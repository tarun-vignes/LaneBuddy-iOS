/**
 * LaneBuddy - A next-generation navigation app
 * 
 * This is the main application component that sets up the navigation structure
 * and theme for the entire app. It uses React Navigation's bottom tab navigator
 * to provide easy access to the main features: navigation, saved routes, and settings.
 * 
 * The app follows a safety-first approach with built-in warnings and guidelines
 * to ensure responsible use while driving.
 */

import React from 'react';
import { NavigationContainer, DefaultTheme } from '@react-navigation/native';
import { createBottomTabNavigator } from '@react-navigation/bottom-tabs';
import type { BottomTabNavigationOptions } from '@react-navigation/bottom-tabs';
import { MaterialIcons } from '@expo/vector-icons';
import { SafeAreaProvider } from 'react-native-safe-area-context';
import { GestureHandlerRootView } from 'react-native-gesture-handler';
import type { RootStackParamList } from './src/types/navigation';

// Screens
import NavigationScreen from './src/screens/NavigationScreen';
import RoutesScreen from './src/screens/RoutesScreen';
import SettingsScreen from './src/screens/SettingsScreen';

// Initialize the bottom tab navigator with type safety
const Tab = createBottomTabNavigator<RootStackParamList>();

// Custom theme that matches the app's design language
const navigationTheme = {
  ...DefaultTheme,
  colors: {
    ...DefaultTheme.colors,
    primary: '#007AFF',
    background: '#fff',
  },
};

// Default options for all tab screens
const screenOptions: BottomTabNavigationOptions = {
  tabBarActiveTintColor: '#007AFF',
  tabBarInactiveTintColor: 'gray',
  headerShown: true,
};

export default function App() {
  return (
    <GestureHandlerRootView style={{ flex: 1 }}>
      <SafeAreaProvider>
        <NavigationContainer theme={navigationTheme}>
          <Tab.Navigator screenOptions={screenOptions}>
            <Tab.Screen 
              name="Navigate" 
              component={NavigationScreen}
              options={{
                tabBarIcon: ({ color }) => (
                  <MaterialIcons name="map" color={color} size={26} />
                ),
              }}
            />
            <Tab.Screen 
              name="Routes" 
              component={RoutesScreen}
              options={{
                tabBarIcon: ({ color }) => (
                  <MaterialIcons name="list" color={color} size={26} />
                ),
              }}
            />
            <Tab.Screen 
              name="Settings" 
              component={SettingsScreen}
              options={{
                tabBarIcon: ({ color }) => (
                  <MaterialIcons name="settings" color={color} size={26} />
                ),
              }}
            />
          </Tab.Navigator>
        </NavigationContainer>
      </SafeAreaProvider>
    </GestureHandlerRootView>
  );
}
