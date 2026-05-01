import SwiftUI

struct SidebarView: View {
    @Binding var selectedTab: FocallyTab
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(spacing: 0) {
            // Logo area
            VStack(alignment: .leading, spacing: 2) {
                Text("Focally")
                    .font(.focallyH1)
                    .foregroundStyle(Color.focallyOnSurface)

                Text("Deep Work")
                    .font(.focallyCaption)
                    .foregroundStyle(Color.focallyOnSurfaceVariant)
                    .textCase(.uppercase)
                    .tracking(3)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, FocallySpacing.md)
            .padding(.top, FocallySpacing.lg)
            .padding(.bottom, FocallySpacing.lg)

            Divider()
                .padding(.horizontal, FocallySpacing.sm)

            // Navigation items
            VStack(spacing: 2) {
                ForEach(FocallyTab.allCases) { tab in
                    SidebarItemView(
                        icon: tab.activeIcon,
                        label: tab.rawValue,
                        isActive: selectedTab == tab,
                        action: { selectedTab = tab }
                    )
                }
            }
            .padding(.horizontal, FocallySpacing.sm)
            .padding(.top, FocallySpacing.sm)

            Spacer()

            // Profile card
            HStack(spacing: 10) {
                Circle()
                    .fill(Color.focallyPrimaryContainer)
                    .frame(width: 32, height: 32)
                    .overlay(
                        Text("E")
                            .font(.focallyBodyBold)
                            .foregroundStyle(.white)
                    )

                Text("Eliab")
                    .font(.focallyBodyBold)
                    .foregroundStyle(Color.focallyOnSurface)

                Spacer()
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: FocallyRadius.lg)
                    .fill(Color.focallySurfaceContainerLow)
                    .overlay(
                        RoundedRectangle(cornerRadius: FocallyRadius.lg)
                            .stroke(Color.focallyCardBorder, lineWidth: 0.5)
                    )
            )
            .padding(.horizontal, FocallySpacing.sm)
            .padding(.bottom, FocallySpacing.md)
        }
        .frame(width: 260)
        .background(
            ZStack {
                if colorScheme == .dark {
                    Color(hex: "121317").opacity(0.8)
                } else {
                    Color(hex: "F3F3F4").opacity(0.8)
                }
            }
            .blur(radius: 30)
            .ignoresSafeArea()
        )
        .overlay(
            Rectangle()
                .frame(width: 0.5)
                .foregroundStyle(
                    colorScheme == .dark
                        ? Color.white.opacity(0.08)
                        : Color.black.opacity(0.1)
                ),
            alignment: .trailing
        )
    }
}
