import React, { useState, useEffect } from 'react';
import {
  View,
  Text,
  TouchableOpacity,
  StyleSheet,
  SafeAreaView,
  Alert,
  ScrollView,
} from 'react-native';
import { supabase } from '../../lib/supabaseClient';

export default function ProfileScreen() {
  const [user, setUser] = useState(null);
  const [profile, setProfile] = useState(null);
  const [stats, setStats] = useState({
    totalTickets: 0,
    assignedTickets: 0,
    openTickets: 0,
    closedTickets: 0,
  });

  useEffect(() => {
    getCurrentUser();
  }, []);

  useEffect(() => {
    if (user) {
      fetchProfile();
      fetchStats();
    }
  }, [user]);

  const getCurrentUser = async () => {
    const { data: { user } } = await supabase.auth.getUser();
    setUser(user);
  };

  const fetchProfile = async () => {
    try {
      const { data, error } = await supabase
        .from('profiles')
        .select('*')
        .eq('id', user.id)
        .single();

      if (error && error.code !== 'PGRST116') {
        console.error('Error fetching profile:', error);
        return;
      }

      setProfile(data);
    } catch (error) {
      console.error('Error in fetchProfile:', error);
    }
  };

  const fetchStats = async () => {
    try {
      // Get total tickets created by user
      const { count: totalTickets } = await supabase
        .from('tickets')
        .select('*', { count: 'exact', head: true })
        .eq('created_by', user.id);

      // Get tickets assigned to user
      const { count: assignedTickets } = await supabase
        .from('tickets')
        .select('*', { count: 'exact', head: true })
        .eq('assigned_to', user.id);

      // Get open tickets for user
      const { count: openTickets } = await supabase
        .from('tickets')
        .select('*', { count: 'exact', head: true })
        .or(`created_by.eq.${user.id},assigned_to.eq.${user.id}`)
        .eq('status', 'open');

      // Get closed tickets for user
      const { count: closedTickets } = await supabase
        .from('tickets')
        .select('*', { count: 'exact', head: true })
        .or(`created_by.eq.${user.id},assigned_to.eq.${user.id}`)
        .eq('status', 'closed');

      setStats({
        totalTickets: totalTickets || 0,
        assignedTickets: assignedTickets || 0,
        openTickets: openTickets || 0,
        closedTickets: closedTickets || 0,
      });
    } catch (error) {
      console.error('Error fetching stats:', error);
    }
  };

  const handleSignOut = async () => {
    Alert.alert(
      'Sign Out',
      'Are you sure you want to sign out?',
      [
        {
          text: 'Cancel',
          style: 'cancel',
        },
        {
          text: 'Sign Out',
          onPress: async () => {
            const { error } = await supabase.auth.signOut();
            if (error) {
              Alert.alert('Error', 'Failed to sign out');
            }
          },
        },
      ]
    );
  };

  const StatCard = ({ title, value, color = '#4CAF50' }) => (
    <View style={[styles.statCard, { borderLeftColor: color }]}>
      <Text style={styles.statValue}>{value}</Text>
      <Text style={styles.statTitle}>{title}</Text>
    </View>
  );

  if (!user) {
    return (
      <SafeAreaView style={styles.container}>
        <View style={styles.centerContainer}>
          <Text>Loading profile...</Text>
        </View>
      </SafeAreaView>
    );
  }

  return (
    <SafeAreaView style={styles.container}>
      <ScrollView style={styles.scrollContainer}>
        {/* Header */}
        <View style={styles.header}>
          <View style={styles.avatar}>
            <Text style={styles.avatarText}>
              {user.email?.charAt(0).toUpperCase() || 'U'}
            </Text>
          </View>
          <Text style={styles.userEmail}>{user.email}</Text>
          <Text style={styles.userRole}>
            Role: {profile?.role?.toUpperCase() || 'AGENT'}
          </Text>
        </View>

        {/* Stats */}
        <View style={styles.statsContainer}>
          <Text style={styles.sectionTitle}>Your Statistics</Text>
          
          <View style={styles.statsGrid}>
            <StatCard 
              title="Created Tickets" 
              value={stats.totalTickets} 
              color="#2196F3" 
            />
            <StatCard 
              title="Assigned Tickets" 
              value={stats.assignedTickets} 
              color="#FF9800" 
            />
            <StatCard 
              title="Open Tickets" 
              value={stats.openTickets} 
              color="#F44336" 
            />
            <StatCard 
              title="Closed Tickets" 
              value={stats.closedTickets} 
              color="#4CAF50" 
            />
          </View>
        </View>

        {/* User Information */}
        <View style={styles.infoContainer}>
          <Text style={styles.sectionTitle}>Account Information</Text>
          
          <View style={styles.infoItem}>
            <Text style={styles.infoLabel}>Email:</Text>
            <Text style={styles.infoValue}>{user.email}</Text>
          </View>
          
          <View style={styles.infoItem}>
            <Text style={styles.infoLabel}>User ID:</Text>
            <Text style={styles.infoValue}>{user.id}</Text>
          </View>
          
          <View style={styles.infoItem}>
            <Text style={styles.infoLabel}>Account Created:</Text>
            <Text style={styles.infoValue}>
              {new Date(user.created_at).toLocaleDateString()}
            </Text>
          </View>
          
          <View style={styles.infoItem}>
            <Text style={styles.infoLabel}>Last Sign In:</Text>
            <Text style={styles.infoValue}>
              {user.last_sign_in_at 
                ? new Date(user.last_sign_in_at).toLocaleDateString() 
                : 'Never'}
            </Text>
          </View>
        </View>

        {/* Actions */}
        <View style={styles.actionsContainer}>
          <Text style={styles.sectionTitle}>Actions</Text>
          
          <TouchableOpacity 
            style={styles.refreshButton} 
            onPress={() => {
              fetchProfile();
              fetchStats();
            }}
          >
            <Text style={styles.refreshButtonText}>🔄 Refresh Stats</Text>
          </TouchableOpacity>
          
          <TouchableOpacity style={styles.signOutButton} onPress={handleSignOut}>
            <Text style={styles.signOutButtonText}>Sign Out</Text>
          </TouchableOpacity>
        </View>

        {/* App Info */}
        <View style={styles.appInfoContainer}>
          <Text style={styles.sectionTitle}>About</Text>
          <Text style={styles.appInfoText}>ITSM Mobile v1.0.0</Text>
          <Text style={styles.appInfoText}>IT Service Management System</Text>
          <Text style={styles.appInfoText}>Built with React Native & Supabase</Text>
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
  header: {
    backgroundColor: 'white',
    alignItems: 'center',
    padding: 30,
    borderBottomWidth: 1,
    borderBottomColor: '#eee',
  },
  avatar: {
    width: 80,
    height: 80,
    borderRadius: 40,
    backgroundColor: '#4CAF50',
    justifyContent: 'center',
    alignItems: 'center',
    marginBottom: 15,
  },
  avatarText: {
    fontSize: 32,
    fontWeight: 'bold',
    color: 'white',
  },
  userEmail: {
    fontSize: 18,
    fontWeight: '600',
    color: '#333',
    marginBottom: 5,
  },
  userRole: {
    fontSize: 14,
    color: '#666',
    backgroundColor: '#e8f5e8',
    paddingHorizontal: 12,
    paddingVertical: 4,
    borderRadius: 12,
  },
  statsContainer: {
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
  sectionTitle: {
    fontSize: 18,
    fontWeight: 'bold',
    color: '#333',
    marginBottom: 15,
  },
  statsGrid: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    gap: 10,
  },
  statCard: {
    backgroundColor: '#f9f9f9',
    padding: 15,
    borderRadius: 8,
    flex: 0.48,
    borderLeftWidth: 4,
    alignItems: 'center',
  },
  statValue: {
    fontSize: 24,
    fontWeight: 'bold',
    color: '#333',
    marginBottom: 5,
  },
  statTitle: {
    fontSize: 12,
    color: '#666',
    textAlign: 'center',
  },
  infoContainer: {
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
  infoItem: {
    flexDirection: 'row',
    paddingVertical: 10,
    borderBottomWidth: 1,
    borderBottomColor: '#f0f0f0',
  },
  infoLabel: {
    fontSize: 14,
    color: '#666',
    minWidth: 120,
    fontWeight: '500',
  },
  infoValue: {
    fontSize: 14,
    color: '#333',
    flex: 1,
  },
  actionsContainer: {
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
  refreshButton: {
    backgroundColor: '#2196F3',
    paddingVertical: 12,
    paddingHorizontal: 20,
    borderRadius: 8,
    alignItems: 'center',
    marginBottom: 10,
  },
  refreshButtonText: {
    color: 'white',
    fontSize: 16,
    fontWeight: '600',
  },
  signOutButton: {
    backgroundColor: '#f44336',
    paddingVertical: 12,
    paddingHorizontal: 20,
    borderRadius: 8,
    alignItems: 'center',
  },
  signOutButtonText: {
    color: 'white',
    fontSize: 16,
    fontWeight: '600',
  },
  appInfoContainer: {
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
  appInfoText: {
    fontSize: 14,
    color: '#666',
    marginBottom: 5,
    textAlign: 'center',
  },
});