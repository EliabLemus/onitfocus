import SwiftUI

struct IntegrationsSettingsView: View {
    @State private var slackEnabled: Bool = false
    @State private var calendarEnabled: Bool = false
    @State private var slackConnected: Bool = false
    @State private var calendarConnected: Bool = false

    var body: some View {
        VStack(spacing: FocallySpacing.lg) {
            // Slack Card
            VStack(alignment: .leading, spacing: FocallySpacing.md) {
                HStack(spacing: FocallySpacing.md) {
                    ZStack {
                        RoundedRectangle(cornerRadius: FocallyRadius.sm)
                            .fill(Color.focallyPrimary.opacity(0.1))
                            .frame(width: 40, height: 40)
                        Image(systemName: "message.fill")
                            .font(.system(size: 18))
                            .foregroundStyle(Color.focallyPrimary)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Slack Integration")
                            .font(.focallyBodyBold)
                            .foregroundStyle(Color.focallyOnSurface)

                        Text("Post focus status updates to Slack channels.")
                            .font(.focallyBody)
                            .foregroundStyle(Color.focallyOutline)
                    }

                    Spacer()

                    // Connection status badge
                    connectionBadge(connected: slackConnected)

                    FocallyToggleButton(isOn: $slackEnabled)
                }
            }
            .padding(FocallySpacing.lg)
            .focallyCard()

            // Google Calendar Card
            VStack(alignment: .leading, spacing: FocallySpacing.md) {
                HStack(spacing: FocallySpacing.md) {
                    ZStack {
                        RoundedRectangle(cornerRadius: FocallyRadius.sm)
                            .fill(Color.focallyTertiaryContainer.opacity(0.1))
                            .frame(width: 40, height: 40)
                        Image(systemName: "calendar")
                            .font(.system(size: 18))
                            .foregroundStyle(Color.focallyTertiary)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Google Calendar")
                            .font(.focallyBodyBold)
                            .foregroundStyle(Color.focallyOnSurface)

                        Text("Sync focus sessions with your calendar events.")
                            .font(.focallyBody)
                            .foregroundStyle(Color.focallyOutline)
                    }

                    Spacer()

                    connectionBadge(connected: calendarConnected)

                    FocallyToggleButton(isOn: $calendarEnabled)
                }
            }
            .padding(FocallySpacing.lg)
            .focallyCard()
        }
    }

    private func connectionBadge(connected: Bool) -> some View {
        HStack(spacing: 4) {
            Circle()
                .fill(connected ? Color.focallyPrimary : Color.focallyOutline)
                .frame(width: 6, height: 6)

            Text(connected ? "Connected" : "Not Connected")
                .font(.focallyCaption)
                .foregroundStyle(connected ? Color.focallyPrimary : Color.focallyOutline)
        }
        .padding(.horizontal, FocallySpacing.sm)
        .padding(.vertical, 4)
        .background(
            RoundedRectangle(cornerRadius: FocallyRadius.xs)
                .fill(connected ? Color.focallyPrimary.opacity(0.1) : Color.focallySurfaceContainer)
        )
    }
}

#Preview {
    IntegrationsSettingsView()
        .frame(width: 500, height: 300)
}
