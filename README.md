# react-native-healthkit

Native module for HealthKit

## Installation

```sh
npm install react-native-healthkit
```

## Usage

```js
import Healthkit, { Workout } from 'react-native-healthkit';

// ...

Healthkit.requestPermissions().then((success) => {
  if (success) {
    Healthkit.getWorkouts().then((workouts: Workout[]) => {
      // TODO: Use workout data
    });
  }
});

// ...
```

## Contributing

See the [contributing guide](CONTRIBUTING.md) to learn how to contribute to the repository and the development workflow.

## License

MIT
