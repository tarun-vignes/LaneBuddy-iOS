/**
 * NavigationScreen Component
 * 
 * This is the main navigation screen of the LaneBuddy app. It displays a Google Maps view
 * and provides real-time navigation features with lane-level guidance.
 * 
 * Features:
 * - Interactive Google Maps integration
 * - Real-time location tracking
 * - Safety warning modal for first-time users
 * - Lane-level navigation guidance
 * - Voice instructions (to be implemented)
 */

import React, { useState, useEffect } from 'react';
import { StyleSheet, View } from 'react-native';
import MapView from 'react-native-maps';
import AsyncStorage from '@react-native-async-storage/async-storage';
import SafetyWarningModal from '../components/SafetyWarningModal';

/**
 * Main navigation screen component that handles map display and user interaction.
 * 
 * @component
 * @param {NavigationProps} props - Navigation props from React Navigation
 * @returns {JSX.Element} The navigation screen component
 */
export default function NavigationScreen() {
  // State to control the visibility of the safety warning modal
  const [showSafetyWarning, setShowSafetyWarning] = useState(false);

  /**
   * Initial region for the map view, centered on a default location
   * TODO: Update this to user's current location
   */

  /**
   * Effect hook to check if the safety warning has been shown before.
   * Shows the warning modal to first-time users.
   */
  useEffect(() => {
    checkSafetyWarning();
  }, []);

  /**
   * Checks AsyncStorage to determine if the safety warning has been shown before.
   * If not, displays the warning modal to the user.
   */
  const checkSafetyWarning = async () => {
    try {
      const hasAccepted = await AsyncStorage.getItem('safetyWarningAccepted');
      if (!hasAccepted) {
        setShowSafetyWarning(true);
      }
    } catch (error) {
      setShowSafetyWarning(true);
    }
  };

  const handleAcceptSafety = async () => {
    try {
      await AsyncStorage.setItem('safetyWarningAccepted', 'true');
      setShowSafetyWarning(false);
    } catch (error) {
      console.error('Error saving safety acceptance:', error);
    }
  };

  return (
    <View style={styles.container}>
      <MapView
        style={styles.map}
        initialRegion={{
          latitude: 37.78825,
          longitude: -122.4324,
          latitudeDelta: 0.0922,
          longitudeDelta: 0.0421,
        }}
      />
      <SafetyWarningModal
        visible={showSafetyWarning}
        onAccept={handleAcceptSafety}
      />
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  map: {
    width: '100%',
    height: '100%',
  },
});
