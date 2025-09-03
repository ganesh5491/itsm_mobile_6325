import React, { useEffect, useState } from 'react';
import { NavigationContainer } from '@react-navigation/native';
import { createStackNavigator } from '@react-navigation/stack';
import { createBottomTabNavigator } from '@react-navigation/bottom-tabs';
import { Text, View, Alert } from 'react-native';
import { supabase } from './lib/supabaseClient';
import AsyncStorage from '@react-native-async-storage/async-storage';
import 'react-native-url-polyfill/auto';

// Import screens
import LoginScreen from './src/screens/LoginScreen';
import AllTicketsScreen from './src/screens/AllTicketsScreen';
import MyTicketsScreen from './src/screens/MyTicketsScreen';
import CreateTicketScreen from './src/screens/CreateTicketScreen';
import TicketDetailsScreen from './src/screens/TicketDetailsScreen';
import ProfileScreen from './src/screens/ProfileScreen';

const Stack = createStackNavigator();
const Tab = createBottomTabNavigator();

// Tab Navigator for main app
function MainTabNavigator({ userRole }) {
  return (
    <Tab.Navigator
      screenOptions={{
        tabBarActiveTintColor: '#4CAF50',
        tabBarInactiveTintColor: '#888',
        headerShown: false,
      }}
    >
      <Tab.Screen 
        name="AllTickets" 
        component={AllTicketsScreen}
        options={{
          tabBarLabel: 'All Tickets',
          tabBarIcon: ({ color }) => <Text style={{color}}>🎫</Text>,
        }}
      />
      <Tab.Screen 
        name="MyTickets" 
        component={MyTicketsScreen}
        options={{
          tabBarLabel: 'My Tickets',
          tabBarIcon: ({ color }) => <Text style={{color}}>📋</Text>,
        }}
      />
      <Tab.Screen 
        name="CreateTicket" 
        component={CreateTicketScreen}
        options={{
          tabBarLabel: 'Create',
          tabBarIcon: ({ color }) => <Text style={{color}}>➕</Text>,
        }}
      />
      <Tab.Screen 
        name="Profile" 
        component={ProfileScreen}
        options={{
          tabBarLabel: 'Profile',
          tabBarIcon: ({ color }) => <Text style={{color}}>👤</Text>,
        }}
      />
    </Tab.Navigator>
  );
}

export default function App() {
  const [isLoading, setIsLoading] = useState(true);
  const [user, setUser] = useState(null);
  const [userRole, setUserRole] = useState(null);

  useEffect(() => {
    // Get initial session
    supabase.auth.getSession().then(({ data: { session } }) => {
      if (session) {
        setUser(session.user);
        getUserRole(session.user.id);
      }
      setIsLoading(false);
    });

    // Listen for auth changes
    const { data: { subscription } } = supabase.auth.onAuthStateChange((_event, session) => {
      if (session) {
        setUser(session.user);
        getUserRole(session.user.id);
      } else {
        setUser(null);
        setUserRole(null);
      }
    });

    return () => subscription.unsubscribe();
  }, []);

  const getUserRole = async (userId) => {
    try {
      const { data, error } = await supabase
        .from('profiles')
        .select('role')
        .eq('id', userId)
        .single();

      if (error && error.code !== 'PGRST116') {
        console.error('Error fetching user role:', error);
        return;
      }
      
      if (data) {
        setUserRole(data.role);
        await AsyncStorage.setItem('userRole', data.role);
      } else {
        // Create profile if doesn't exist
        const { error: insertError } = await supabase
          .from('profiles')
          .insert({ id: userId, role: 'agent' });
        
        if (!insertError) {
          setUserRole('agent');
          await AsyncStorage.setItem('userRole', 'agent');
        }
      }
    } catch (error) {
      console.error('Error in getUserRole:', error);
      // Default to agent role
      setUserRole('agent');
      await AsyncStorage.setItem('userRole', 'agent');
    }
  };

  if (isLoading) {
    return (
      <View style={{ flex: 1, justifyContent: 'center', alignItems: 'center' }}>
        <Text>Loading...</Text>
      </View>
    );
  }

  return (
    <NavigationContainer>
      <Stack.Navigator screenOptions={{ headerShown: false }}>
        {user ? (
          <>
            <Stack.Screen name="Main">
              {(props) => <MainTabNavigator {...props} userRole={userRole} />}
            </Stack.Screen>
            <Stack.Screen 
              name="TicketDetails" 
              component={TicketDetailsScreen}
              options={{ headerShown: true, title: 'Ticket Details' }}
            />
          </>
        ) : (
          <Stack.Screen name="Login" component={LoginScreen} />
        )}
      </Stack.Navigator>
    </NavigationContainer>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#f5f7fa',
  },
  scrollContainer: {
    flexGrow: 1,
    padding: 20,
  },
  header: {
    alignItems: 'center',
    marginBottom: 30,
    paddingTop: 20,
  },
  logo: {
    width: 80,
    height: 80,
    backgroundColor: '#4CAF50',
    borderRadius: 40,
    justifyContent: 'center',
    alignItems: 'center',
    marginBottom: 15,
  },
  logoText: {
    color: 'white',
    fontSize: 32,
    fontWeight: 'bold',
  },
  title: {
    fontSize: 28,
    fontWeight: 'bold',
    color: '#333',
    marginBottom: 5,
  },
  subtitle: {
    fontSize: 16,
    color: '#666',
    textAlign: 'center',
  },
  content: {
    backgroundColor: 'white',
    borderRadius: 12,
    padding: 20,
    shadowColor: '#000',
    shadowOffset: {
      width: 0,
      height: 2,
    },
    shadowOpacity: 0.1,
    shadowRadius: 3.84,
    elevation: 5,
  },
  statusTitle: {
    fontSize: 20,
    fontWeight: 'bold',
    color: '#4CAF50',
    marginBottom: 10,
    textAlign: 'center',
  },
  statusText: {
    fontSize: 16,
    color: '#333',
    textAlign: 'center',
    marginBottom: 25,
  },
  featuresSection: {
    marginBottom: 25,
  },
  configSection: {
    backgroundColor: '#f8f9fa',
    padding: 15,
    borderRadius: 8,
    borderLeftWidth: 4,
    borderLeftColor: '#4CAF50',
  },
  sectionTitle: {
    fontSize: 18,
    fontWeight: 'bold',
    color: '#333',
    marginBottom: 15,
  },
  featureList: {
    paddingLeft: 10,
  },
  featureItem: {
    fontSize: 14,
    color: '#555',
    marginBottom: 8,
    lineHeight: 20,
  },
  configItem: {
    fontSize: 14,
    color: '#555',
    marginBottom: 5,
    fontFamily: 'monospace',
  },
});