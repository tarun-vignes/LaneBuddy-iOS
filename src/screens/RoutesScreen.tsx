import React from 'react';
import { StyleSheet, View, Text, FlatList } from 'react-native';

const dummyRoutes = [
  { id: '1', name: 'Home to Work', frequency: '5 times/week' },
  { id: '2', name: 'Home to Gym', frequency: '3 times/week' },
  { id: '3', name: 'Work to Shopping Mall', frequency: 'Occasional' },
];

export default function RoutesScreen() {
  return (
    <View style={styles.container}>
      <FlatList
        data={dummyRoutes}
        keyExtractor={(item) => item.id}
        renderItem={({ item }) => (
          <View style={styles.routeItem}>
            <Text style={styles.routeName}>{item.name}</Text>
            <Text style={styles.routeFrequency}>{item.frequency}</Text>
          </View>
        )}
      />
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#fff',
  },
  routeItem: {
    padding: 20,
    borderBottomWidth: 1,
    borderBottomColor: '#eee',
  },
  routeName: {
    fontSize: 18,
    fontWeight: 'bold',
  },
  routeFrequency: {
    fontSize: 14,
    color: '#666',
    marginTop: 5,
  },
});
