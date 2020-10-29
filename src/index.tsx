import { NativeModules } from 'react-native';

export enum WorkoutActivityType {
  americanFootball = 'americanFootball',
  archery = 'archery',
  australianFootball = 'australianFootball',
  badminton = 'badminton',
  barre = 'barre',
  baseball = 'baseball',
  basketball = 'basketball',
  bowling = 'bowling',
  boxing = 'boxing',
  cardioDance = 'cardioDance',
  climbing = 'climbing',
  cooldown = 'cooldown',
  coreTraining = 'coreTraining',
  cricket = 'cricket',
  crossCountrySkiing = 'crossCountrySkiing',
  crossTraining = 'crossTraining',
  curling = 'curling',
  cycling = 'cycling',
  dance = 'dance',
  danceInspiredTraining = 'danceInspiredTraining',
  discSports = 'discSports',
  downhillSkiing = 'downhillSkiing',
  elliptical = 'elliptical',
  equestrianSports = 'equestrianSports',
  fencing = 'fencing',
  fishing = 'fishing',
  fitnessGaming = 'fitnessGaming',
  flexibility = 'flexibility',
  functionalStrengthTraining = 'functionalStrengthTraining',
  golf = 'golf',
  gymnastics = 'gymnastics',
  handCycling = 'handCycling',
  handball = 'handball',
  highIntensityIntervalTraining = 'highIntensityIntervalTraining',
  hiking = 'hiking',
  hockey = 'hockey',
  hunting = 'hunting',
  jumpRope = 'jumpRope',
  kickboxing = 'kickboxing',
  lacrosse = 'lacrosse',
  martialArts = 'martialArts',
  mindAndBody = 'mindAndBody',
  mixedCardio = 'mixedCardio',
  mixedMetabolicCardioTraining = 'mixedMetabolicCardioTraining',
  other = 'other',
  paddleSports = 'paddleSports',
  pickleball = 'pickleball',
  pilates = 'pilates',
  play = 'play',
  preparationAndRecovery = 'preparationAndRecovery',
  racquetball = 'racquetball',
  rowing = 'rowing',
  rugby = 'rugby',
  running = 'running',
  sailing = 'sailing',
  skatingSports = 'skatingSports',
  snowSports = 'snowSports',
  snowboarding = 'snowboarding',
  soccer = 'soccer',
  socialDance = 'socialDance',
  softball = 'softball',
  squash = 'squash',
  stairClimbing = 'stairClimbing',
  stairs = 'stairs',
  stepTraining = 'stepTraining',
  surfingSports = 'surfingSports',
  swimming = 'swimming',
  tableTennis = 'tableTennis',
  taiChi = 'taiChi',
  tennis = 'tennis',
  trackAndField = 'trackAndField',
  traditionalStrengthTraining = 'traditionalStrengthTraining',
  volleyball = 'volleyball',
  walking = 'walking',
  waterFitness = 'waterFitness',
  waterPolo = 'waterPolo',
  waterSports = 'waterSports',
  wheelchairRunPace = 'wheelchairRunPace',
  wheelchairWalkPace = 'wheelchairWalkPace',
  wrestling = 'wrestling',
  yoga = 'yoga',
}

export interface CLLocationCoordinate {
  /** The latitude in degrees. */
  latitude: number;
  /** The longitude in degrees. */
  longitude: number;
}

export interface CLLocation {
  /** The coordinates for the locations */
  coordinate: CLLocationCoordinate;
  /** Timestamp as an ISO8601 string */
  timestamp: string;
  /** The horizontal accuracy of the location. Negative if the lateral location is invalid. */
  horizontalAccuracy: number;
  /** The vertical accuracy of the location. Negative if the altitude is invalid */
  verticalAccuracy: number;
  /** The speed of the location in m/s. Negative if speed is invalid. */
  speed: number;
  /** The course of the location in degrees true North. Negative if course is invalid. */
  course: number;
  /** The altitude of the location in degrees true North. Negative if course is invalid. */
  altitude: number;
  /** The logical floor that you are on in the current building if you are inside a supported venue. */
  floor?: number;
}

export interface WorkoutRoute {
  /** Unique identifier for the workout route */
  uuid: string;
  /** Start date as an ISO8601 string */
  startDate: string;
  /** End date as an ISO8601 string */
  endDate: string;
  /** List of associated locations for the workout route */
  locations?: CLLocation[];
}
export interface Workout {
  /** Unique identifier for the workout */
  uuid: string;
  /** Start date as an ISO8601 string */
  startDate: string;
  /** End date as an ISO8601 string */
  endDate: string;
  /** Activity type for the workout */
  workoutActivityType: WorkoutActivityType;
  /** Total distance in meters */
  totalDistance: number;
  /** Duration in seconds */
  duration: number;
  /** List of associated routes for the workout */
  routes?: WorkoutRoute[];
}

export interface WorkoutQuery {
  /** Start time in milliseconds */
  startDate?: number;
  /** End time in milliseconds */
  endDate?: number;
}

type HealthkitType = {
  requestPermissions(): Promise<boolean>;
  getWorkouts(input: WorkoutQuery): Promise<Workout[]>;
};

const { Healthkit } = NativeModules;

export default Healthkit as HealthkitType;
