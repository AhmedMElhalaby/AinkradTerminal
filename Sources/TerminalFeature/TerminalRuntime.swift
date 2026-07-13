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
}
