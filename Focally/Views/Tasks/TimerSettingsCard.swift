import SwiftUI

struct TimerSettingsCard: View {
    @State private var focusDuration: String = "25"
    @State private var shortBreak: String = "5"
    @State private var longBreak: String = "15"
    @State private var autoStartBreaks: Bool = true

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack(spacing: 8) {
                Image(systemName: "timer")
                    .font(.system(size: 20))
                    .foregroundStyle(Color.focallyPrimary)
                Text("Timer Settings")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(Color.focallyOnSurface)
            }

            // Timer duration inputs
            VStack(spacing: 12) {
                TimerInputRow(label: "Focus Duration", value: $focusDuration, unit: "min", defaultValue: "25")
                Divider()
                TimerInputRow(label: "Short Break", value: $shortBreak, unit: "min", defaultValue: "5")
                Divider()
                TimerInputRow(label: "Long Break", value: $longBreak, unit: "min", defaultValue: "15")
            }

            Spacer()

            // Auto-start breaks toggle
            HStack {
                Image(systemName: "arrow.triangle.2.circlepath")
                    .font(.system(size: 16))
                    .foregroundStyle(Color.focallySecondary)
                Text("Auto-start Breaks")
                    .font(.system(size: 13))
                    .foregroundStyle(Color.focallyOnSurface)

                Spacer()

                Toggle("", isOn: $autoStartBreaks)
                    .labelsHidden()
                    .toggleStyle(.switch)
            }
        }
        .padding(16)
        .focallyCard()
    }
}

struct TimerInputRow: View {
    let label: String
    @Binding var value: String
    let unit: String
    let defaultValue: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(label)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color.focallyOnSurface)
                Spacer()
                Text(unit)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(Color.focallyOutline)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Color.focallySurfaceContainerLowest.opacity(0.5))
                    .cornerRadius(6)
            }

            TextField("0", text: $value)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(Color.focallyOnSurface)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(Color.focallySurfaceContainerLowest.opacity(0.5))
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.focallyOutline.opacity(0.2))
                )
                .multilineTextAlignment(.trailing)
        }
    }
}

struct FocusModeCard: View {
    var body: some View {
        VStack(spacing: 0) {
            // Gradient background
            LinearGradient(
                colors: [Color.focallyPrimary.opacity(0.8), Color.focallyPrimaryContainer.opacity(0.6)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .frame(height: 128)
            .cornerRadius(12)

            // Content
            VStack(alignment: .leading, spacing: 4) {
                Text("Flow Mode")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(.white)
                Text("Optimized for knowledge work.")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(.white.opacity(0.8))
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .focallyCard()
    }
}
