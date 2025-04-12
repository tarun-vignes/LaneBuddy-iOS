import React, { useState, useEffect } from 'react';
import { StyleSheet, View } from 'react-native';
import MapView from 'react-native-maps';
import AsyncStorage from '@react-native-async-storage/async-storage';
import SafetyWarningModal from '../components/SafetyWarningModal';

export default function NavigationScreen() {
  const [showSafetyWarning, setShowSafetyWarning] = useState(false);

  useEffect(() => {
    checkSafetyWarning();
  }, []);

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
