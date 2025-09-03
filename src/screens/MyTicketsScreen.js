import React, { useState, useEffect, useCallback } from 'react';
import {
  View,
  Text,
  FlatList,
  TouchableOpacity,
  StyleSheet,
  SafeAreaView,
  RefreshControl,
  TextInput,
  Alert,
} from 'react-native';
import { supabase } from '../../lib/supabaseClient';
import { useFocusEffect } from '@react-navigation/native';

export default function MyTicketsScreen({ navigation }) {
  const [tickets, setTickets] = useState([]);
  const [loading, setLoading] = useState(false);
  const [refreshing, setRefreshing] = useState(false);
  const [searchQuery, setSearchQuery] = useState('');
  const [filteredTickets, setFilteredTickets] = useState([]);
  const [currentUser, setCurrentUser] = useState(null);

  useEffect(() => {
    getCurrentUser();
  }, []);

  const getCurrentUser = async () => {
    const { data: { user } } = await supabase.auth.getUser();
    setCurrentUser(user);
  };

  const fetchMyTickets = async () => {
    if (!currentUser) return;
    
    try {
      const { data, error } = await supabase
        .from('tickets')
        .select(`
          id,
          title,
          description,
          status,
          priority,
          created_at,
          created_by,
          assigned_to,
          category,
          subcategory,
          support_type,
          due_date,
          contact_name,
          phone,
          department,
          profiles:created_by(email),
          assigned_profiles:assigned_to(email)
        `)
        .or(`assigned_to.eq.${currentUser.id},created_by.eq.${currentUser.id}`)
        .order('created_at', { ascending: false });

      if (error) {
        console.error('Error fetching my tickets:', error);
        Alert.alert('Error', 'Failed to fetch tickets');
        return;
      }

      setTickets(data || []);
      setFilteredTickets(data || []);
    } catch (error) {
      console.error('Error in fetchMyTickets:', error);
      Alert.alert('Error', 'An unexpected error occurred');
    }
  };

  useFocusEffect(
    useCallback(() => {
      if (currentUser) {
        setLoading(true);
        fetchMyTickets().finally(() => setLoading(false));
      }
    }, [currentUser])
  );

  const onRefresh = useCallback(() => {
    setRefreshing(true);
    fetchMyTickets().finally(() => setRefreshing(false));
  }, [currentUser]);

  const handleSearch = (query) => {
    setSearchQuery(query);
    if (query.trim() === '') {
      setFilteredTickets(tickets);
    } else {
      const filtered = tickets.filter(ticket =>
        ticket.title.toLowerCase().includes(query.toLowerCase()) ||
        ticket.description.toLowerCase().includes(query.toLowerCase()) ||
        ticket.status.toLowerCase().includes(query.toLowerCase()) ||
        ticket.priority.toLowerCase().includes(query.toLowerCase())
      );
      setFilteredTickets(filtered);
    }
  };

  const getStatusColor = (status) => {
    switch (status) {
      case 'open':
        return '#ff9800';
      case 'in_progress':
        return '#2196f3';
      case 'closed':
        return '#4caf50';
      default:
        return '#666';
    }
  };

  const getPriorityColor = (priority) => {
    switch (priority) {
      case 'high':
        return '#f44336';
      case 'medium':
        return '#ff9800';
      case 'low':
        return '#4caf50';
      default:
        return '#666';
    }
  };

  const formatDate = (dateString) => {
    const date = new Date(dateString);
    return date.toLocaleDateString() + ' ' + date.toLocaleTimeString([], {hour: '2-digit', minute:'2-digit'});
  };

  const renderTicketItem = ({ item }) => {
    const isAssignedToMe = item.assigned_to === currentUser?.id;
    const isCreatedByMe = item.created_by === currentUser?.id;
    
    return (
      <TouchableOpacity
        style={styles.ticketCard}
        onPress={() => navigation.navigate('TicketDetails', { ticketId: item.id })}
      >
        <View style={styles.ticketHeader}>
          <Text style={styles.ticketTitle} numberOfLines={2}>{item.title}</Text>
          <View style={styles.statusBadge}>
            <View style={[styles.statusDot, { backgroundColor: getStatusColor(item.status) }]} />
            <Text style={[styles.statusText, { color: getStatusColor(item.status) }]}>
              {item.status.replace('_', ' ').toUpperCase()}
            </Text>
          </View>
        </View>
        
        {isAssignedToMe && (
          <View style={styles.assignmentBadge}>
            <Text style={styles.assignmentText}>📋 Assigned to me</Text>
          </View>
        )}
        
        {isCreatedByMe && (
          <View style={styles.creatorBadge}>
            <Text style={styles.creatorText}>✏️ Created by me</Text>
          </View>
        )}
        
        <Text style={styles.ticketDescription} numberOfLines={2}>
          {item.description}
        </Text>
        
        <View style={styles.ticketMeta}>
          <View style={styles.metaRow}>
            <Text style={styles.metaLabel}>Priority: </Text>
            <Text style={[styles.metaValue, { color: getPriorityColor(item.priority) }]}>
              {item.priority.toUpperCase()}
            </Text>
          </View>
          <View style={styles.metaRow}>
            <Text style={styles.metaLabel}>Category: </Text>
            <Text style={styles.metaValue}>{item.category}</Text>
          </View>
          <View style={styles.metaRow}>
            <Text style={styles.metaLabel}>Created: </Text>
            <Text style={styles.metaValue}>{formatDate(item.created_at)}</Text>
          </View>
        </View>
      </TouchableOpacity>
    );
  };

  if (loading && !refreshing) {
    return (
      <SafeAreaView style={styles.container}>
        <View style={styles.centerContainer}>
          <Text>Loading your tickets...</Text>
        </View>
      </SafeAreaView>
    );
  }

  return (
    <SafeAreaView style={styles.container}>
      <View style={styles.header}>
        <Text style={styles.headerTitle}>My Tickets</Text>
        <View style={styles.searchContainer}>
          <TextInput
            style={styles.searchInput}
            placeholder="Search my tickets..."
            value={searchQuery}
            onChangeText={handleSearch}
          />
        </View>
      </View>
      
      <FlatList
        data={filteredTickets}
        keyExtractor={(item) => item.id.toString()}
        renderItem={renderTicketItem}
        contentContainerStyle={styles.listContainer}
        refreshControl={
          <RefreshControl refreshing={refreshing} onRefresh={onRefresh} />
        }
        ListEmptyComponent={
          <View style={styles.emptyContainer}>
            <Text style={styles.emptyText}>No tickets assigned to you or created by you</Text>
          </View>
        }
      />
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#f5f7fa',
  },
  centerContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
  },
  header: {
    backgroundColor: 'white',
    padding: 20,
    borderBottomWidth: 1,
    borderBottomColor: '#eee',
  },
  headerTitle: {
    fontSize: 24,
    fontWeight: 'bold',
    color: '#333',
    marginBottom: 15,
  },
  searchContainer: {
    marginBottom: 5,
  },
  searchInput: {
    borderWidth: 1,
    borderColor: '#ddd',
    borderRadius: 8,
    paddingHorizontal: 15,
    paddingVertical: 10,
    fontSize: 16,
    backgroundColor: '#f9f9f9',
  },
  listContainer: {
    padding: 15,
  },
  ticketCard: {
    backgroundColor: 'white',
    padding: 16,
    borderRadius: 12,
    marginBottom: 12,
    shadowColor: '#000',
    shadowOffset: {
      width: 0,
      height: 2,
    },
    shadowOpacity: 0.1,
    shadowRadius: 3.84,
    elevation: 5,
  },
  ticketHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'flex-start',
    marginBottom: 8,
  },
  ticketTitle: {
    fontSize: 18,
    fontWeight: 'bold',
    color: '#333',
    flex: 1,
    marginRight: 10,
  },
  statusBadge: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  statusDot: {
    width: 8,
    height: 8,
    borderRadius: 4,
    marginRight: 5,
  },
  statusText: {
    fontSize: 12,
    fontWeight: '600',
  },
  assignmentBadge: {
    backgroundColor: '#e3f2fd',
    padding: 6,
    borderRadius: 6,
    marginBottom: 8,
    alignSelf: 'flex-start',
  },
  assignmentText: {
    fontSize: 12,
    color: '#1976d2',
    fontWeight: '500',
  },
  creatorBadge: {
    backgroundColor: '#f3e5f5',
    padding: 6,
    borderRadius: 6,
    marginBottom: 8,
    alignSelf: 'flex-start',
  },
  creatorText: {
    fontSize: 12,
    color: '#7b1fa2',
    fontWeight: '500',
  },
  ticketDescription: {
    fontSize: 14,
    color: '#666',
    marginBottom: 12,
    lineHeight: 20,
  },
  ticketMeta: {
    borderTopWidth: 1,
    borderTopColor: '#f0f0f0',
    paddingTop: 12,
  },
  metaRow: {
    flexDirection: 'row',
    marginBottom: 4,
  },
  metaLabel: {
    fontSize: 14,
    color: '#888',
    minWidth: 90,
  },
  metaValue: {
    fontSize: 14,
    color: '#333',
    flex: 1,
    fontWeight: '500',
  },
  emptyContainer: {
    alignItems: 'center',
    justifyContent: 'center',
    paddingVertical: 50,
  },
  emptyText: {
    fontSize: 16,
    color: '#666',
    textAlign: 'center',
  },
});