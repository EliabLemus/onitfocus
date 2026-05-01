import SwiftUI

struct TasksPage: View {
    @State private var focusDuration: String = "25"
    @State private var shortBreak: String = "5"
    @State private var longBreak: String = "15"
    @State private var autoStartBreaks: Bool = true

    @State private var predefinedTasks: [PredefinedTask] = [
        PredefinedTask(name: "Code Review", emoji: "💻"),
        PredefinedTask(name: "Documentation", emoji: "📚"),
        PredefinedTask(name: "Email", emoji: "📧"),
        PredefinedTask(name: "Exercise", emoji: "💪")
    ]

    @State private var showingAddSheet = false

    var body: some View {
        VStack(spacing: 0) {
            // TopBar
            TopBarView {
                Text("Task Configuration")
                    .font(.focallyH2)
                    .foregroundStyle(Color.focallyOnSurface)
            }

            VStack(spacing: 0) {
                // Header
                HStack {
                    Text("Task Configuration")
                        .font(.focallyDisplay)
                        .foregroundStyle(Color.focallyOnSurface)

                    Spacer()
                }
                .padding(.horizontal, FocallySpacing.lg)
                .padding(.top, FocallySpacing.lg)

                Text("Manage your focus sessions and predefined activities.")
                    .font(.focallyBody)
                    .foregroundStyle(Color.focallyOutline)
                    .padding(.horizontal, FocallySpacing.lg)
                    .padding(.bottom, FocallySpacing.lg)

                ScrollView {
                    VStack(spacing: FocallySpacing.lg) {
                        // Timer Settings Card
                        TimerSettingsCard()

                        // Visual Accent Card
                        FocusModeCard()

                        // Predefined Tasks Card
                        PredefinedTasksList()
                    }
                    .padding(.horizontal, FocallySpacing.lg)
                    .padding(.bottom, FocallySpacing.lg)
                }
                .scrollContentBackground(.hidden)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.focallyBackground)
        }
    }
}

#Preview {
    TasksPage()
}
