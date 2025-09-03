import React, { useState, useEffect } from 'react';
import {
  View,
  Text,
  ScrollView,
  TouchableOpacity,
  StyleSheet,
  SafeAreaView,
  TextInput,
  Alert,
  RefreshControl,
} from 'react-native';
import { supabase } from '../../lib/supabaseClient';

export default function TicketDetailsScreen({ route, navigation }) {
  const { ticketId } = route.params;
  const [ticket, setTicket] = useState(null);
  const [comments, setComments] = useState([]);
  const [newComment, setNewComment] = useState('');
  const [loading, setLoading] = useState(true);
  const [refreshing, setRefreshing] = useState(false);
  const [currentUser, setCurrentUser] = useState(null);

  useEffect(() => {
    getCurrentUser();
    fetchTicketDetails();
    fetchComments();
  }, [ticketId]);

  const getCurrentUser = async () => {
    const { data: { user } } = await supabase.auth.getUser();
    setCurrentUser(user);
  };

  const fetchTicketDetails = async () => {
    try {
      const { data, error } = await supabase
        .from('tickets')
        .select(`
          *,
          profiles:created_by(email),
          assigned_profiles:assigned_to(email)
        `)
        .eq('id', ticketId)
        .single();

      if (error) {
        console.error('Error fetching ticket:', error);
        Alert.alert('Error', 'Failed to load ticket details');
        navigation.goBack();
        return;
      }

      setTicket(data);
    } catch (error) {
      console.error('Error in fetchTicketDetails:', error);
      Alert.alert('Error', 'An unexpected error occurred');
    } finally {
      setLoading(false);
    }
  };

  const fetchComments = async () => {
    try {
      const { data, error } = await supabase
        .from('comments')
        .select(`
          id,
          comment_text,
          created_at,
          created_by,
          profiles:created_by(email)
        `)
        .eq('ticket_id', ticketId)
        .order('created_at', { ascending: true });

      if (error) {
        console.error('Error fetching comments:', error);
        return;
      }

      setComments(data || []);
    } catch (error) {
      console.error('Error in fetchComments:', error);
    }
  };

  const onRefresh = async () => {
    setRefreshing(true);
    await Promise.all([fetchTicketDetails(), fetchComments()]);
    setRefreshing(false);
  };

  const handleAddComment = async () => {
    if (!newComment.trim()) {
      Alert.alert('Error', 'Please enter a comment');
      return;
    }

    try {
      const { error } = await supabase
        .from('comments')
        .insert([
          {
            ticket_id: ticketId,
            comment_text: newComment.trim(),
            created_by: currentUser.id,
          },
        ]);

      if (error) {
        console.error('Error adding comment:', error);
        Alert.alert('Error', 'Failed to add comment');
        return;
      }

      setNewComment('');
      fetchComments();
    } catch (error) {
      console.error('Error in handleAddComment:', error);
      Alert.alert('Error', 'An unexpected error occurred');
    }
  };

  const handleStatusChange = async (newStatus) => {
    try {
      const { error } = await supabase
        .from('tickets')
        .update({ status: newStatus })
        .eq('id', ticketId);

      if (error) {
        console.error('Error updating status:', error);
        Alert.alert('Error', 'Failed to update status');
        return;
      }

      setTicket(prev => ({ ...prev, status: newStatus }));
      Alert.alert('Success', 'Status updated successfully');
    } catch (error) {
      console.error('Error in handleStatusChange:', error);
      Alert.alert('Error', 'An unexpected error occurred');
    }
  };

  const handlePriorityChange = async (newPriority) => {
    try {
      const { error } = await supabase
        .from('tickets')
        .update({ priority: newPriority })
        .eq('id', ticketId);

      if (error) {
        console.error('Error updating priority:', error);
        Alert.alert('Error', 'Failed to update priority');
        return;
      }

      setTicket(prev => ({ ...prev, priority: newPriority }));
      Alert.alert('Success', 'Priority updated successfully');
    } catch (error) {
      console.error('Error in handlePriorityChange:', error);
      Alert.alert('Error', 'An unexpected error occurred');
    }
  };

  const showStatusOptions = () => {
    Alert.alert(
      'Change Status',
      'Select new status:',
      [
        { text: 'Open', onPress: () => handleStatusChange('open') },
        { text: 'In Progress', onPress: () => handleStatusChange('in_progress') },
        { text: 'Closed', onPress: () => handleStatusChange('closed') },
        { text: 'Cancel', style: 'cancel' },
      ]
    );
  };

  const showPriorityOptions = () => {
    Alert.alert(
      'Change Priority',
      'Select new priority:',
      [
        { text: 'Low', onPress: () => handlePriorityChange('low') },
        { text: 'Medium', onPress: () => handlePriorityChange('medium') },
        { text: 'High', onPress: () => handlePriorityChange('high') },
        { text: 'Cancel', style: 'cancel' },
      ]
    );
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

  if (loading) {
    return (
      <SafeAreaView style={styles.container}>
        <View style={styles.centerContainer}>
          <Text>Loading ticket details...</Text>
        </View>
      </SafeAreaView>
    );
  }

  if (!ticket) {
    return (
      <SafeAreaView style={styles.container}>
        <View style={styles.centerContainer}>
          <Text>Ticket not found</Text>
        </View>
      </SafeAreaView>
    );
  }

  return (
    <SafeAreaView style={styles.container}>
      <ScrollView
        style={styles.scrollContainer}
        refreshControl={<RefreshControl refreshing={refreshing} onRefresh={onRefresh} />}
      >
        {/* Ticket Header */}
        <View style={styles.headerCard}>
          <Text style={styles.ticketTitle}>{ticket.title}</Text>
          
          <View style={styles.statusRow}>
            <TouchableOpacity
              style={[styles.statusBadge, { backgroundColor: getStatusColor(ticket.status) }]}
              onPress={showStatusOptions}
            >
              <Text style={styles.statusText}>
                {ticket.status.replace('_', ' ').toUpperCase()}
              </Text>
            </TouchableOpacity>
            
            <TouchableOpacity
              style={[styles.priorityBadge, { backgroundColor: getPriorityColor(ticket.priority) }]}
              onPress={showPriorityOptions}
            >
              <Text style={styles.priorityText}>
                {ticket.priority.toUpperCase()}
              </Text>
            </TouchableOpacity>
          </View>
        </View>

        {/* Ticket Details */}
        <View style={styles.detailsCard}>
          <Text style={styles.sectionTitle}>Ticket Details</Text>
          
          <View style={styles.detailRow}>
            <Text style={styles.detailLabel}>Category:</Text>
            <Text style={styles.detailValue}>{ticket.category}</Text>
          </View>
          
          {ticket.subcategory && (
            <View style={styles.detailRow}>
              <Text style={styles.detailLabel}>Subcategory:</Text>
              <Text style={styles.detailValue}>{ticket.subcategory}</Text>
            </View>
          )}
          
          <View style={styles.detailRow}>
            <Text style={styles.detailLabel}>Support Type:</Text>
            <Text style={styles.detailValue}>{ticket.support_type}</Text>
          </View>
          
          <View style={styles.detailRow}>
            <Text style={styles.detailLabel}>Created By:</Text>
            <Text style={styles.detailValue}>{ticket.profiles?.email || 'Unknown'}</Text>
          </View>
          
          {ticket.assigned_profiles && (
            <View style={styles.detailRow}>
              <Text style={styles.detailLabel}>Assigned To:</Text>
              <Text style={styles.detailValue}>{ticket.assigned_profiles.email}</Text>
            </View>
          )}
          
          <View style={styles.detailRow}>
            <Text style={styles.detailLabel}>Created:</Text>
            <Text style={styles.detailValue}>{formatDate(ticket.created_at)}</Text>
          </View>
          
          {ticket.due_date && (
            <View style={styles.detailRow}>
              <Text style={styles.detailLabel}>Due Date:</Text>
              <Text style={styles.detailValue}>{formatDate(ticket.due_date)}</Text>
            </View>
          )}
          
          <View style={styles.detailRow}>
            <Text style={styles.detailLabel}>Contact:</Text>
            <Text style={styles.detailValue}>
              {ticket.contact_name}
              {ticket.phone && ` (${ticket.phone})`}
            </Text>
          </View>
          
          <View style={styles.detailRow}>
            <Text style={styles.detailLabel}>Department:</Text>
            <Text style={styles.detailValue}>{ticket.department}</Text>
          </View>
        </View>

        {/* Description */}
        <View style={styles.descriptionCard}>
          <Text style={styles.sectionTitle}>Description</Text>
          <Text style={styles.descriptionText}>{ticket.description}</Text>
        </View>

        {/* Comments Section */}
        <View style={styles.commentsCard}>
          <Text style={styles.sectionTitle}>Comments ({comments.length})</Text>
          
          {comments.map((comment) => (
            <View key={comment.id} style={styles.commentItem}>
              <View style={styles.commentHeader}>
                <Text style={styles.commentAuthor}>
                  {comment.profiles?.email || 'Unknown'}
                </Text>
                <Text style={styles.commentDate}>{formatDate(comment.created_at)}</Text>
              </View>
              <Text style={styles.commentText}>{comment.comment_text}</Text>
            </View>
          ))}
          
          {comments.length === 0 && (
            <Text style={styles.noComments}>No comments yet</Text>
          )}
        </View>

        {/* Add Comment */}
        <View style={styles.addCommentCard}>
          <Text style={styles.sectionTitle}>Add Comment</Text>
          <TextInput
            style={styles.commentInput}
            value={newComment}
            onChangeText={setNewComment}
            placeholder="Enter your comment..."
            multiline={true}
            numberOfLines={3}
            textAlignVertical="top"
          />
          <TouchableOpacity style={styles.addCommentButton} onPress={handleAddComment}>
            <Text style={styles.addCommentButtonText}>Add Comment</Text>
          </TouchableOpacity>
        </View>
      </ScrollView>
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
  scrollContainer: {
    flex: 1,
  },
  headerCard: {
    backgroundColor: 'white',
    padding: 20,
    borderBottomWidth: 1,
    borderBottomColor: '#eee',
  },
  ticketTitle: {
    fontSize: 24,
    fontWeight: 'bold',
    color: '#333',
    marginBottom: 15,
    lineHeight: 30,
  },
  statusRow: {
    flexDirection: 'row',
    gap: 10,
  },
  statusBadge: {
    paddingHorizontal: 12,
    paddingVertical: 6,
    borderRadius: 20,
  },
  statusText: {
    color: 'white',
    fontSize: 12,
    fontWeight: '600',
  },
  priorityBadge: {
    paddingHorizontal: 12,
    paddingVertical: 6,
    borderRadius: 20,
  },
  priorityText: {
    color: 'white',
    fontSize: 12,
    fontWeight: '600',
  },
  detailsCard: {
    backgroundColor: 'white',
    margin: 15,
    padding: 20,
    borderRadius: 10,
    shadowColor: '#000',
    shadowOffset: {
      width: 0,
      height: 2,
    },
    shadowOpacity: 0.1,
    shadowRadius: 3.84,
    elevation: 5,
  },
  descriptionCard: {
    backgroundColor: 'white',
    margin: 15,
    marginTop: 0,
    padding: 20,
    borderRadius: 10,
    shadowColor: '#000',
    shadowOffset: {
      width: 0,
      height: 2,
    },
    shadowOpacity: 0.1,
    shadowRadius: 3.84,
    elevation: 5,
  },
  commentsCard: {
    backgroundColor: 'white',
    margin: 15,
    marginTop: 0,
    padding: 20,
    borderRadius: 10,
    shadowColor: '#000',
    shadowOffset: {
      width: 0,
      height: 2,
    },
    shadowOpacity: 0.1,
    shadowRadius: 3.84,
    elevation: 5,
  },
  addCommentCard: {
    backgroundColor: 'white',
    margin: 15,
    marginTop: 0,
    marginBottom: 30,
    padding: 20,
    borderRadius: 10,
    shadowColor: '#000',
    shadowOffset: {
      width: 0,
      height: 2,
    },
    shadowOpacity: 0.1,
    shadowRadius: 3.84,
    elevation: 5,
  },
  sectionTitle: {
    fontSize: 18,
    fontWeight: 'bold',
    color: '#333',
    marginBottom: 15,
  },
  detailRow: {
    flexDirection: 'row',
    marginBottom: 8,
  },
  detailLabel: {
    fontSize: 14,
    color: '#666',
    minWidth: 120,
    fontWeight: '500',
  },
  detailValue: {
    fontSize: 14,
    color: '#333',
    flex: 1,
  },
  descriptionText: {
    fontSize: 16,
    color: '#333',
    lineHeight: 24,
  },
  commentItem: {
    borderBottomWidth: 1,
    borderBottomColor: '#f0f0f0',
    paddingBottom: 15,
    marginBottom: 15,
  },
  commentHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    marginBottom: 8,
  },
  commentAuthor: {
    fontSize: 14,
    fontWeight: '600',
    color: '#333',
  },
  commentDate: {
    fontSize: 12,
    color: '#666',
  },
  commentText: {
    fontSize: 14,
    color: '#333',
    lineHeight: 20,
  },
  noComments: {
    fontSize: 14,
    color: '#666',
    fontStyle: 'italic',
    textAlign: 'center',
    paddingVertical: 20,
  },
  commentInput: {
    borderWidth: 1,
    borderColor: '#ddd',
    borderRadius: 8,
    paddingHorizontal: 15,
    paddingVertical: 12,
    fontSize: 16,
    backgroundColor: '#f9f9f9',
    marginBottom: 15,
    minHeight: 80,
  },
  addCommentButton: {
    backgroundColor: '#4CAF50',
    paddingVertical: 12,
    borderRadius: 8,
    alignItems: 'center',
  },
  addCommentButtonText: {
    color: 'white',
    fontSize: 16,
    fontWeight: '600',
  },
});