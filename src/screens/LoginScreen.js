import React, { useState } from 'react';
import {
  View,
  Text,
  TextInput,
  TouchableOpacity,
  StyleSheet,
  SafeAreaView,
  Alert,
  KeyboardAvoidingView,
  Platform,
  ScrollView,
} from 'react-native';
import { supabase } from '../../lib/supabaseClient';

export default function LoginScreen() {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [isLogin, setIsLogin] = useState(true);
  const [loading, setLoading] = useState(false);

  const handleAuth = async () => {
    if (!email || !password) {
      Alert.alert('Error', 'Please fill in all fields');
      return;
    }

    setLoading(true);
    try {
      if (isLogin) {
        const { error } = await supabase.auth.signInWithPassword({
          email,
          password,
        });
        if (error) {
          Alert.alert('Login Error', error.message);
        }
      } else {
        const { error } = await supabase.auth.signUp({
          email,
          password,
        });
        if (error) {
          Alert.alert('Signup Error', error.message);
        } else {
          Alert.alert('Success', 'Check your email for verification link');
          setIsLogin(true);
        }
      }
    } catch (error) {
      Alert.alert('Error', 'An unexpected error occurred');
    } finally {
      setLoading(false);
    }
  };

  return (
    <SafeAreaView style={styles.container}>
      <KeyboardAvoidingView
        behavior={Platform.OS === 'ios' ? 'padding' : 'height'}
        style={styles.keyboardAvoidingView}
      >
        <ScrollView contentContainerStyle={styles.scrollContainer}>
          <View style={styles.header}>
            <View style={styles.logo}>
              <Text style={styles.logoText}>IT</Text>
            </View>
            <Text style={styles.title}>ITSM Mobile</Text>
            <Text style={styles.subtitle}>IT Service Management System</Text>
          </View>

          <View style={styles.formContainer}>
            <Text style={styles.formTitle}>
              {isLogin ? 'Login to Continue' : 'Create Account'}
            </Text>

            <View style={styles.inputContainer}>
              <Text style={styles.label}>Email</Text>
              <TextInput
                style={styles.input}
                value={email}
                onChangeText={setEmail}
                placeholder="Enter your email"
                keyboardType="email-address"
                autoCapitalize="none"
                autoCorrect={false}
              />
            </View>

            <View style={styles.inputContainer}>
              <Text style={styles.label}>Password</Text>
              <TextInput
                style={styles.input}
                value={password}
                onChangeText={setPassword}
                placeholder="Enter your password"
                secureTextEntry
                autoCapitalize="none"
                autoCorrect={false}
              />
            </View>

            <TouchableOpacity
              style={[styles.authButton, loading && styles.disabledButton]}
              onPress={handleAuth}
              disabled={loading}
            >
              <Text style={styles.authButtonText}>
                {loading ? 'Loading...' : isLogin ? 'Login' : 'Sign Up'}
              </Text>
            </TouchableOpacity>

            <TouchableOpacity
              style={styles.switchModeButton}
              onPress={() => setIsLogin(!isLogin)}
            >
              <Text style={styles.switchModeText}>
                {isLogin
                  ? "Don't have an account? Sign Up"
                  : 'Already have an account? Login'}
              </Text>
            </TouchableOpacity>

            <View style={styles.roleInfo}>
              <Text style={styles.roleInfoTitle}>Role Information:</Text>
              <Text style={styles.roleInfoText}>• Admin: Can view and manage all tickets</Text>
              <Text style={styles.roleInfoText}>• Agent: Can view assigned tickets only</Text>
            </View>
          </View>
        </ScrollView>
      </KeyboardAvoidingView>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#f5f7fa',
  },
  keyboardAvoidingView: {
    flex: 1,
  },
  scrollContainer: {
    flexGrow: 1,
    justifyContent: 'center',
    padding: 20,
  },
  header: {
    alignItems: 'center',
    marginBottom: 40,
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
  formContainer: {
    backgroundColor: 'white',
    padding: 30,
    borderRadius: 15,
    shadowColor: '#000',
    shadowOffset: {
      width: 0,
      height: 4,
    },
    shadowOpacity: 0.1,
    shadowRadius: 8,
    elevation: 5,
  },
  formTitle: {
    fontSize: 24,
    fontWeight: 'bold',
    color: '#333',
    textAlign: 'center',
    marginBottom: 30,
  },
  inputContainer: {
    marginBottom: 20,
  },
  label: {
    fontSize: 16,
    fontWeight: '500',
    color: '#333',
    marginBottom: 8,
  },
  input: {
    borderWidth: 1,
    borderColor: '#ddd',
    borderRadius: 10,
    paddingHorizontal: 15,
    paddingVertical: 12,
    fontSize: 16,
    backgroundColor: '#f9f9f9',
  },
  authButton: {
    backgroundColor: '#4CAF50',
    paddingVertical: 15,
    borderRadius: 10,
    alignItems: 'center',
    marginTop: 20,
    marginBottom: 15,
  },
  disabledButton: {
    backgroundColor: '#ccc',
  },
  authButtonText: {
    color: 'white',
    fontSize: 18,
    fontWeight: 'bold',
  },
  switchModeButton: {
    alignItems: 'center',
    paddingVertical: 10,
  },
  switchModeText: {
    color: '#4CAF50',
    fontSize: 16,
    fontWeight: '500',
  },
  roleInfo: {
    marginTop: 30,
    padding: 15,
    backgroundColor: '#f0f8f0',
    borderRadius: 8,
    borderLeftWidth: 4,
    borderLeftColor: '#4CAF50',
  },
  roleInfoTitle: {
    fontSize: 16,
    fontWeight: 'bold',
    color: '#333',
    marginBottom: 8,
  },
  roleInfoText: {
    fontSize: 14,
    color: '#555',
    marginBottom: 4,
  },
});