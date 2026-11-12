// Decodes a .yaif with the same code as the extension and writes a PNG: swift selftest.swift's check.
import Foundation
import ImageIO
import UniformTypeIdentifiers

@main struct SelfTest {
  static func main() {
    let a = CommandLine.arguments
    guard a.count == 3, let d = try? Data(contentsOf: URL(fileURLWithPath: a[1])) else { print("usage: selftest in.yaif out.png"); exit(2) }
    guard let img = ThumbnailProvider.image(d) else { print("decode FAILED"); exit(1) }
    print("decoded \(img.width)x\(img.height)")
    let out = CGImageDestinationCreateWithURL(URL(fileURLWithPath: a[2]) as CFURL, UTType.png.identifier as CFString, 1, nil)!
    CGImageDestinationAddImage(out, img, nil)
    print(CGImageDestinationFinalize(out) ? "wrote \(a[2])" : "write FAILED")
  }
}
