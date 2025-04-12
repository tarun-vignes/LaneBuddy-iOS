import React, { useState } from 'react';
import { StyleSheet, View, Text, Switch } from 'react-native';

export default function SettingsScreen() {
  const [avoidHighways, setAvoidHighways] = useState(false);
  const [avoidTolls, setAvoidTolls] = useState(false);
  const [voiceEnabled, setVoiceEnabled] = useState(true);
  const [vibrationEnabled, setVibrationEnabled] = useState(true);

  return (
    <View style={styles.container}>
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
