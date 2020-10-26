import { NativeModules } from 'react-native';

export interface Workout {
  uuid: string;
  startDate: string;
  endDate: string;
  activityName: string;
  distance: number;
  duration: number;
}

type HealthkitType = {
  requestPermissions(): Promise<boolean>;
  getWorkouts(): Promise<Workout[]>;
};

const { Healthkit } = NativeModules;

export default Healthkit as HealthkitType;
