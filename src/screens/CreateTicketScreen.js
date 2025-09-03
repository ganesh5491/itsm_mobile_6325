import React, { useState, useEffect } from 'react';
import {
  View,
  Text,
  TextInput,
  TouchableOpacity,
  StyleSheet,
  SafeAreaView,
  ScrollView,
  Alert,
  Platform,
} from 'react-native';
import { supabase } from '../../lib/supabaseClient';

// Dropdown picker component (simplified)
const DropdownPicker = ({ label, value, onValueChange, items, placeholder }) => (
  <View style={styles.dropdownContainer}>
    <Text style={styles.label}>{label}</Text>
    <View style={styles.pickerContainer}>
      {items.map((item, index) => (
        <TouchableOpacity
          key={index}
          style={[styles.pickerItem, value === item.value && styles.selectedItem]}
          onPress={() => onValueChange(item.value)}
        >
          <Text style={[styles.pickerText, value === item.value && styles.selectedText]}>
            {item.label}
          </Text>
        </TouchableOpacity>
      ))}
    </View>
  </View>
);

export default function CreateTicketScreen({ navigation }) {
  const [formData, setFormData] = useState({
    title: '',
    category: '',
    subcategory: '',
    priority: '',
    supportType: '',
    dueDate: '',
    contactName: '',
    phone: '',
    department: '',
    assignedTo: '',
    description: '',
  });
  
  const [loading, setLoading] = useState(false);
  const [users, setUsers] = useState([]);

  const categories = [
    { label: 'Software Issues', value: 'software_issues' },
    { label: 'Hardware Issues', value: 'hardware_issues' },
    { label: 'Network Issues', value: 'network_issues' },
    { label: 'Application Crashes', value: 'application_crashes' },
    { label: 'Others', value: 'others' },
  ];

  const getSubcategories = (category) => {
    switch (category) {
      case 'software_issues':
        return [
          { label: 'Installation', value: 'installation' },
          { label: 'Update', value: 'update' },
          { label: 'Bug', value: 'bug' },
          { label: 'License', value: 'license' },
        ];
      case 'hardware_issues':
        return [
          { label: 'Laptop', value: 'laptop' },
          { label: 'Desktop', value: 'desktop' },
          { label: 'Printer', value: 'printer' },
          { label: 'Peripheral', value: 'peripheral' },
        ];
      case 'network_issues':
        return [
          { label: 'Connectivity', value: 'connectivity' },
          { label: 'VPN', value: 'vpn' },
          { label: 'Server', value: 'server' },
          { label: 'Firewall', value: 'firewall' },
        ];
      case 'application_crashes':
        return [
          { label: 'Login', value: 'login' },
          { label: 'Performance', value: 'performance' },
          { label: 'Data Loss', value: 'data_loss' },
          { label: 'Compatibility', value: 'compatibility' },
        ];
      default:
        return [{ label: 'General', value: 'general' }];
    }
  };

  const priorities = [
    { label: 'Low', value: 'low' },
    { label: 'Medium', value: 'medium' },
    { label: 'High', value: 'high' },
  ];

  const supportTypes = [
    { label: 'Remote', value: 'remote' },
    { label: 'Onsite', value: 'onsite' },
    { label: 'Telephone', value: 'telephone' },
  ];

  const departments = [
    { label: 'IT', value: 'it' },
    { label: 'HR', value: 'hr' },
    { label: 'Finance', value: 'finance' },
    { label: 'Operations', value: 'operations' },
    { label: 'Sales', value: 'sales' },
    { label: 'Marketing', value: 'marketing' },
  ];

  useEffect(() => {
    fetchUsers();
  }, []);

  const fetchUsers = async () => {
    try {
      const { data, error } = await supabase
        .from('profiles')
        .select('id, email')
        .order('email');

      if (error) {
        console.error('Error fetching users:', error);
        return;
      }

      const userOptions = data.map(user => ({
        label: user.email,
        value: user.id,
      }));
      
      setUsers([{ label: 'Unassigned', value: '' }, ...userOptions]);
    } catch (error) {
      console.error('Error in fetchUsers:', error);
    }
  };

  const updateFormData = (field, value) => {
    setFormData(prev => ({ ...prev, [field]: value }));
    
    // Reset subcategory when category changes
    if (field === 'category') {
      setFormData(prev => ({ ...prev, subcategory: '' }));
    }
  };

  const validateForm = () => {
    if (!formData.title.trim()) {
      Alert.alert('Validation Error', 'Please enter a ticket title');
      return false;
    }
    if (!formData.category) {
      Alert.alert('Validation Error', 'Please select a category');
      return false;
    }
    if (!formData.priority) {
      Alert.alert('Validation Error', 'Please select a priority');
      return false;
    }
    if (!formData.supportType) {
      Alert.alert('Validation Error', 'Please select a support type');
      return false;
    }
    if (!formData.contactName.trim()) {
      Alert.alert('Validation Error', 'Please enter contact name');
      return false;
    }
    if (!formData.department) {
      Alert.alert('Validation Error', 'Please select a department');
      return false;
    }
    if (!formData.description.trim()) {
      Alert.alert('Validation Error', 'Please enter a description');
      return false;
    }
    return true;
  };

  const handleSubmit = async () => {
    if (!validateForm()) return;

    setLoading(true);
    try {
      const { data: { user } } = await supabase.auth.getUser();
      
      const ticketData = {
        title: formData.title.trim(),
        category: formData.category,
        subcategory: formData.subcategory || null,
        priority: formData.priority,
        support_type: formData.supportType,
        due_date: formData.dueDate || null,
        contact_name: formData.contactName.trim(),
        phone: formData.phone.trim() || null,
        department: formData.department,
        assigned_to: formData.assignedTo || null,
        description: formData.description.trim(),
        created_by: user.id,
        status: 'open',
      };

      const { error } = await supabase
        .from('tickets')
        .insert([ticketData]);

      if (error) {
        console.error('Error creating ticket:', error);
        Alert.alert('Error', 'Failed to create ticket. Please try again.');
        return;
      }

      Alert.alert(
        'Success', 
        'Ticket created successfully!',
        [
          {
            text: 'OK',
            onPress: () => {
              // Reset form
              setFormData({
                title: '',
                category: '',
                subcategory: '',
                priority: '',
                supportType: '',
                dueDate: '',
                contactName: '',
                phone: '',
                department: '',
                assignedTo: '',
                description: '',
              });
              // Navigate to All Tickets
              navigation.navigate('AllTickets');
            }
          }
        ]
      );
    } catch (error) {
      console.error('Error in handleSubmit:', error);
      Alert.alert('Error', 'An unexpected error occurred');
    } finally {
      setLoading(false);
    }
  };

  return (
    <SafeAreaView style={styles.container}>
      <View style={styles.header}>
        <Text style={styles.headerTitle}>Create New Ticket</Text>
      </View>
      
      <ScrollView style={styles.formContainer} showsVerticalScrollIndicator={false}>
        <View style={styles.inputContainer}>
          <Text style={styles.label}>Ticket Title *</Text>
          <TextInput
            style={styles.input}
            value={formData.title}
            onChangeText={(text) => updateFormData('title', text)}
            placeholder="Enter ticket title"
            multiline={false}
          />
        </View>

        <DropdownPicker
          label="Category *"
          value={formData.category}
          onValueChange={(value) => updateFormData('category', value)}
          items={categories}
          placeholder="Select category"
        />

        {formData.category && (
          <DropdownPicker
            label="Subcategory"
            value={formData.subcategory}
            onValueChange={(value) => updateFormData('subcategory', value)}
            items={getSubcategories(formData.category)}
            placeholder="Select subcategory"
          />
        )}

        <DropdownPicker
          label="Priority *"
          value={formData.priority}
          onValueChange={(value) => updateFormData('priority', value)}
          items={priorities}
          placeholder="Select priority"
        />

        <DropdownPicker
          label="Support Type *"
          value={formData.supportType}
          onValueChange={(value) => updateFormData('supportType', value)}
          items={supportTypes}
          placeholder="Select support type"
        />

        <View style={styles.inputContainer}>
          <Text style={styles.label}>Due Date (Optional)</Text>
          <TextInput
            style={styles.input}
            value={formData.dueDate}
            onChangeText={(text) => updateFormData('dueDate', text)}
            placeholder="YYYY-MM-DD"
          />
        </View>

        <View style={styles.inputContainer}>
          <Text style={styles.label}>Contact Name *</Text>
          <TextInput
            style={styles.input}
            value={formData.contactName}
            onChangeText={(text) => updateFormData('contactName', text)}
            placeholder="Enter contact name"
          />
        </View>

        <View style={styles.inputContainer}>
          <Text style={styles.label}>Phone</Text>
          <TextInput
            style={styles.input}
            value={formData.phone}
            onChangeText={(text) => updateFormData('phone', text)}
            placeholder="Enter phone number"
            keyboardType="phone-pad"
          />
        </View>

        <DropdownPicker
          label="Department *"
          value={formData.department}
          onValueChange={(value) => updateFormData('department', value)}
          items={departments}
          placeholder="Select department"
        />

        <DropdownPicker
          label="Assign to Agent/Admin"
          value={formData.assignedTo}
          onValueChange={(value) => updateFormData('assignedTo', value)}
          items={users}
          placeholder="Select assignee"
        />

        <View style={styles.inputContainer}>
          <Text style={styles.label}>Description *</Text>
          <TextInput
            style={[styles.input, styles.textArea]}
            value={formData.description}
            onChangeText={(text) => updateFormData('description', text)}
            placeholder="Enter detailed description"
            multiline={true}
            numberOfLines={4}
            textAlignVertical="top"
          />
        </View>

        <TouchableOpacity
          style={[styles.submitButton, loading && styles.disabledButton]}
          onPress={handleSubmit}
          disabled={loading}
        >
          <Text style={styles.submitButtonText}>
            {loading ? 'Creating Ticket...' : 'Create Ticket'}
          </Text>
        </TouchableOpacity>

        <View style={{ height: 50 }} />
      </ScrollView>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#f5f7fa',
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
  },
  formContainer: {
    flex: 1,
    padding: 20,
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
    borderRadius: 8,
    paddingHorizontal: 15,
    paddingVertical: 12,
    fontSize: 16,
    backgroundColor: 'white',
  },
  textArea: {
    height: 100,
    textAlignVertical: 'top',
  },
  dropdownContainer: {
    marginBottom: 20,
  },
  pickerContainer: {
    backgroundColor: 'white',
    borderWidth: 1,
    borderColor: '#ddd',
    borderRadius: 8,
  },
  pickerItem: {
    padding: 15,
    borderBottomWidth: 1,
    borderBottomColor: '#f0f0f0',
  },
  selectedItem: {
    backgroundColor: '#e8f5e8',
  },
  pickerText: {
    fontSize: 16,
    color: '#333',
  },
  selectedText: {
    color: '#4CAF50',
    fontWeight: '500',
  },
  submitButton: {
    backgroundColor: '#4CAF50',
    paddingVertical: 15,
    borderRadius: 10,
    alignItems: 'center',
    marginTop: 20,
  },
  disabledButton: {
    backgroundColor: '#ccc',
  },
  submitButtonText: {
    color: 'white',
    fontSize: 18,
    fontWeight: 'bold',
  },
});