import SwiftUI
import AppKit

public struct MenuBarView: View {
    @ObservedObject var settings = AppSettings.shared

    let onOpenSettings: () -> Void

    public init(onOpenSettings: @escaping () -> Void) {
        self.onOpenSettings = onOpenSettings
    }

    private var s: AppStrings { settings.strings }

    public var body: some View {
        HStack(spacing: Space.sm + 2) {
            LamhaBrandIconView(size: 34)

            VStack(alignment: .leading, spacing: 2) {
                Text(s.appName)
                    .font(.system(size: 13, weight: .bold))
                    .lineLimit(1)
                HStack(spacing: Space.xs) {
                    Circle()
                        .fill(settings.isEnabled ? Palette.success : Color.secondary.opacity(0.5))
                        .frame(width: 6.5, height: 6.5)
                    Text(settings.isEnabled ? s.enabled : s.disabled)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(.secondary)
                }
            }

            Spacer(minLength: Space.sm)

            // 1. Enable / Disable Toggle Switch
            Toggle("", isOn: $settings.isEnabled)
                .labelsHidden()
                .toggleStyle(.switch)
                .controlSize(.small)

            // 2. Settings Icon Button
            Button(action: onOpenSettings) {
                Image(systemName: "gearshape.fill")
                    .font(.system(size: 12.5, weight: .semibold))
                    .foregroundStyle(.primary)
                    .frame(width: 28, height: 28)
                    .background(Circle().fill(Color.primary.opacity(0.08)))
            }
            .buttonStyle(.plain)
            .help(s.openSettingsBtn)

            // 3. Close / Quit App Icon Button
            Button(action: {
                NSApplication.shared.terminate(nil)
            }) {
                Image(systemName: "power")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(Palette.accent)
                    .frame(width: 28, height: 28)
                    .background(Circle().fill(Palette.accent.opacity(0.14)))
            }
            .buttonStyle(.plain)
            .help(s.quitBtn)
        }
        .padding(.horizontal, Space.lg)
        .padding(.vertical, Space.md + 2)
        .frame(width: 345)
        .themed()
        .noInitialFocus()
        .environment(\.layoutDirection, settings.layoutDirection)
    }
}
