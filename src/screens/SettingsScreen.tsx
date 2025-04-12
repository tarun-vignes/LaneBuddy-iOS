/**
 * SettingsScreen Component
 * 
 * Allows users to customize their navigation preferences and app settings.
 * This screen provides various options to personalize the navigation experience
 * and manage app-wide configurations.
 * 
 * Features:
 * - Navigation preferences
 * - Voice guidance settings
 * - Map display options
 * - Privacy settings
 * - Data management
 */

import React, { useState } from 'react';
import { StyleSheet, View, Text, Switch } from 'react-native';

/**
 * Settings screen component for app configuration and preferences.
 * 
 * @component
 * @param {NavigationProps} props - Navigation props from React Navigation
 * @returns {JSX.Element} The settings screen component
 */
export default function SettingsScreen() {
  /**
   * State variable to store the user's preference for avoiding highways.
   * 
   * @type {boolean}
   */
  const [avoidHighways, setAvoidHighways] = useState(false);

  /**
   * State variable to store the user's preference for avoiding tolls.
   * 
   * @type {boolean}
   */
  const [avoidTolls, setAvoidTolls] = useState(false);

  /**
   * State variable to store the user's preference for enabling voice guidance.
   * 
   * @type {boolean}
   */
  const [voiceEnabled, setVoiceEnabled] = useState(true);

  /**
   * State variable to store the user's preference for enabling vibration.
   * 
   * @type {boolean}
   */
  const [vibrationEnabled, setVibrationEnabled] = useState(true);

  return (
    /**
     * Container view for the settings screen.
     * 
     * @type {JSX.Element}
     */
    <View style={styles.container}>
      /**
       * Section view for navigation preferences.
       * 
       * @type {JSX.Element}
       */
      <View style={styles.section}>
        <Text style={styles.sectionTitle}>Navigation Preferences</Text>
        <View style={styles.setting}>
          <Text>Avoid Highways</Text>
          <Switch value={avoidHighways} onValueChange={setAvoidHighways} />
        </View>
        <View style={styles.setting}>
          <Text>Avoid Tolls</Text>
          <Switch value={avoidTolls} onValueChange={setAvoidTolls} />
        </View>
      </View>

      <View style={styles.section}>
        <Text style={styles.sectionTitle}>Notifications</Text>
        <View style={styles.setting}>
          <Text>Voice Guidance</Text>
          <Switch value={voiceEnabled} onValueChange={setVoiceEnabled} />
        </View>
        <View style={styles.setting}>
          <Text>Vibration</Text>
          <Switch value={vibrationEnabled} onValueChange={setVibrationEnabled} />
        </View>
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#fff',
    padding: 20,
  },
  section: {
    marginBottom: 30,
  },
  sectionTitle: {
    fontSize: 20,
    fontWeight: 'bold',
    marginBottom: 15,
  },
  setting: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    paddingVertical: 10,
    borderBottomWidth: 1,
    borderBottomColor: '#eee',
  },
});
