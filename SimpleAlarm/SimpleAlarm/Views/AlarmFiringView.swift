import SwiftUI

struct AlarmFiringView: View {
    @EnvironmentObject var alarmManager: AlarmManager
    @State private var pulseScale: CGFloat = 1.0
    @State private var timeString: String = ""
    @State private var timer: Timer?

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 40) {
                Spacer()

                // Pulsing alarm icon
                ZStack {
                    Circle()
                        .fill(Color.blue.opacity(0.15))
                        .frame(width: 160, height: 160)
                        .scaleEffect(pulseScale)

                    Circle()
                        .fill(Color.blue.opacity(0.25))
                        .frame(width: 120, height: 120)
                        .scaleEffect(pulseScale * 0.9)

                    Image(systemName: "alarm.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.blue)
                }

                // Time
                Text(timeString)
                    .font(.system(size: 64, weight: .light, design: .default))
                    .foregroundColor(.white)

                // Alarm label
                if let alarm = alarmManager.firingAlarm {
                    VStack(spacing: 8) {
                        Text(alarm.label)
                            .font(.title2)
                            .foregroundColor(.white.opacity(0.8))

                        if alarm.stopMode.isAutomatic {
                            Text("Auto-stops in \(alarm.stopMode.seconds) seconds")
                                .font(.subheadline)
                                .foregroundColor(.blue)
                        }
                    }
                }

                Spacer()

                // Action buttons
                VStack(spacing: 16) {
                    // Snooze button (only if snooze is enabled)
                    if alarmManager.firingAlarm?.snoozeEnabled == true {
                        Button {
                            alarmManager.snoozeAlarm()
                        } label: {
                            Text("Snooze")
                                .font(.title3)
                                .fontWeight(.medium)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color(white: 0.2))
                                .cornerRadius(14)
                        }
                    }

                    // Stop button
                    Button {
                        alarmManager.stopAlarm()
                    } label: {
                        Text("Stop")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.blue)
                            .cornerRadius(14)
                    }
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 60)
            }
        }
        .onAppear {
            startPulse()
            updateTime()
            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
                updateTime()
            }
        }
        .onDisappear {
            timer?.invalidate()
        }
    }

    private func startPulse() {
        withAnimation(
            .easeInOut(duration: 1.0)
            .repeatForever(autoreverses: true)
        ) {
            pulseScale = 1.15
        }
    }

    private func updateTime() {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm:ss a"
        timeString = formatter.string(from: Date())
    }
}
