import * as React from 'react';
import { SafeAreaView, ScrollView, StyleSheet, Text, View } from 'react-native';
import Healthkit, { Workout } from 'react-native-healthkit';

export default function App() {
  const [status, setStatus] = React.useState<string>();
  const [workouts, setWorkouts] = React.useState<Workout[]>();

  React.useEffect(() => {
    setStatus('Checking Permissions...');
    Healthkit.requestPermissions()
      .then(async (success) => {
        if (success) {
          setStatus('Getting workouts...');
          return Healthkit.getWorkouts().then((items) => {
            console.log(JSON.stringify(items));
            setStatus('Workouts: ' + items.length);
            setWorkouts(items);
          });
        } else {
          setStatus('Permission Denied');
        }
      })
      .catch((e: Error) => {
        setStatus('Error:' + e.message);
      });
  }, []);

  return (
    <SafeAreaView style={styles.container}>
      <Text style={styles.statusText}>{status}</Text>
      <ScrollView style={styles.workoutContainer}>
        {workouts
          ?.filter((item) => item.distance > 0 && item.duration > 0)
          ?.map((item) => {
            return (
              <View key={item.uuid} style={styles.workoutRow}>
                <View style={styles.dateColumn}>
                  <Text numberOfLines={1} ellipsizeMode="tail">
                    {item.startDate}
                  </Text>
                  <Text numberOfLines={1} ellipsizeMode="tail">
                    {item.endDate}
                  </Text>
                </View>
                <Text style={styles.durationColumn}>
                  {(item.duration / 60).toFixed(0) + ' mins'}
                </Text>
                <Text style={styles.distanceColumn}>
                  {(item.distance / 1000).toFixed(2) + ' km'}
                </Text>
              </View>
            );
          })}
      </ScrollView>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
  },
  statusText: { paddingVertical: 12 },
  workoutContainer: { width: '100%' },
  workoutRow: {
    width: '100%',
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'flex-end',
    padding: 6,
  },
  dateColumn: { flex: 3, paddingHorizontal: 6 },
  durationColumn: { flex: 1, textAlign: 'right', paddingHorizontal: 6 },
  distanceColumn: { flex: 1, textAlign: 'right', paddingHorizontal: 6 },
});
