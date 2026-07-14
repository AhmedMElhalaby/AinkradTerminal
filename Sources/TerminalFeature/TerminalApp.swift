import SwiftUI
import AinkradAppKit

/// Terminal as an `AinkradApp` — the SDK contract. Compiled into the host for
/// now (slice 4a); slice 4b extracts it into its own catalog bundle. Depends
/// only on `HostServices`, never on `AppEnvironment`.
public struct TerminalApp: AinkradApp {
    public static let id = "terminal"
    public static let displayName = "Terminal"
    public static let icon = "terminal"

    public static func makeRootView(host: HostServices) -> AnyView {
        TerminalRuntime.registerActions(for: host)
        return AnyView(TerminalBlockRootView(
            settingsStore: TerminalRuntime.settingsStore(for: host),
            contextBridge: TerminalRuntime.contextBridge(for: host),
            theme: host.theme
        ))
    }

    public static func makeSettingsView(host: HostServices) -> AnyView {
        AnyView(TerminalSettingsView(
            settingsStore: TerminalRuntime.settingsStore(for: host),
            theme: host.theme
        ))
    }

    /// The header matches the terminal window: the resolved scheme background at
    /// the configured transparency, so the title bar reads as one continuous
    /// surface with the terminal below.
    public static func chromeFill(host: HostServices) -> Color? {
        let appearance = TerminalAppearanceResolver.resolve(
            settings: TerminalRuntime.settingsStore(for: host).settings,
            tokens: host.theme.tokens
        )
        return Color(hex: appearance.background).opacity(appearance.backgroundOpacity)
    }
}
