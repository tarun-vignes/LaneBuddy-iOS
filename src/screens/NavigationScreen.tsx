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
import { StyleSheet, View, Alert } from 'react-native';
import MapView, { Marker, PROVIDER_GOOGLE } from 'react-native-maps';
import AsyncStorage from '@react-native-async-storage/async-storage';
import SafetyWarningModal from '../components/SafetyWarningModal';
import LocationService, { LocationState } from '../services/LocationService';

/**
 * Main navigation screen component that handles map display and user interaction.
 * 
 * @component
 * @param {NavigationProps} props - Navigation props from React Navigation
 * @returns {JSX.Element} The navigation screen component
 */
export default function NavigationScreen() {
  const [showSafetyWarning, setShowSafetyWarning] = useState(false);
  const [location, setLocation] = useState<LocationState | null>(null);
  const [hasLocationPermission, setHasLocationPermission] = useState(false);

  /**
   * Initialize location services and request permissions
   */
  const initializeLocation = async () => {
    try {
      const hasPermission = await LocationService.requestPermissions();
      setHasLocationPermission(hasPermission);

      if (hasPermission) {
        // Start location updates
        await LocationService.startLocationUpdates(
          (newLocation) => {
            setLocation(newLocation);
          },
          (error) => {
            Alert.alert('Location Error', 'Unable to get your location. Please check your GPS settings.');
          }
        );

        // Get initial location
        const currentLocation = await LocationService.getCurrentLocation();
        setLocation(currentLocation);
      } else {
        Alert.alert(
          'Location Permission Required',
          'LaneBuddy needs access to your location for navigation. Please enable it in your settings.'
        );
      }
    } catch (error) {
      console.error('Error initializing location:', error);
      Alert.alert('Error', 'Failed to initialize location services');
    }
  };

  // Request location permissions and initialize location tracking
  useEffect(() => {
    initializeLocation();
    checkSafetyWarning();
    return () => {
      // Cleanup location subscription when component unmounts
      LocationService.stopLocationUpdates();
    };
  }, []);

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
        provider={PROVIDER_GOOGLE}
        showsUserLocation
        followsUserLocation
        region={location ? {
          latitude: location.latitude,
          longitude: location.longitude,
          latitudeDelta: 0.01,
          longitudeDelta: 0.01,
        } : {
          latitude: 37.78825,
          longitude: -122.4324,
          latitudeDelta: 0.0922,
          longitudeDelta: 0.0421,
        }}
      >
        {location && (
          <Marker
            coordinate={{
              latitude: location.latitude,
              longitude: location.longitude,
            }}
            title="You are here"
            description={`Heading: ${location.heading}°, Speed: ${location.speed} m/s`}
          />
        )}
      </MapView>

      <SafetyWarningModal
        visible={showSafetyWarning}
        onAccept={() => setShowSafetyWarning(false)}
      />
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  map: {
    flex: 1,
  },
});
