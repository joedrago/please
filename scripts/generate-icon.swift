#!/usr/bin/env swift
// Generates a 1024x1024 PNG icon for Please.app
// Draws a rounded-rect with blue-to-indigo gradient and a white magnifying glass.

import AppKit
import CoreGraphics

let size: CGFloat = 1024
let outputPath = "scripts/icon_1024.png"

// Create bitmap context
let rep = NSBitmapImageRep(
    bitmapDataPlanes: nil,
    pixelsWide: Int(size),
    pixelsHigh: Int(size),
    bitsPerSample: 8,
    samplesPerPixel: 4,
    hasAlpha: true,
    isPlanar: false,
    colorSpaceName: .deviceRGB,
    bytesPerRow: 0,
    bitsPerPixel: 0
)!

NSGraphicsContext.saveGraphicsState()
let context = NSGraphicsContext(bitmapImageRep: rep)!
NSGraphicsContext.current = context
let cgContext = context.cgContext

// -- Background: rounded rect with gradient --
let cornerRadius: CGFloat = size * 0.22
let rect = CGRect(x: 0, y: 0, width: size, height: size)
let path = CGPath(roundedRect: rect, cornerWidth: cornerRadius, cornerHeight: cornerRadius, transform: nil)

cgContext.addPath(path)
cgContext.clip()

let colorSpace = CGColorSpaceCreateDeviceRGB()
let colors = [
    CGColor(red: 0.25, green: 0.47, blue: 0.95, alpha: 1.0), // Blue
    CGColor(red: 0.35, green: 0.22, blue: 0.82, alpha: 1.0), // Indigo
] as CFArray
let gradient = CGGradient(colorsSpace: colorSpace, colors: colors, locations: [0.0, 1.0])!
cgContext.drawLinearGradient(gradient, start: CGPoint(x: 0, y: size), end: CGPoint(x: size, y: 0), options: [])

// -- Magnifying glass (white) --
cgContext.setStrokeColor(CGColor(red: 1, green: 1, blue: 1, alpha: 1))
cgContext.setFillColor(CGColor(red: 1, green: 1, blue: 1, alpha: 0.15))
cgContext.setLineWidth(size * 0.055)
cgContext.setLineCap(.round)

// Glass circle — centered slightly above-left of center
let glassRadius: CGFloat = size * 0.22
let glassCenterX: CGFloat = size * 0.44
let glassCenterY: CGFloat = size * 0.56

cgContext.addEllipse(in: CGRect(
    x: glassCenterX - glassRadius,
    y: glassCenterY - glassRadius,
    width: glassRadius * 2,
    height: glassRadius * 2
))
cgContext.drawPath(using: .fillStroke)

// Handle — from bottom-right of circle outward at 45 degrees
let handleAngle: CGFloat = -.pi / 4 // 45 degrees down-right
let handleStart = CGPoint(
    x: glassCenterX + glassRadius * cos(handleAngle),
    y: glassCenterY + glassRadius * sin(handleAngle)
)
let handleLength: CGFloat = size * 0.22
let handleEnd = CGPoint(
    x: handleStart.x + handleLength * cos(handleAngle),
    y: handleStart.y + handleLength * sin(handleAngle)
)

cgContext.move(to: handleStart)
cgContext.addLine(to: handleEnd)
cgContext.strokePath()

NSGraphicsContext.restoreGraphicsState()

// Write PNG
guard let pngData = rep.representation(using: .png, properties: [:]) else {
    fputs("Error: Failed to create PNG data\n", stderr)
    exit(1)
}

let url = URL(fileURLWithPath: outputPath)
do {
    try pngData.write(to: url)
    print("Generated \(outputPath)")
} catch {
    fputs("Error writing PNG: \(error)\n", stderr)
    exit(1)
}
