import AppKit
import CoreGraphics
import SwiftUI

// MARK: - Spacing Scale
public enum Space {
    public static let xxs: CGFloat = 2
    public static let xs: CGFloat = 4
    public static let sm: CGFloat = 8
    public static let md: CGFloat = 12
    public static let lg: CGFloat = 16
    public static let xl: CGFloat = 20
    public static let xxl: CGFloat = 24
    public static let section: CGFloat = 32
    public static let margin: CGFloat = 20
}

// MARK: - Corner Radii
public enum Radius {
    public static let xs: CGFloat = 6
    public static let sm: CGFloat = 8
    public static let row: CGFloat = 10
    public static let md: CGFloat = 12
    public static let lg: CGFloat = 14
    public static let xl: CGFloat = 20
}

// MARK: - Motion Tokens
public enum Motion {
    public static var quick: Animation {
        NSWorkspace.shared.accessibilityDisplayShouldReduceMotion
            ? .linear(duration: 0.01)
            : .easeOut(duration: 0.10)
    }

    public static var appear: Animation {
        NSWorkspace.shared.accessibilityDisplayShouldReduceMotion
            ? .linear(duration: 0.01)
            : .spring(response: 0.15, dampingFraction: 0.84)
    }
}

// MARK: - Primary Brand Palette
public enum Palette {
    /// Primary Crimson Red brand color (#E11D48)
    public static let accent = Color(light: 0xE11D48, dark: 0xF43F5E)

    /// Readable crimson text tint
    public static let accentText = Color(light: 0xBE123C, dark: 0xFB7185)

    /// Secondary warm red for gradients
    public static let accentSecondary = Color(light: 0x9F1239, dark: 0xBE123C)

    /// Foreground color on top of accent fills
    public static let onAccent = Color.white

    /// Semantic status colors
    public static let success = Color(light: 0x15803D, dark: 0x4ADE80)
    public static let warning = Color(light: 0xB45309, dark: 0xFBBF24)
}

// MARK: - Surface Tokens
public enum Surfaces {
    public static let cardFill = Color.primary.opacity(0.045)
    public static let cardHover = Color.primary.opacity(0.075)
    public static let hairline = Color.primary.opacity(0.10)
    public static let glassBorder = Color.white.opacity(0.22)

    /// Clear, deep dark surface for Dark Mode
    public static let popupDarkBg = Color(hex: 0x161822)
    /// Crisp pure white surface for Light Mode
    public static let popupLightBg = Color(hex: 0xFFFFFF)

    /// Returns `.dark` if the macOS system appearance is currently Dark Mode, otherwise `.light`.
    public static var currentSystemColorScheme: ColorScheme {
        let best = NSApp.effectiveAppearance.bestMatch(from: [.aqua, .darkAqua])
        return best == .darkAqua ? .dark : .light
    }
}

// MARK: - Brand Icon View (Dual-Card Translation Prism + Spark)
public struct LamhaBrandIconView: View {
    public let size: CGFloat

    public init(size: CGFloat = 44) {
        self.size = size
    }

    public var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: size * 0.24, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(hex: 0x160B14),
                            Color(hex: 0x2A0917),
                            Color(hex: 0x4C0D24)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RadialGradient(
                        colors: [
                            Color(hex: 0xF43F5E).opacity(0.42),
                            Color.clear
                        ],
                        center: .bottomTrailing,
                        startRadius: size * 0.05,
                        endRadius: size * 0.65
                    )
                    .clipShape(RoundedRectangle(cornerRadius: size * 0.24, style: .continuous))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: size * 0.24, style: .continuous)
                        .strokeBorder(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.32),
                                    Color(hex: 0xF43F5E).opacity(0.45)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: max(1, size * 0.025)
                        )
                )

            RoundedRectangle(cornerRadius: size * 0.12, style: .continuous)
                .fill(Color.white.opacity(0.14))
                .frame(width: size * 0.44, height: size * 0.44)
                .overlay(
                    RoundedRectangle(cornerRadius: size * 0.12, style: .continuous)
                        .strokeBorder(Color.white.opacity(0.34), lineWidth: max(0.8, size * 0.02))
                )
                .overlay(
                    Text("A")
                        .font(.system(size: size * 0.23, weight: .heavy, design: .rounded))
                        .foregroundStyle(Color.white.opacity(0.92))
                )
                .rotationEffect(.degrees(-8))
                .offset(x: -size * 0.12, y: -size * 0.10)

            RoundedRectangle(cornerRadius: size * 0.13, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(hex: 0xFF335C),
                            Color(hex: 0xE11D48),
                            Color(hex: 0x9F1239)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: size * 0.46, height: size * 0.46)
                .overlay(
                    RoundedRectangle(cornerRadius: size * 0.13, style: .continuous)
                        .strokeBorder(Color.white.opacity(0.45), lineWidth: max(0.9, size * 0.022))
                )
                .overlay(
                    Text("ع")
                        .font(.system(size: size * 0.25, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.white)
                        .offset(y: -size * 0.015)
                )
                .shadow(color: Color.black.opacity(0.45), radius: size * 0.08, x: -size * 0.03, y: size * 0.04)
                .rotationEffect(.degrees(6))
                .offset(x: size * 0.12, y: size * 0.10)

            Image(systemName: "sparkle")
                .font(.system(size: size * 0.17, weight: .bold))
                .foregroundStyle(Color(hex: 0xFDE047))
                .offset(x: size * 0.24, y: -size * 0.24)
        }
        .frame(width: size, height: size)
        .environment(\.layoutDirection, .leftToRight)
    }
}

// MARK: - GitHub Vector Logo Shape
public struct GitHubIconView: View {
    public let size: CGFloat

    public init(size: CGFloat = 16) {
        self.size = size
    }

    public var body: some View {
        Canvas { context, canvasSize in
            let scale = min(canvasSize.width, canvasSize.height) / 24.0
            var path = Path()
            // Standard GitHub Octocat silhouette scaled to 24x24
            path.move(to: CGPoint(x: 12 * scale, y: 0.5 * scale))
            path.addCurve(
                to: CGPoint(x: 0 * scale, y: 12.5 * scale),
                control1: CGPoint(x: 5.37 * scale, y: 0.5 * scale),
                control2: CGPoint(x: 0 * scale, y: 5.87 * scale)
            )
            path.addCurve(
                to: CGPoint(x: 8.21 * scale, y: 23.89 * scale),
                control1: CGPoint(x: 0 * scale, y: 17.8 * scale),
                control2: CGPoint(x: 3.44 * scale, y: 22.3 * scale)
            )
            path.addCurve(
                to: CGPoint(x: 9.03 * scale, y: 23.31 * scale),
                control1: CGPoint(x: 8.81 * scale, y: 24.0 * scale),
                control2: CGPoint(x: 9.03 * scale, y: 23.63 * scale)
            )
            path.addLine(to: CGPoint(x: 9.03 * scale, y: 21.1 * scale))
            path.addCurve(
                to: CGPoint(x: 4.91 * scale, y: 19.3 * scale),
                control1: CGPoint(x: 5.69 * scale, y: 21.82 * scale),
                control2: CGPoint(x: 4.99 * scale, y: 19.49 * scale)
            )
            path.addCurve(
                to: CGPoint(x: 3.32 * scale, y: 17.3 * scale),
                control1: CGPoint(x: 4.36 * scale, y: 17.91 * scale),
                control2: CGPoint(x: 3.57 * scale, y: 17.54 * scale)
            )
            path.addCurve(
                to: CGPoint(x: 3.45 * scale, y: 17.06 * scale),
                control1: CGPoint(x: 2.78 * scale, y: 17.01 * scale),
                control2: CGPoint(x: 3.45 * scale, y: 17.06 * scale)
            )
            path.addCurve(
                to: CGPoint(x: 5.29 * scale, y: 18.37 * scale),
                control1: CGPoint(x: 4.33 * scale, y: 17.12 * scale),
                control2: CGPoint(x: 4.79 * scale, y: 17.97 * scale)
            )
            path.addCurve(
                to: CGPoint(x: 9.09 * scale, y: 19.1 * scale),
                control1: CGPoint(x: 6.36 * scale, y: 20.2 * scale),
                control2: CGPoint(x: 8.08 * scale, y: 19.67 * scale)
            )
            path.addCurve(
                to: CGPoint(x: 9.89 * scale, y: 17.5 * scale),
                control1: CGPoint(x: 9.2 * scale, y: 18.32 * scale),
                control2: CGPoint(x: 9.51 * scale, y: 17.79 * scale)
            )
            path.addCurve(
                to: CGPoint(x: 4.55 * scale, y: 11.6 * scale),
                control1: CGPoint(x: 7.22 * scale, y: 17.2 * scale),
                control2: CGPoint(x: 4.55 * scale, y: 16.16 * scale)
            )
            path.addCurve(
                to: CGPoint(x: 5.79 * scale, y: 8.37 * scale),
                control1: CGPoint(x: 4.55 * scale, y: 10.29 * scale),
                control2: CGPoint(x: 5.02 * scale, y: 9.22 * scale)
            )
            path.addCurve(
                to: CGPoint(x: 5.91 * scale, y: 5.1 * scale),
                control1: CGPoint(x: 5.66 * scale, y: 8.07 * scale),
                control2: CGPoint(x: 5.25 * scale, y: 6.84 * scale)
            )
            path.addCurve(
                to: CGPoint(x: 9.21 * scale, y: 6.35 * scale),
                control1: CGPoint(x: 5.91 * scale, y: 5.1 * scale),
                control2: CGPoint(x: 6.92 * scale, y: 4.78 * scale)
            )
            path.addCurve(
                to: CGPoint(x: 15.21 * scale, y: 6.35 * scale),
                control1: CGPoint(x: 10.17 * scale, y: 6.08 * scale),
                control2: CGPoint(x: 14.25 * scale, y: 6.08 * scale)
            )
            path.addCurve(
                to: CGPoint(x: 18.51 * scale, y: 5.1 * scale),
                control1: CGPoint(x: 17.5 * scale, y: 4.78 * scale),
                control2: CGPoint(x: 18.51 * scale, y: 5.1 * scale)
            )
            path.addCurve(
                to: CGPoint(x: 18.63 * scale, y: 8.37 * scale),
                control1: CGPoint(x: 19.17 * scale, y: 6.84 * scale),
                control2: CGPoint(x: 18.76 * scale, y: 8.07 * scale)
            )
            path.addCurve(
                to: CGPoint(x: 19.87 * scale, y: 11.6 * scale),
                control1: CGPoint(x: 19.4 * scale, y: 9.22 * scale),
                control2: CGPoint(x: 19.87 * scale, y: 10.29 * scale)
            )
            path.addCurve(
                to: CGPoint(x: 14.51 * scale, y: 17.48 * scale),
                control1: CGPoint(x: 19.87 * scale, y: 16.18 * scale),
                control2: CGPoint(x: 17.19 * scale, y: 17.19 * scale)
            )
            path.addCurve(
                to: CGPoint(x: 15.45 * scale, y: 19.49 * scale),
                control1: CGPoint(x: 14.93 * scale, y: 17.85 * scale),
                control2: CGPoint(x: 15.45 * scale, y: 18.58 * scale)
            )
            path.addLine(to: CGPoint(x: 15.45 * scale, y: 23.31 * scale))
            path.addCurve(
                to: CGPoint(x: 16.28 * scale, y: 23.89 * scale),
                control1: CGPoint(x: 15.45 * scale, y: 23.63 * scale),
                control2: CGPoint(x: 15.67 * scale, y: 24.01 * scale)
            )
            path.addCurve(
                to: CGPoint(x: 24 * scale, y: 12.5 * scale),
                control1: CGPoint(x: 20.56 * scale, y: 22.3 * scale),
                control2: CGPoint(x: 24 * scale, y: 17.8 * scale)
            )
            path.addCurve(
                to: CGPoint(x: 12 * scale, y: 0.5 * scale),
                control1: CGPoint(x: 24 * scale, y: 5.87 * scale),
                control2: CGPoint(x: 18.63 * scale, y: 0.5 * scale)
            )
            path.closeSubpath()
            context.fill(path, with: .foreground)
        }
        .frame(width: size, height: size)
    }
}

// MARK: - Menu Bar Status Icon Generator
public enum LamhaMenuBarIcon {
    /// Generates a crisp dual-card translation icon for the macOS top Menu Bar.
    public static func make(isEnabled: Bool) -> NSImage {
        let size = NSSize(width: 20, height: 18)
        let image = NSImage(size: size, flipped: false) { _ in
            let alpha: CGFloat = isEnabled ? 1.0 : 0.45

            let backRect = NSRect(x: 1.5, y: 6.5, width: 10.5, height: 9.5)
            let backPath = NSBezierPath(roundedRect: backRect, xRadius: 2.6, yRadius: 2.6)
            NSColor.labelColor.withAlphaComponent(0.22 * alpha).setFill()
            backPath.fill()
            NSColor.labelColor.withAlphaComponent(0.75 * alpha).setStroke()
            backPath.lineWidth = 1.25
            backPath.stroke()

            let aAttrs: [NSAttributedString.Key: Any] = [
                .font: NSFont.systemFont(ofSize: 6.5, weight: .heavy),
                .foregroundColor: NSColor.labelColor.withAlphaComponent(0.90 * alpha)
            ]
            NSString(string: "A").draw(at: NSPoint(x: 4.3, y: 7.4), withAttributes: aAttrs)

            let frontRect = NSRect(x: 7.8, y: 1.5, width: 10.8, height: 10.0)
            let frontPath = NSBezierPath(roundedRect: frontRect, xRadius: 2.8, yRadius: 2.8)
            let crimson = isEnabled
                ? NSColor(hex: 0xE11D48)
                : NSColor.labelColor.withAlphaComponent(0.45)
            crimson.setFill()
            frontPath.fill()

            NSColor.white.withAlphaComponent(0.85 * alpha).setStroke()
            frontPath.lineWidth = 1.0
            frontPath.stroke()

            let arAttrs: [NSAttributedString.Key: Any] = [
                .font: NSFont.systemFont(ofSize: 7.0, weight: .bold),
                .foregroundColor: NSColor.white.withAlphaComponent(alpha)
            ]
            NSString(string: "ع").draw(at: NSPoint(x: 10.8, y: 2.7), withAttributes: arAttrs)

            return true
        }
        image.isTemplate = false
        return image
    }
}

extension View {
    public func themed() -> some View {
        self.tint(Palette.accent)
    }
}

extension Color {
    public init(hex: UInt32) {
        self.init(nsColor: NSColor(hex: hex))
    }

    public init(light: UInt32, dark: UInt32) {
        self.init(nsColor: NSColor(name: nil) { appearance in
            switch appearance.bestMatch(from: [.aqua, .darkAqua]) {
            case .darkAqua:
                return NSColor(hex: dark)
            default:
                return NSColor(hex: light)
            }
        })
    }
}

extension NSColor {
    public convenience init(hex: UInt32) {
        self.init(
            srgbRed: CGFloat((hex >> 16) & 0xFF) / 255.0,
            green: CGFloat((hex >> 8) & 0xFF) / 255.0,
            blue: CGFloat(hex & 0xFF) / 255.0,
            alpha: 1.0
        )
    }
}
