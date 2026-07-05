import Foundation
import AinkradAppKit
import TerminalFeature

/// The bundle's `NSPrincipalClass`. `@objc` + explicit name so the Info.plist
/// resolves it after `Bundle.load()`. Registers the plugin's bundled fonts,
/// then hands the host the Terminal app type.
@objc(TerminalEntryPoint)
final class TerminalEntryPoint: NSObject, AinkradPluginEntryPoint {
    static func app() -> any AinkradApp.Type {
        TerminalFonts.registerBundledFonts()
        return TerminalApp.self
    }
}
