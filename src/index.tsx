import { NativeModules } from 'react-native';

type HealthkitType = {
  multiply(a: number, b: number): Promise<number>;
};

const { Healthkit } = NativeModules;

export default Healthkit as HealthkitType;
