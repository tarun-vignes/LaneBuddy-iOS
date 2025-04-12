/**
 * SafetyWarningModal Component
 * 
 * A modal component that displays important safety information to users
 * before they start using the navigation features. This ensures users
 * understand the importance of safe driving and proper app usage.
 * 
 * Features:
 * - Clear safety guidelines
 * - Persistent acceptance tracking
 * - Accessible design
 * - One-time display with AsyncStorage persistence
 */

import React from 'react';
import {
  Modal,
  StyleSheet,
  Text,
  View,
  TouchableOpacity,
  ScrollView,
} from 'react-native';
import { MaterialIcons } from '@expo/vector-icons';
import AsyncStorage from '@react-native-async-storage/async-storage';

/**
 * Props interface for the SafetyWarningModal component
 * 
 * @property visible - Controls the visibility of the modal
 * @property onAccept - Callback function when user accepts the safety guidelines
 */
interface SafetyWarningModalProps {
  visible: boolean;
  onAccept: () => void;
}

/**
 * Modal component that displays driving safety guidelines and warnings.
 * Shows only once to new users and stores acceptance in AsyncStorage.
 * 
 * @component
 * @param {SafetyWarningModalProps} props - Component props
 * @returns {JSX.Element} The safety warning modal component
 */
const SafetyWarningModal: React.FC<SafetyWarningModalProps> = ({ visible, onAccept }) => {
  /**
   * Handles the user's acceptance of safety guidelines.
   * Stores acceptance in AsyncStorage and triggers the onAccept callback.
   */
  const handleAccept = async () => {
    try {
      await AsyncStorage.setItem('safetyWarningAccepted', 'true');
      onAccept();
    } catch (error) {
      console.error('Error saving safety warning acceptance:', error);
    }
  };

  return (
    <Modal
      animationType="slide"
      transparent={true}
      visible={visible}
      onRequestClose={() => {}}
    >
      <View style={styles.centeredView}>
        <View style={styles.modalView}>
          <MaterialIcons name="warning" size={48} color="#FFB700" />
          
          <Text style={styles.modalTitle}>Safety First!</Text>
          
          <ScrollView style={styles.scrollView}>
            <Text style={styles.warningText}>
              ⚠️ IMPORTANT SAFETY INFORMATION
            </Text>
            
            <Text style={styles.modalText}>
              • Always follow local traffic laws and regulations
            </Text>
            
            <Text style={styles.modalText}>
              • Keep your eyes on the road and hands on the wheel
            </Text>
            
            <Text style={styles.modalText}>
              • This app is designed to assist, not replace, your judgment
            </Text>
            
            <Text style={styles.modalText}>
              • Pull over safely if you need to interact with the app
            </Text>
            
            <Text style={styles.modalText}>
              • Weather and road conditions may affect suggested lane guidance
            </Text>
            
            <Text style={styles.modalText}>
              • Stay alert and be prepared for unexpected traffic situations
            </Text>
            
            <Text style={styles.disclaimer}>
              By proceeding, you acknowledge these safety guidelines and agree to use this app responsibly.
            </Text>
          </ScrollView>

          <TouchableOpacity
            style={styles.acceptButton}
            onPress={handleAccept}
          >
            <Text style={styles.acceptButtonText}>I Understand and Accept</Text>
          </TouchableOpacity>
        </View>
      </View>
    </Modal>
  );
};

const styles = StyleSheet.create({
  centeredView: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: 'rgba(0, 0, 0, 0.5)',
  },
  modalView: {
    margin: 20,
    backgroundColor: 'white',
    borderRadius: 20,
    padding: 25,
    alignItems: 'center',
    shadowColor: '#000',
    shadowOffset: {
      width: 0,
      height: 2,
    },
    shadowOpacity: 0.25,
    shadowRadius: 4,
    elevation: 5,
    width: '90%',
    maxHeight: '80%',
  },
  scrollView: {
    width: '100%',
    marginVertical: 15,
  },
  modalTitle: {
    marginVertical: 15,
    textAlign: 'center',
    fontSize: 24,
    fontWeight: 'bold',
    color: '#000',
  },
  warningText: {
    fontSize: 18,
    fontWeight: 'bold',
    color: '#FF6B6B',
    textAlign: 'center',
    marginBottom: 15,
  },
  modalText: {
    marginBottom: 15,
    textAlign: 'left',
    fontSize: 16,
    color: '#333',
    lineHeight: 22,
  },
  disclaimer: {
    marginTop: 10,
    textAlign: 'center',
    fontSize: 14,
    color: '#666',
    fontStyle: 'italic',
  },
  acceptButton: {
    backgroundColor: '#4CAF50',
    borderRadius: 10,
    padding: 15,
    width: '100%',
    marginTop: 15,
  },
  acceptButtonText: {
    color: 'white',
    fontWeight: 'bold',
    textAlign: 'center',
    fontSize: 16,
  },
});
