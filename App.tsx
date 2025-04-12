/**
 * LaneBuddy - A next-generation navigation app
 * 
 * This is the main application component that sets up the navigation structure
 * and theme for the entire app. It uses React Navigation's bottom tab navigator
 * to provide easy access to the main features: navigation, saved routes, and settings.
 * 
 * Key Features:
 * - Bottom tab navigation for intuitive user experience
 * - Integration with Google Maps for real-time navigation
 * - Safety-first approach with built-in warnings
 * - Gesture handling for smooth user interactions
 * - Safe area support for modern device compatibility
 * 
 * @author Tarun Vignes
 * @version 1.0.0
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

/**
 * Initialize the bottom tab navigator with TypeScript type safety.
 * RootStackParamList defines the available screens and their parameters.
 */
const Tab = createBottomTabNavigator<RootStackParamList>();

/**
 * Custom theme configuration for the navigation container.
 * Extends the default theme with our brand colors and styling.
 */
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

/**
 * Main application component that sets up the app's navigation structure
 * and provides necessary context providers for features like gestures and safe areas.
 * 
 * The component hierarchy is:
 * - GestureHandlerRootView (for gesture support)
 * - SafeAreaProvider (for safe area insets)
 * - NavigationContainer (for routing)
 * - Tab.Navigator (for bottom tab navigation)
 * 
 * @returns {JSX.Element} The root component of the application
 */
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
