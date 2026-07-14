import Foundation
import AinkradAppKit

/// Bridges Terminal's static `AinkradApp` entry points to a single shared,
/// observable `TerminalSettingsStore` per host. `makeRootView(host:)` and
/// `makeSettingsView(host:)` receive the same host instance, so every Terminal
/// pane and the settings pane share one store — a settings edit restyles all
/// running terminals live. Keyed by host object identity (the host is always a
/// reference type — `HostServicesImpl`).
@MainActor
enum TerminalRuntime {
    private static var stores: [ObjectIdentifier: TerminalSettingsStore] = [:]
    private static var bridges: [ObjectIdentifier: TerminalContextBridge] = [:]
    private static var actionTokens: [ObjectIdentifier: AgentActionToken] = [:]

    static func settingsStore(for host: HostServices) -> TerminalSettingsStore {
        let key = ObjectIdentifier(host as AnyObject)
        if let existing = stores[key] { return existing }
        let store = TerminalSettingsStore(documents: host.documents)
        stores[key] = store
        return store
    }

    /// The per-host agent-context bridge. Created and **registered with the host
    /// once** on first request (mirroring `settingsStore` — a Block's root and
    /// settings views share the one host, hence one bridge). Never removed: the
    /// registered closure returns nil once the view is gone.
    static func contextBridge(for host: HostServices) -> TerminalContextBridge {
        let key = ObjectIdentifier(host as AnyObject)
        if let existing = bridges[key] { return existing }
        let bridge = TerminalContextBridge()
        bridges[key] = bridge
        _ = host.context.register { bridge.snapshot() }
        return bridge
    }

    /// Register this host's gated action handlers **once**. The `terminal.echo`
    /// handler decodes {command, output} and renders it into the active terminal
    /// via the per-host context bridge. Never torn down — a gone view means the
    /// bridge's weak source is nil and the echo is a no-op.
    static func registerActions(for host: HostServices) {
        let key = ObjectIdentifier(host as AnyObject)
        guard actionTokens[key] == nil else { return }
        let bridge = contextBridge(for: host)
        let token = host.actions.register(actionID: "terminal.echo") { json in
            guard let data = json.data(using: .utf8),
                  let obj = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let command = obj["command"] as? String else {
                return AgentActionResult(text: "terminal.echo: malformed input", isError: true)
            }
            let output = obj["output"] as? String ?? ""
            bridge.echo(command: command, output: output)
            return AgentActionResult(text: "echoed", isError: false)
        }
        actionTokens[key] = token
    }
}
