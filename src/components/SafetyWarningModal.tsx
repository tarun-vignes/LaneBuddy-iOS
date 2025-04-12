import React from 'react';
import {
  Modal,
  View,
  Text,
  StyleSheet,
  TouchableOpacity,
  ScrollView,
} from 'react-native';
import { MaterialIcons } from '@expo/vector-icons';

interface SafetyWarningModalProps {
  visible: boolean;
  onAccept: () => void;
}

export default function SafetyWarningModal({ visible, onAccept }: SafetyWarningModalProps) {
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
            onPress={onAccept}
          >
            <Text style={styles.acceptButtonText}>I Understand and Accept</Text>
          </TouchableOpacity>
        </View>
      </View>
    </Modal>
  );
}

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
