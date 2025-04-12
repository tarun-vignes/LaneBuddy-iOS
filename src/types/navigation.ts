/**
 * Navigation type definitions for LaneBuddy
 * 
 * This file contains TypeScript type definitions for the app's navigation system.
 * It ensures type safety when navigating between screens and handling navigation props.
 */

import type { BottomTabScreenProps } from '@react-navigation/bottom-tabs';

/**
 * Defines the available screens in the app and their parameters.
 * Each screen is mapped to its route parameters (if any).
 * 
 * @property Navigate - Main navigation screen with map view
 * @property Routes - List of saved routes
 * @property Settings - App configuration and user preferences
 */
export type RootStackParamList = {
  Navigate: undefined;
  Routes: undefined;
  Settings: undefined;
};

/**
 * Type for navigation props used in screen components.
 * Combines the bottom tab navigation props with our custom param list.
 */
export type NavigationProps = BottomTabScreenProps<RootStackParamList>;

/**
 * Extends the global ReactNavigation namespace to include our param list.
 * This enables proper type checking throughout the navigation system.
 */
declare global {
  namespace ReactNavigation {
    interface RootParamList extends RootStackParamList {}
  }
};
