# react-native-alarmkit

> [!WARNING]
> This library is still under development. Use at your own risk.

This library provides a simple and modern interface for working with alarms in your React Native app using Apple’s latest AlarmKit framework.

## Installation

### React Native
> [!NOTE]  
> ``react-native-nitro-modules`` is required because this library leverages [Nitro Modules](https://nitro.margelo.com/).
```sh
npm install react-native-alarmkit react-native-nitro-modules
```
### Expo
```sh
npx expo add react-native-real-fetch react-native-nitro-modules
npx expo prebuild
```

## Usage


```js
import { createAlarmButton, createAlarmCountdown, requestAlarmPermission, scheduleFixedAlarm, scheduleRelativeAlarm } from 'react-native-alarmkit';

// Ask for permission to schedule alarms
await requestAlarmPermission();

// Alarm Buttons and Countdown
const secondBtn = await createAlarmButton("repeat", "#000000", "play.circle")
const stopBtn = await createAlarmButton("stop", "#FF0000", "stop.circle")
const countdown = await createAlarmCountdown(3, 15)

// Set up a timer that will trigger in 3 seconds and repeat after 15 seconds
scheduleFixedAlarm("super alarme", stopBtn, "#FFFFFF", secondBtn, undefined, countdown)

// Set up a relative alarm that will trigger at 10:00 on Monday, Thursday, and Friday
scheduleRelativeAlarm("amazing relative alarm", stopBtn, "#FFFFFF", 10, 0, ["monday", "friday", "thursday"])
```


## Contributing

See the [contributing guide](CONTRIBUTING.md) to learn how to contribute to the repository and the development workflow.
