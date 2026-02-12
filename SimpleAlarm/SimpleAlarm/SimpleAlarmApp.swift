import SwiftUI

@main
struct SimpleAlarmApp: App {
    @StateObject private var alarmManager = AlarmManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(alarmManager)
        }
    }
}

struct ContentView: View {
    @EnvironmentObject var alarmManager: AlarmManager

    var body: some View {
        ZStack {
            AlarmListView()
                .environmentObject(alarmManager)

            if alarmManager.isAlarmFiring {
                AlarmFiringView()
                    .environmentObject(alarmManager)
                    .transition(.opacity)
                    .zIndex(1)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: alarmManager.isAlarmFiring)
    }
}
