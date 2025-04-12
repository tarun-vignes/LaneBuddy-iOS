import type { BottomTabScreenProps } from '@react-navigation/bottom-tabs';

export type RootStackParamList = {
  Navigate: undefined;
  Routes: undefined;
  Settings: undefined;
};

export type NavigationProps = BottomTabScreenProps<RootStackParamList>;

declare global {
  namespace ReactNavigation {
    interface RootParamList extends RootStackParamList {}
  }
};
