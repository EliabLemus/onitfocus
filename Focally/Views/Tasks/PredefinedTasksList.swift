import SwiftUI

struct PredefinedTasksList: View {
    @State private var tasks: [PredefinedTask] = [
        PredefinedTask(name: "Code Review", emoji: "💻"),
        PredefinedTask(name: "Documentation", emoji: "📚"),
        PredefinedTask(name: "Email", emoji: "📧"),
        PredefinedTask(name: "Exercise", emoji: "💪")
    ]

    @State private var showingAddSheet = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                Image(systemName: "checklist")
                    .font(.system(size: 18))
                    .foregroundStyle(Color.focallyPrimary)
                Text("Predefined Tasks")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(Color.focallyOnSurface)

                Spacer()

                Button(action: {
                    showingAddSheet = true
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "plus")
                            .font(.system(size: 12, weight: .semibold))
                        Text("Add New")
                            .font(.system(size: 12, weight: .medium))
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.focallyPrimary)
                    .foregroundStyle(Color.focallyOnPrimary)
                    .cornerRadius(8)
                }
            }

            // Task list
            ForEach(tasks, id: \.id) { task in
                TaskRowView(task: task)
                    .transition(.opacity)
            }

            // Smart Templates section (placeholder)
            Divider()
                .padding(.vertical, 8)

            HStack {
                Text("AI-Powered Task Suggestions")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(Color.focallyOutline)

                Spacer()

                Text("Coming Soon")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(Color.focallyOutline.opacity(0.5))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Color.focallySurfaceContainer.opacity(0.5))
                    .cornerRadius(6)
            }
            .padding(.horizontal, 4)
        }
    }

    struct TaskRowView: View {
        let task: PredefinedTask
        @State private var isHovered = false

        var body: some View {
            HStack(spacing: 12) {
                // Icon
                ZStack {
                    Circle()
                        .fill(iconColor)
                        .frame(width: 32, height: 32)

                    Image(systemName: "chevron.left.forwardslash.chevron.right")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(.white)
                }

                // Task name
                VStack(alignment: .leading, spacing: 2) {
                    Text(task.name)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(Color.focallyOnSurface)

                    Text("25m • 4 cycles")
                        .font(.system(size: 10))
                        .foregroundStyle(Color.focallyOutline)
                }

                Spacer()

                // Actions (hover reveal)
                if isHovered {
                    HStack(spacing: 8) {
                        Button(action: {}) {
                            Image(systemName: "pencil")
                                .font(.system(size: 12))
                                .foregroundStyle(Color.focallyOnSurface)
                        }
                        .buttonStyle(.plain)

                        Button(action: {}) {
                            Image(systemName: "trash")
                                .font(.system(size: 12))
                                .foregroundStyle(Color.focallyError)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(12)
            .background(Color.focallySurfaceContainerLowest.opacity(0.5))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.focallyOutline.opacity(0.1))
            )
            .animation(.easeInOut(duration: 0.2), value: isHovered)
            .onHover { hovering in
                isHovered = hovering
            }
        }

        private var iconColor: Color {
            Color(hex: "0058BC").opacity(0.8)
        }
    }
}
