import SwiftUI

public struct TriggerBadgeView: View {
    @ObservedObject var settings = AppSettings.shared
    let onTrigger: () -> Void

    @State private var isHovered: Bool = false
    @State private var appearScale: CGFloat = 0.85
    @State private var hoverTimer: Timer?

    public init(onTrigger: @escaping () -> Void) {
        self.onTrigger = onTrigger
    }

    private var effectiveScheme: ColorScheme {
        switch settings.themeMode {
        case .system: return Surfaces.currentSystemColorScheme
        case .darkGlass: return .dark
        case .lightGlass: return .light
        }
    }

    public var body: some View {
        let size = CGFloat(settings.badgeSize)
        let isDark = (effectiveScheme == .dark)

        Button(action: {
            hoverTimer?.invalidate()
            onTrigger()
        }) {
            ZStack {
                Circle()
                    .fill(isDark ? Surfaces.popupDarkBg : Surfaces.popupLightBg)
                    .overlay(
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Palette.accent.opacity(isHovered ? 0.38 : 0.18),
                                        Palette.accentSecondary.opacity(isHovered ? 0.26 : 0.08)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    )
                    .overlay(
                        Circle()
                            .strokeBorder(
                                LinearGradient(
                                    colors: [
                                        Palette.accent.opacity(isHovered ? 0.90 : 0.55),
                                        (isDark ? Color.white : Color.black).opacity(0.24)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1.2
                            )
                    )
                    .shadow(color: Color.black.opacity(isDark ? 0.38 : 0.20), radius: 5, x: 0, y: 2)

                ZStack {
                    Text("ع")
                        .font(.system(size: size * 0.44, weight: .heavy, design: .rounded))
                        .foregroundStyle(Palette.accent)
                        .offset(x: -size * 0.04, y: size * 0.02)

                    Image(systemName: "sparkle")
                        .font(.system(size: size * 0.25, weight: .bold))
                        .foregroundStyle(Palette.accent)
                        .offset(x: size * 0.19, y: -size * 0.17)
                }
            }
            .frame(width: size, height: size)
            .scaleEffect(appearScale * (isHovered ? 1.10 : 1.0))
            .animation(Motion.quick, value: isHovered)
            .animation(Motion.appear, value: appearScale)
        }
        .buttonStyle(.plain)
        .environment(\.colorScheme, effectiveScheme)
        .noInitialFocus()
        .onHover { hovering in
            isHovered = hovering
            if hovering && settings.triggerMode == .showIconHover {
                hoverTimer?.invalidate()
                hoverTimer = Timer.scheduledTimer(withTimeInterval: 0.04, repeats: false) { _ in
                    Task { @MainActor in
                        onTrigger()
                    }
                }
            } else {
                hoverTimer?.invalidate()
            }
        }
        .onAppear {
            appearScale = 1.0
        }
    }
}
