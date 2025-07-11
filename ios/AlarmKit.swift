import AlarmKit
import SwiftUI
import NitroModules

class AlarmKit: HybridAlarmKitSpec {
    @available(iOS 15.1, *)
    public func requestAlarmPermission() throws -> NitroModules.Promise<Bool> {
        return NitroModules.Promise.async {
            if #available(iOS 26.0, *) {
                let manager = AlarmManager.shared
                let state: AlarmManager.AuthorizationState
                do {
                    state = try await manager.requestAuthorization()
                } catch {
                    print("Error in requestAuthorization: \(error)")
                    throw error
                }
                return state == .authorized
            } else {
                throw NSError(
                    domain: "AlarmKitError",
                    code: 1,
                    userInfo: [NSLocalizedDescriptionKey: "AlarmKit requires iOS 26.0 or later"]
                )
            }
        }
    }
    
    @available(iOS 15.1, *)
    public func scheduleFixedAlarm(title: String, stopBtn: CustomizableAlarmButton, tintColor: String, secondaryBtn: CustomizableAlarmButton?, timestamp: Double?, countdown: AlarmCountdown?) throws -> NitroModules.Promise<Bool> {
        return NitroModules.Promise.async {
            if #available(iOS 26.0, *) {
                let manager = AlarmManager.shared
                
                let stopButton = AlarmButton(
                    text: LocalizedStringResource(stringLiteral: stopBtn.text),
                    textColor: Color(StringToColor(hex: stopBtn.textColor)),
                    systemImageName: stopBtn.icon
                )
                let alertPresentationAlert: AlarmPresentation.Alert

                if let btn = secondaryBtn {
                    let secondaryButton = AlarmButton(
                        text: LocalizedStringResource(stringLiteral: btn.text),
                        textColor: Color(StringToColor(hex: btn.textColor)),
                        systemImageName: btn.icon
                    )
                    
                    alertPresentationAlert = AlarmPresentation.Alert(
                        title: LocalizedStringResource(stringLiteral: title),
                        stopButton: stopButton,
                        secondaryButton: secondaryButton,
                        secondaryButtonBehavior: .countdown
                    )
                } else {
                    alertPresentationAlert = AlarmPresentation.Alert(
                        title: LocalizedStringResource(stringLiteral: title),
                        stopButton: stopButton
                    )
                }

                let presentation = AlarmPresentation(alert: alertPresentationAlert)
                let countdown = Alarm.CountdownDuration(preAlert: countdown?.preAlert, postAlert: countdown?.postAlert)
                
                nonisolated struct EmptyMetadata: AlarmMetadata {}
                let attributes = AlarmAttributes<EmptyMetadata>(presentation: presentation, tintColor: Color(StringToColor(hex: tintColor)))

                var schedule: Alarm.Schedule? = nil

                if let timestamp = timestamp {
                    let date = Date(timeIntervalSince1970: timestamp)
                    schedule = Alarm.Schedule.fixed(date)
                }
                
                let configuration = AlarmManager.AlarmConfiguration(
                    countdownDuration: countdown,
                    schedule: schedule,
                    attributes: attributes,
                    sound: .default
                )
                
                let uuid = UUID()
                do {
                    _ = try await manager.schedule(id: uuid, configuration: configuration)
                    return true
                } catch {
                    throw error
                }
            } else {
                print("error")
                throw NSError(
                    domain: "AlarmKitError",
                    code: 1,
                    userInfo: [NSLocalizedDescriptionKey: "AlarmKit requires iOS 26.0 or later"]
                )
            }
        }
    }

    @available(iOS 15.1, *)
    public func scheduleRelativeAlarm(
        title: String,
        stopBtn: CustomizableAlarmButton,
        tintColor: String,
        hour: Double,
        minute: Double,
        repeats: [AlarmWeekday],
        secondaryBtn: CustomizableAlarmButton?,
        countdown: AlarmCountdown?
    ) throws -> NitroModules.Promise<Bool> {
        return NitroModules.Promise.async {
            if #available(iOS 26.0, *) {
                let manager = AlarmManager.shared

                let stopButton = AlarmButton(
                    text: LocalizedStringResource(stringLiteral: stopBtn.text),
                    textColor: Color(StringToColor(hex: stopBtn.textColor)),
                    systemImageName: stopBtn.icon
                )

                let alertPresentationAlert: AlarmPresentation.Alert

                if let btn = secondaryBtn {
                    let secondaryButton = AlarmButton(
                        text: LocalizedStringResource(stringLiteral: btn.text),
                        textColor: Color(StringToColor(hex: btn.textColor)),
                        systemImageName: btn.icon
                    )

                    alertPresentationAlert = AlarmPresentation.Alert(
                        title: LocalizedStringResource(stringLiteral: title),
                        stopButton: stopButton,
                        secondaryButton: secondaryButton,
                        secondaryButtonBehavior: .countdown
                    )
                } else {
                    alertPresentationAlert = AlarmPresentation.Alert(
                        title: LocalizedStringResource(stringLiteral: title),
                        stopButton: stopButton
                    )
                }

                let presentation = AlarmPresentation(alert: alertPresentationAlert)
                let countdown = Alarm.CountdownDuration(preAlert: countdown?.preAlert, postAlert: countdown?.postAlert)

                nonisolated struct EmptyMetadata: AlarmMetadata {}
                let attributes = AlarmAttributes<EmptyMetadata>(presentation: presentation, tintColor: Color(StringToColor(hex: tintColor)))

                let time = Alarm.Schedule.Relative.Time(hour: Int(hour), minute: Int(minute))

                let localeWeekdays: [Locale.Weekday] = repeats.map { alarmWeekday in
                  switch alarmWeekday {
                  case .monday: return .monday
                  case .tuesday: return .tuesday
                  case .wednesday: return .wednesday
                  case .thursday: return .thursday
                  case .friday: return .friday
                  case .saturday: return .saturday
                  case .sunday: return .sunday
                  }
                }
                let recurrence = Alarm.Schedule.Relative.Recurrence.weekly(localeWeekdays)
                let relativeSchedule = Alarm.Schedule.Relative(time: time, repeats: recurrence)
                let schedule = Alarm.Schedule.relative(relativeSchedule)

                let configuration = AlarmManager.AlarmConfiguration(
                    countdownDuration: countdown,
                    schedule: schedule,
                    attributes: attributes,
                    sound: .default
                )

                let uuid = UUID()
                do {
                    _ = try await manager.schedule(id: uuid, configuration: configuration)
                    return true
                } catch {
                    throw error
                }
            } else {
                throw NSError(
                    domain: "AlarmKitError",
                    code: 1,
                    userInfo: [NSLocalizedDescriptionKey: "AlarmKit requires iOS 26.0 or later"]
                )
            }
        }
    }
}

func StringToColor (hex:String) -> UIColor {
    var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

    if (cString.hasPrefix("#")) {
        cString.remove(at: cString.startIndex)
    }

    if ((cString.count) != 6) {
        return UIColor.gray
    }

    var rgbValue:UInt64 = 0
    Scanner(string: cString).scanHexInt64(&rgbValue)

    return UIColor(
        red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
        green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
        blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
        alpha: CGFloat(1.0)
    )
}