#!/usr/bin/env xcrun swift
//
// gen-promo-screenshot.swift
//
// PLACEHOLDER PROMO IMAGE — original artwork generated offscreen with
// AppKit/CoreGraphics. This is a stand-in for the App Store detail page
// until a real product screenshot is captured; replace screenshots/terminal-1.png
// with an actual screenshot of AinkradTerminal when one is available.
//
// Run headlessly (no window / run loop needed):
//   xcrun swift scripts/gen-promo-screenshot.swift
//
// Renders a ~1440x900 PNG depicting a stylized dark terminal window card
// on a subtle dark gradient background, with a traffic-light title strip
// and a few lines of mock monospace output in a blue/cyan/green/purple
// accent palette.

import AppKit
import CoreGraphics
import Foundation

let width = 1440
let height = 900

guard let rep = NSBitmapImageRep(
    bitmapDataPlanes: nil,
    pixelsWide: width,
    pixelsHigh: height,
    bitsPerSample: 8,
    samplesPerPixel: 4,
    hasAlpha: true,
    isPlanar: false,
    colorSpaceName: .deviceRGB,
    bytesPerRow: 0,
    bitsPerPixel: 0
) else {
    FileHandle.standardError.write("Failed to create bitmap rep\n".data(using: .utf8)!)
    exit(1)
}

guard let ctx = NSGraphicsContext(bitmapImageRep: rep) else {
    FileHandle.standardError.write("Failed to create graphics context\n".data(using: .utf8)!)
    exit(1)
}

NSGraphicsContext.saveGraphicsState()
NSGraphicsContext.current = ctx

let fullRect = NSRect(x: 0, y: 0, width: width, height: height)

// MARK: - Background: subtle dark gradient

let bgTop = NSColor(calibratedRed: 0.09, green: 0.10, blue: 0.14, alpha: 1.0)
let bgBottom = NSColor(calibratedRed: 0.04, green: 0.045, blue: 0.06, alpha: 1.0)
if let bgGradient = NSGradient(starting: bgTop, ending: bgBottom) {
    bgGradient.draw(in: fullRect, angle: -90)
}

// A faint radial accent glow behind the card for depth.
if let glow = NSGradient(starting: NSColor(calibratedRed: 0.20, green: 0.35, blue: 0.55, alpha: 0.28),
                          ending: NSColor(calibratedRed: 0.20, green: 0.35, blue: 0.55, alpha: 0.0)) {
    let glowCenter = NSPoint(x: CGFloat(width) * 0.5, y: CGFloat(height) * 0.62)
    glow.draw(fromCenter: glowCenter, radius: 0, toCenter: glowCenter, radius: 620, options: [])
}

// MARK: - Terminal window card

let cardWidth: CGFloat = 1120
let cardHeight: CGFloat = 660
let cardOrigin = NSPoint(x: (CGFloat(width) - cardWidth) / 2, y: (CGFloat(height) - cardHeight) / 2)
let cardRect = NSRect(origin: cardOrigin, size: NSSize(width: cardWidth, height: cardHeight))
let cardRadius: CGFloat = 20

// Soft drop shadow for the card.
NSGraphicsContext.saveGraphicsState()
let shadow = NSShadow()
shadow.shadowColor = NSColor.black.withAlphaComponent(0.55)
shadow.shadowBlurRadius = 40
shadow.shadowOffset = NSSize(width: 0, height: -12)
shadow.set()

let cardPath = NSBezierPath(roundedRect: cardRect, xRadius: cardRadius, yRadius: cardRadius)
NSColor(calibratedRed: 0.078, green: 0.086, blue: 0.11, alpha: 1.0).setFill()
cardPath.fill()
NSGraphicsContext.restoreGraphicsState()

// Subtle border around the card.
NSColor.white.withAlphaComponent(0.06).setStroke()
cardPath.lineWidth = 1
cardPath.stroke()

// MARK: - Title strip

let titleStripHeight: CGFloat = 44
let titleStripRect = NSRect(
    x: cardRect.minX,
    y: cardRect.maxY - titleStripHeight,
    width: cardRect.width,
    height: titleStripHeight
)

// Clip to the card's rounded shape so the title strip's top corners stay rounded.
NSGraphicsContext.saveGraphicsState()
cardPath.addClip()
NSColor(calibratedRed: 0.11, green: 0.12, blue: 0.15, alpha: 1.0).setFill()
titleStripRect.fill()
NSGraphicsContext.restoreGraphicsState()

// Hairline separator below the title strip.
NSColor.white.withAlphaComponent(0.08).setStroke()
let sepPath = NSBezierPath()
sepPath.move(to: NSPoint(x: cardRect.minX, y: titleStripRect.minY))
sepPath.line(to: NSPoint(x: cardRect.maxX, y: titleStripRect.minY))
sepPath.lineWidth = 1
sepPath.stroke()

// Three traffic-light dots in the accent palette (original styling, not
// a copy of any specific OS chrome).
let dotColors = [
    NSColor(calibratedRed: 0.35, green: 0.60, blue: 0.98, alpha: 1.0), // blue
    NSColor(calibratedRed: 0.25, green: 0.80, blue: 0.85, alpha: 1.0), // cyan
    NSColor(calibratedRed: 0.62, green: 0.48, blue: 0.95, alpha: 1.0), // purple
]
let dotRadius: CGFloat = 6
let dotSpacing: CGFloat = 22
var dotX = cardRect.minX + 24
let dotY = titleStripRect.midY
for color in dotColors {
    let dotRect = NSRect(x: dotX - dotRadius, y: dotY - dotRadius, width: dotRadius * 2, height: dotRadius * 2)
    color.setFill()
    NSBezierPath(ovalIn: dotRect).fill()
    dotX += dotSpacing
}

// Title label, centered in the strip.
let titleFont = NSFont.monospacedSystemFont(ofSize: 13, weight: .medium)
let titleAttrs: [NSAttributedString.Key: Any] = [
    .font: titleFont,
    .foregroundColor: NSColor.white.withAlphaComponent(0.75),
]
let titleString = "Terminal — Ainkrad" as NSString
let titleSize = titleString.size(withAttributes: titleAttrs)
let titlePoint = NSPoint(
    x: titleStripRect.midX - titleSize.width / 2,
    y: titleStripRect.midY - titleSize.height / 2
)
titleString.draw(at: titlePoint, withAttributes: titleAttrs)

// MARK: - Mock terminal output

let contentRect = NSRect(
    x: cardRect.minX,
    y: cardRect.minY,
    width: cardRect.width,
    height: cardRect.height - titleStripHeight
)

let bodyFontSize: CGFloat = 20
let promptFont = NSFont.monospacedSystemFont(ofSize: bodyFontSize, weight: .semibold)
let bodyFont = NSFont.monospacedSystemFont(ofSize: bodyFontSize, weight: .regular)

let green = NSColor(calibratedRed: 0.40, green: 0.85, blue: 0.55, alpha: 1.0)
let cyan = NSColor(calibratedRed: 0.30, green: 0.80, blue: 0.90, alpha: 1.0)
let blue = NSColor(calibratedRed: 0.40, green: 0.62, blue: 0.98, alpha: 1.0)
let purple = NSColor(calibratedRed: 0.66, green: 0.52, blue: 0.96, alpha: 1.0)
let dim = NSColor.white.withAlphaComponent(0.55)
let bright = NSColor.white.withAlphaComponent(0.92)

struct Line {
    let segments: [(String, NSColor, NSFont)]
}

let lines: [Line] = [
    Line(segments: [("ahmed@ainkrad ", green, promptFont), ("~ % ", blue, promptFont), ("ainkrad terminal --launch", bright, bodyFont)]),
    Line(segments: [("→ Loading workspace…", cyan, bodyFont)]),
    Line(segments: [("→ Theme: ", dim, bodyFont), ("Dracula", purple, bodyFont)]),
    Line(segments: [("→ Panes: ", dim, bodyFont), ("2 split, 1 active", bright, bodyFont)]),
    Line(segments: [("✓ Ready", green, promptFont)]),
    Line(segments: [("ahmed@ainkrad ", green, promptFont), ("~ % ", blue, promptFont)]),
]

let lineHeight: CGFloat = 40
let startX = contentRect.minX + 32
var startY = contentRect.maxY - 56
var lastLineEndX = startX
var lastLineBaselineY: CGFloat = startY

for line in lines {
    var x = startX
    let maxAscent = line.segments.map { $0.2.ascender }.max() ?? bodyFont.ascender
    let y = startY - maxAscent
    for (text, color, font) in line.segments {
        let attrs: [NSAttributedString.Key: Any] = [.font: font, .foregroundColor: color]
        let nsText = text as NSString
        nsText.draw(at: NSPoint(x: x, y: y), withAttributes: attrs)
        x += nsText.size(withAttributes: attrs).width
    }
    lastLineEndX = x
    lastLineBaselineY = y
    startY -= lineHeight
}

// Blinking cursor block after the final prompt.
let cursorRect = NSRect(x: lastLineEndX + 4, y: lastLineBaselineY, width: 11, height: promptFont.ascender * 0.9)
NSColor.white.withAlphaComponent(0.85).setFill()
cursorRect.fill()

NSGraphicsContext.restoreGraphicsState()

// MARK: - Write PNG

guard let pngData = rep.representation(using: .png, properties: [:]) else {
    FileHandle.standardError.write("Failed to encode PNG\n".data(using: .utf8)!)
    exit(1)
}

let scriptDir = URL(fileURLWithPath: #filePath).deletingLastPathComponent()
let outputURL = scriptDir.deletingLastPathComponent().appendingPathComponent("screenshots/terminal-1.png")

do {
    try FileManager.default.createDirectory(at: outputURL.deletingLastPathComponent(), withIntermediateDirectories: true)
    try pngData.write(to: outputURL)
    print("Wrote \(outputURL.path) (\(width)x\(height))")
} catch {
    FileHandle.standardError.write("Failed to write PNG: \(error)\n".data(using: .utf8)!)
    exit(1)
}
