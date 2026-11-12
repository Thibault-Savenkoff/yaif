// Quick Look thumbnails for .yaif (Finder, Spotlight, Quick Look): the 512 px PREV chunk when the
// file has one, else a full decode. Orientation is applied except for RAW (its preview is upright).
import Foundation
import QuickLookThumbnailing
import CoreImage
import AppKit

class ThumbnailProvider: QLThumbnailProvider {
  override func provideThumbnail(for request: QLFileThumbnailRequest,
                                 _ handler: @escaping (QLThumbnailReply?, Error?) -> Void) {
    guard let data = try? Data(contentsOf: request.fileURL, options: .mappedIfSafe),
          let cg = Self.image(data) else {
      handler(nil, NSError(domain: "yaif", code: 1)); return
    }
    // aspect fit inside maximumSize
    let m = request.maximumSize, w = CGFloat(cg.width), h = CGFloat(cg.height)
    let s = min(m.width / w, m.height / h)
    let size = CGSize(width: max(1, (w * s).rounded()), height: max(1, (h * s).rounded()))
    handler(QLThumbnailReply(contextSize: size, currentContextDrawing: {
      guard let ctx = NSGraphicsContext.current?.cgContext else { return false }
      ctx.interpolationQuality = .high
      ctx.draw(cg, in: CGRect(origin: .zero, size: size))
      return true
    }), nil)
  }

  static func image(_ data: Data) -> CGImage? {
    return data.withUnsafeBytes { (raw: UnsafeRawBufferPointer) -> CGImage? in
      guard let base = raw.bindMemory(to: UInt8.self).baseAddress else { return nil }
      var info = yaif_info()
      if yaif_read_info(base, data.count, &info) != 0 { return nil }
      var w: Int32 = 0, h: Int32 = 0
      var px: UnsafeMutablePointer<UInt8>? = nil
      if info.has_preview != 0 || info.raw != 0 {
        px = yaif_decode_preview(base, data.count, &w, &h)
      }
      if px == nil && info.raw == 0 {
        px = yaif_decode(base, data.count, &info)   // first frame is first in memory
        w = info.width; h = info.height
      }
      guard let p = px, w > 0, h > 0 else { return nil }
      let n = Int(w) * Int(h) * 4
      let buf = Data(bytes: p, count: n)
      free(p)
      guard let prov = CGDataProvider(data: buf as CFData),
            var img = CGImage(width: Int(w), height: Int(h), bitsPerComponent: 8, bitsPerPixel: 32,
                              bytesPerRow: Int(w) * 4, space: CGColorSpaceCreateDeviceRGB(),
                              bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.last.rawValue),
                              provider: prov, decode: nil, shouldInterpolate: true,
                              intent: .defaultIntent) else { return nil }
      if info.raw == 0 && info.orientation > 1 && info.orientation <= 8 {
        let ci = CIImage(cgImage: img).oriented(forExifOrientation: Int32(info.orientation))
        if let o = CIContext().createCGImage(ci, from: ci.extent) { img = o }
      }
      return img
    }
  }
}
