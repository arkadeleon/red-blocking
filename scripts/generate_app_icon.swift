import AppKit

private extension NSColor {
    convenience init(hex: Int, alpha: CGFloat = 1) {
        let red = CGFloat((hex >> 16) & 0xFF) / 255
        let green = CGFloat((hex >> 8) & 0xFF) / 255
        let blue = CGFloat(hex & 0xFF) / 255
        self.init(calibratedRed: red, green: green, blue: blue, alpha: alpha)
    }
}

private extension NSBezierPath {
    static func polygon(_ points: [CGPoint], closed: Bool = true) -> NSBezierPath {
        let path = NSBezierPath()
        guard let first = points.first else { return path }
        path.move(to: first)
        for point in points.dropFirst() {
            path.line(to: point)
        }
        if closed {
            path.close()
        }
        return path
    }
}

private struct Palette {
    let black = NSColor(hex: 0x050506)
    let coal = NSColor(hex: 0x141114)
    let burgundy = NSColor(hex: 0x451013)
    let crimson = NSColor(hex: 0xB41221)
    let red = NSColor(hex: 0xEE2B2D)
    let orange = NSColor(hex: 0xFF6B1A)
    let gold = NSColor(hex: 0xFFB515)
    let ivory = NSColor(hex: 0xF5E6C9)
    let sand = NSColor(hex: 0xD6B88C)
}

private let palette = Palette()
private let canvasSize: CGFloat = 1024

private func point(_ x: CGFloat, _ y: CGFloat) -> CGPoint {
    CGPoint(x: x, y: y)
}

private func withShadow(color: NSColor, blur: CGFloat, offset: CGSize = .zero, draw: () -> Void) {
    NSGraphicsContext.saveGraphicsState()
    let shadow = NSShadow()
    shadow.shadowColor = color
    shadow.shadowBlurRadius = blur
    shadow.shadowOffset = offset
    shadow.set()
    draw()
    NSGraphicsContext.restoreGraphicsState()
}

private func clipAndDraw(_ path: NSBezierPath, angle: CGFloat, colors: [NSColor]) {
    NSGraphicsContext.saveGraphicsState()
    path.addClip()
    NSGradient(colors: colors)?.draw(in: path.bounds, angle: angle)
    NSGraphicsContext.restoreGraphicsState()
}

private func fill(_ path: NSBezierPath, color: NSColor) {
    color.setFill()
    path.fill()
}

private func drawHalftone(in rect: CGRect, step: CGFloat, maxRadius: CGFloat, color: NSColor, fadeTowardTop: Bool = false) {
    for row in stride(from: rect.minY, through: rect.maxY, by: step) {
        for column in stride(from: rect.minX, through: rect.maxX, by: step) {
            let xOffset = ((Int((row - rect.minY) / step) % 2) == 0) ? 0 : step * 0.5
            let center = point(column + xOffset, row)
            let horizontalRatio = max(0, min(1, (center.x - rect.minX) / max(1, rect.width)))
            let verticalRatio = max(0, min(1, (center.y - rect.minY) / max(1, rect.height)))
            let ratio = fadeTowardTop ? (horizontalRatio * (1 - verticalRatio)) : horizontalRatio
            let radius = maxRadius * ratio
            if radius < 1.2 { continue }
            let dotRect = CGRect(x: center.x - radius, y: center.y - radius, width: radius * 2, height: radius * 2)
            fill(NSBezierPath(ovalIn: dotRect), color: color)
        }
    }
}

private func drawBackground(in rect: CGRect) {
    clipAndDraw(NSBezierPath(rect: rect), angle: -28, colors: [
        palette.burgundy,
        palette.black
    ])

    let leftBurst = NSBezierPath.polygon([
        point(0, 1024),
        point(0, 624),
        point(312, 750),
        point(574, 600),
        point(736, 1024)
    ])
    clipAndDraw(leftBurst, angle: -18, colors: [
        palette.gold,
        palette.orange,
        palette.red
    ])

    let upperFlash = NSBezierPath.polygon([
        point(126, 1024),
        point(436, 1024),
        point(700, 690),
        point(520, 624),
        point(298, 768)
    ])
    clipAndDraw(upperFlash, angle: -42, colors: [
        NSColor.white.withAlphaComponent(0.82),
        palette.gold.withAlphaComponent(0.86),
        palette.orange.withAlphaComponent(0.94)
    ])

    let lowerBand = NSBezierPath.polygon([
        point(0, 0),
        point(0, 248),
        point(596, 434),
        point(1024, 340),
        point(1024, 0)
    ])
    fill(lowerBand, color: palette.black.withAlphaComponent(0.90))

    let rightInk = NSBezierPath.polygon([
        point(474, 0),
        point(1024, 0),
        point(1024, 700),
        point(868, 660),
        point(700, 594),
        point(590, 460)
    ])
    fill(rightInk, color: NSColor.black.withAlphaComponent(0.58))

    let diagonalStripe1 = NSBezierPath.polygon([
        point(-30, 286),
        point(94, 286),
        point(420, 0),
        point(294, 0)
    ])
    fill(diagonalStripe1, color: palette.red.withAlphaComponent(0.18))

    let diagonalStripe2 = NSBezierPath.polygon([
        point(520, 1024),
        point(658, 1024),
        point(1024, 724),
        point(1024, 600)
    ])
    fill(diagonalStripe2, color: palette.orange.withAlphaComponent(0.16))

    drawHalftone(
        in: CGRect(x: 10, y: 548, width: 420, height: 368),
        step: 26,
        maxRadius: 8,
        color: palette.black.withAlphaComponent(0.22),
        fadeTowardTop: false
    )

    drawHalftone(
        in: CGRect(x: 602, y: 174, width: 332, height: 300),
        step: 24,
        maxRadius: 7,
        color: palette.ivory.withAlphaComponent(0.12),
        fadeTowardTop: true
    )

    for index in 0..<9 {
        let y = 132 + CGFloat(index) * 34
        let path = NSBezierPath()
        path.move(to: point(0, y))
        path.line(to: point(746, y + 76))
        path.lineWidth = 4
        path.lineCapStyle = .square
        palette.ivory.withAlphaComponent(0.035).setStroke()
        path.stroke()
    }
}

private func drawBurst(center: CGPoint) {
    let burst = NSBezierPath.polygon([
        point(center.x - 30, center.y + 330),
        point(center.x + 80, center.y + 188),
        point(center.x + 300, center.y + 230),
        point(center.x + 178, center.y + 52),
        point(center.x + 350, center.y - 98),
        point(center.x + 130, center.y - 112),
        point(center.x + 104, center.y - 344),
        point(center.x - 16, center.y - 176),
        point(center.x - 238, center.y - 256),
        point(center.x - 150, center.y - 30),
        point(center.x - 352, center.y + 76),
        point(center.x - 126, center.y + 106)
    ])
    clipAndDraw(burst, angle: -56, colors: [
        palette.orange,
        palette.red,
        palette.crimson
    ])

    let burstEcho = NSBezierPath.polygon([
        point(center.x - 84, center.y + 284),
        point(center.x + 16, center.y + 160),
        point(center.x + 246, center.y + 196),
        point(center.x + 128, center.y + 38),
        point(center.x + 286, center.y - 82),
        point(center.x + 88, center.y - 98),
        point(center.x + 76, center.y - 302),
        point(center.x - 26, center.y - 142),
        point(center.x - 212, center.y - 208),
        point(center.x - 126, center.y - 4),
        point(center.x - 304, center.y + 78),
        point(center.x - 102, center.y + 96)
    ])
    fill(burstEcho, color: palette.gold.withAlphaComponent(0.42))

    let ring = NSBezierPath(ovalIn: CGRect(x: center.x - 248, y: center.y - 248, width: 496, height: 496))
    palette.ivory.withAlphaComponent(0.16).setStroke()
    ring.lineWidth = 12
    ring.stroke()
}

private func drawPlate(_ path: NSBezierPath, stroke: NSColor) {
    clipAndDraw(path, angle: -90, colors: [
        palette.ivory,
        palette.sand
    ])
    stroke.setStroke()
    path.lineWidth = 10
    path.lineJoinStyle = .miter
    path.stroke()
}

private func drawEmblem(center: CGPoint) {
    let rightShadow = NSBezierPath.polygon([
        point(center.x + 118, center.y - 200),
        point(center.x + 270, center.y - 200),
        point(center.x + 458, center.y),
        point(center.x + 270, center.y + 200),
        point(center.x + 118, center.y + 200),
        point(center.x + 244, center.y)
    ])
    fill(rightShadow, color: palette.gold.withAlphaComponent(0.34))

    let rightOffset = NSBezierPath.polygon([
        point(center.x + 82, center.y - 186),
        point(center.x + 232, center.y - 186),
        point(center.x + 416, center.y),
        point(center.x + 232, center.y + 186),
        point(center.x + 82, center.y + 186),
        point(center.x + 202, center.y)
    ])
    fill(rightOffset, color: palette.red.withAlphaComponent(0.42))

    let leftPlate = NSBezierPath.polygon([
        point(center.x - 304, center.y - 194),
        point(center.x - 92, center.y - 194),
        point(center.x - 28, center.y),
        point(center.x - 92, center.y + 194),
        point(center.x - 304, center.y + 194)
    ])

    let rightPlate = NSBezierPath.polygon([
        point(center.x + 28, center.y - 194),
        point(center.x + 178, center.y - 194),
        point(center.x + 362, center.y),
        point(center.x + 178, center.y + 194),
        point(center.x + 28, center.y + 194),
        point(center.x + 146, center.y)
    ])

    let seam = NSBezierPath.polygon([
        point(center.x - 36, center.y - 276),
        point(center.x + 22, center.y - 84),
        point(center.x + 68, center.y),
        point(center.x + 24, center.y + 84),
        point(center.x - 40, center.y + 276),
        point(center.x - 92, center.y + 88),
        point(center.x - 128, center.y),
        point(center.x - 86, center.y - 88)
    ])

    withShadow(color: NSColor.black.withAlphaComponent(0.36), blur: 24, offset: CGSize(width: 0, height: -12)) {
        drawPlate(leftPlate, stroke: palette.black.withAlphaComponent(0.14))
        drawPlate(rightPlate, stroke: palette.black.withAlphaComponent(0.18))
    }

    fill(
        NSBezierPath(roundedRect: CGRect(x: center.x - 242, y: center.y - 126, width: 30, height: 252), xRadius: 8, yRadius: 8),
        color: palette.black.withAlphaComponent(0.14)
    )

    fill(
        NSBezierPath(roundedRect: CGRect(x: center.x + 108, y: center.y - 102, width: 24, height: 204), xRadius: 8, yRadius: 8),
        color: palette.black.withAlphaComponent(0.12)
    )

    clipAndDraw(seam, angle: -90, colors: [
        palette.gold,
        palette.red,
        palette.crimson
    ])
    palette.ivory.withAlphaComponent(0.54).setStroke()
    seam.lineWidth = 6
    seam.stroke()

    let slash = NSBezierPath()
    slash.move(to: point(center.x - 248, center.y + 264))
    slash.line(to: point(center.x + 302, center.y - 266))
    slash.lineWidth = 12
    slash.lineCapStyle = .square
    withShadow(color: palette.orange.withAlphaComponent(0.26), blur: 10) {
        palette.ivory.withAlphaComponent(0.56).setStroke()
        slash.stroke()
    }

    for (start, end) in [
        (point(center.x - 188, center.y + 234), point(center.x - 120, center.y + 316)),
        (point(center.x + 190, center.y - 198), point(center.x + 290, center.y - 292)),
        (point(center.x + 238, center.y + 124), point(center.x + 332, center.y + 184))
    ] {
        let spark = NSBezierPath()
        spark.move(to: start)
        spark.line(to: end)
        spark.lineWidth = 12
        spark.lineCapStyle = .round
        palette.gold.withAlphaComponent(0.86).setStroke()
        spark.stroke()
    }
}

private func drawTopStamp() {
    let stamp = NSBezierPath.polygon([
        point(0, 1024),
        point(418, 1024),
        point(260, 856),
        point(0, 904)
    ])
    fill(stamp, color: NSColor.white.withAlphaComponent(0.12))

    let accent = NSBezierPath.polygon([
        point(726, 1024),
        point(1024, 1024),
        point(1024, 910),
        point(810, 876)
    ])
    fill(accent, color: palette.red.withAlphaComponent(0.18))
}

private func writePNG(to path: String) throws {
    let rect = CGRect(x: 0, y: 0, width: canvasSize, height: canvasSize)
    let image = NSImage(size: rect.size)
    image.lockFocus()
    guard let context = NSGraphicsContext.current?.cgContext else {
        throw NSError(domain: "GenerateAppIcon", code: 1)
    }

    context.interpolationQuality = .high
    context.setAllowsAntialiasing(true)

    drawBackground(in: rect)
    drawTopStamp()
    let center = point(canvasSize / 2 - 8, canvasSize / 2 - 10)
    drawBurst(center: center)
    drawEmblem(center: center)

    image.unlockFocus()

    guard
        let tiff = image.tiffRepresentation,
        let rep = NSBitmapImageRep(data: tiff),
        let png = rep.representation(using: .png, properties: [:])
    else {
        throw NSError(domain: "GenerateAppIcon", code: 2)
    }

    let outputURL = URL(fileURLWithPath: path)
    try FileManager.default.createDirectory(at: outputURL.deletingLastPathComponent(), withIntermediateDirectories: true)
    try png.write(to: outputURL)
}

let defaultOutput = "RedBlocking/Assets.xcassets/AppIcon.appiconset/AppIcon.png"
let outputPath = CommandLine.arguments.dropFirst().first ?? defaultOutput

do {
    try writePNG(to: outputPath)
    print("Wrote \(outputPath)")
} catch {
    fputs("Failed to generate icon: \(error)\n", stderr)
    exit(1)
}
