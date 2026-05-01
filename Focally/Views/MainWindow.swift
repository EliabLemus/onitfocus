import SwiftUI

struct MainWindow: View {
    @State private var selectedTab: FocallyTab = .timer

    var body: some View {
        HStack(spacing: 0) {
            SidebarView(selectedTab: $selectedTab)

            VStack(spacing: 0) {
                TopBarView {
                    Text(selectedTab.rawValue)
                        .font(.focallyH2)
                        .foregroundStyle(Color.focallyOnSurface)
                }

                content
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.focallyBackground)
        }
        .onReceive(NotificationCenter.default.publisher(for: .focusNavigateToSettings)) { _ in
            selectedTab = .settings
        }
    }

    @ViewBuilder
    private var content: some View {
        switch selectedTab {
        case .timer:
            TimerPage()
        case .tasks:
            TasksPage()
        case .schedule:
            SchedulePage()
        case .analytics:
            AnalyticsPage()
        case .settings:
            SettingsPage()
        }
    }
}
