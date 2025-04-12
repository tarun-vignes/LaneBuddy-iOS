/**
 * LocationService
 * 
 * Handles all location-related functionality including:
 * - Location permissions
 * - Real-time location updates
 * - Location accuracy settings
 * - Background location tracking
 */

import * as Location from 'expo-location';
import { Platform } from 'react-native';

export interface LocationState {
  latitude: number;
  longitude: number;
  heading: number | null;
  speed: number | null;
  accuracy: number | null;
  timestamp: number;
}

class LocationService {
  private static instance: LocationService;
  private locationSubscription: Location.LocationSubscription | null = null;

  private constructor() {}

  public static getInstance(): LocationService {
    if (!LocationService.instance) {
      LocationService.instance = new LocationService();
    }
    return LocationService.instance;
  }

  /**
   * Request location permissions from the user
   * @returns Promise<boolean> - Whether permissions were granted
   */
  public async requestPermissions(): Promise<boolean> {
    try {
      const { status: foregroundStatus } = await Location.requestForegroundPermissionsAsync();
      if (foregroundStatus !== 'granted') {
        return false;
      }

      // Request background permissions if on iOS
      if (Platform.OS === 'ios') {
        const { status: backgroundStatus } = await Location.requestBackgroundPermissionsAsync();
        if (backgroundStatus !== 'granted') {
          return false;
        }
      }

      return true;
    } catch (error) {
      console.error('Error requesting location permissions:', error);
      return false;
    }
  }

  /**
   * Start watching the user's location with high accuracy
   * @param onLocationUpdate - Callback for location updates
   * @param onError - Callback for errors
   */
  public async startLocationUpdates(
    onLocationUpdate: (location: LocationState) => void,
    onError?: (error: any) => void
  ): Promise<void> {
    try {
      // Check if we already have a subscription
      if (this.locationSubscription) {
        await this.stopLocationUpdates();
      }

      // Configure location tracking
      await Location.setActivityType(Location.ActivityType.AutomotiveNavigation);
      await Location.enableNetworkProviderAsync();

      // Start location updates
      this.locationSubscription = await Location.watchPositionAsync(
        {
          accuracy: Location.Accuracy.BestForNavigation,
          distanceInterval: 5, // Update every 5 meters
          timeInterval: 1000, // Update every second
        },
        (location) => {
          const locationState: LocationState = {
            latitude: location.coords.latitude,
            longitude: location.coords.longitude,
            heading: location.coords.heading || null,
            speed: location.coords.speed || null,
            accuracy: location.coords.accuracy || null,
            timestamp: location.timestamp,
          };
          onLocationUpdate(locationState);
        }
      );
    } catch (error) {
      console.error('Error starting location updates:', error);
      onError?.(error);
    }
  }

  /**
   * Stop watching the user's location
   */
  public async stopLocationUpdates(): Promise<void> {
    if (this.locationSubscription) {
      this.locationSubscription.remove();
      this.locationSubscription = null;
    }
  }

  /**
   * Get the current location once
   * @returns Promise<LocationState>
   */
  public async getCurrentLocation(): Promise<LocationState> {
    try {
      const location = await Location.getCurrentPositionAsync({
        accuracy: Location.Accuracy.BestForNavigation,
      });

      return {
        latitude: location.coords.latitude,
        longitude: location.coords.longitude,
        heading: location.coords.heading || null,
        speed: location.coords.speed || null,
        accuracy: location.coords.accuracy || null,
        timestamp: location.timestamp,
      };
    } catch (error) {
      console.error('Error getting current location:', error);
      throw error;
    }
  }
}

export default LocationService.getInstance();
