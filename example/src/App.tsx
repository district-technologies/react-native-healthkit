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
          return Healthkit.getWorkouts({
            startDate: Date.parse('2018-01-01'),
          }).then((items) => {
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
          ?.filter((item) => item.totalDistance > 0 && item.duration > 0)
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
                  <View style={styles.activityRow}>
                    <Text>{item.workoutActivityType}</Text>
                    <Text>
                      {item.routes?.reduce((result, item) => {
                        if (item.locations) {
                          result += item.locations?.length;
                        }
                        return result;
                      }, 0) || 'no'}{' '}
                      locations
                    </Text>
                    <Text style={styles.duration}>
                      {(item.duration / 60).toFixed(0) + ' mins'}
                    </Text>
                    <Text style={styles.distance}>
                      {(item.totalDistance / 1000).toFixed(2) + ' km'}
                    </Text>
                  </View>
                </View>
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
  dateColumn: { flex: 1, paddingHorizontal: 6 },
  duration: { textAlign: 'right', paddingHorizontal: 6 },
  distance: { textAlign: 'right', paddingHorizontal: 6 },
  activityRow: { flexDirection: 'row', justifyContent: 'space-between' },
});
