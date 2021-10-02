//
//  Extension_UIImage.swift
//  Waadsu
//
//  Created by Assylzhan Nurlybekuly on 18.09.2021.
//

import Foundation
import UIKit
import MobileCoreServices

extension UIImage {

    func toJpegData (compressionQuality: CGFloat, hasAlpha: Bool = true, orientation: Int = 6) -> Data? {
        guard cgImage != nil else { return nil }
        let options: NSDictionary =     [
            kCGImagePropertyOrientation: orientation,
            kCGImagePropertyHasAlpha: hasAlpha,
            kCGImageDestinationLossyCompressionQuality: compressionQuality
        ]
        return toData(options: options, type: .jpeg)
    }

    func toData (options: NSDictionary, type: ImageType) -> Data? {
        guard cgImage != nil else { return nil }
        return toData(options: options, type: type.value)
    }

    // about properties: https://developer.apple.com/documentation/imageio/1464962-cgimagedestinationaddimage
    func toData (options: NSDictionary, type: CFString) -> Data? {
        guard let cgImage = cgImage else { return nil }
        return autoreleasepool { () -> Data? in
            let data = NSMutableData()
            guard let imageDestination = CGImageDestinationCreateWithData(data as CFMutableData, type, 1, nil) else { return nil }
            CGImageDestinationAddImage(imageDestination, cgImage, options)
            CGImageDestinationFinalize(imageDestination)
            return data as Data
        }
    }

    // https://developer.apple.com/documentation/mobilecoreservices/uttype/uti_image_content_types
    enum ImageType {
        case image // abstract image data
        case jpeg                       // JPEG image
        case jpeg2000                   // JPEG-2000 image
        case tiff                       // TIFF image
        case pict                       // Quickdraw PICT format
        case gif                        // GIF image
        case png                        // PNG image
        case quickTimeImage             // QuickTime image format (OSType 'qtif')
        case appleICNS                  // Apple icon data
        case bmp                        // Windows bitmap
        case ico                        // Windows icon data
        case rawImage                   // base type for raw image data (.raw)
        case scalableVectorGraphics     // SVG image
        case livePhoto                  // Live Photo

        var value: CFString {
            switch self {
            case .image: return kUTTypeImage
            case .jpeg: return kUTTypeJPEG
            case .jpeg2000: return kUTTypeJPEG2000
            case .tiff: return kUTTypeTIFF
            case .pict: return kUTTypePICT
            case .gif: return kUTTypeGIF
            case .png: return kUTTypePNG
            case .quickTimeImage: return kUTTypeQuickTimeImage
            case .appleICNS: return kUTTypeAppleICNS
            case .bmp: return kUTTypeBMP
            case .ico: return kUTTypeICO
            case .rawImage: return kUTTypeRawImage
            case .scalableVectorGraphics: return kUTTypeScalableVectorGraphics
            case .livePhoto: return kUTTypeLivePhoto
            }
        }
    }
}

// Convert encodable structure to dictionary
extension Encodable {
  func asDictionary() throws -> [String: Any] {
    let data = try JSONEncoder().encode(self)
    guard let dictionary = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] else {
      throw NSError()
    }
    return dictionary
  }
}

// extension for using string subscript as in C++
extension StringProtocol {
    subscript(offset: Int) -> Character {
        self[index(startIndex, offsetBy: offset)]
    }
}

extension String {
    //: ### Base64 encoding a string
    func base64Encoded() -> String? {
        if let data = self.data(using: .utf8) {
            return data.base64EncodedString()
        }
        return nil
    }
    
    //: ### Base64 decoding a string
    func base64Decoded() -> String? {
        if let data = Data(base64Encoded: self) {
            return String(data: data, encoding: .utf8)
        }
        return nil
    }
    func toArrayofInt()->[Int]? {
        let array:[Int]? = self.compactMap { char in
            char == "0" ? 0 : char == "1" ? 1 : nil
        }
        return array
    }
}
extension Data {
    struct HexEncodingOptions: OptionSet {
        let rawValue: Int
        static let upperCase = HexEncodingOptions(rawValue: 1 << 0)
    }
    
    func hexEncodedString(options: HexEncodingOptions = []) -> String {
        let format = options.contains(.upperCase) ? "%02hhX" : "%02hhx"
        return self.map { String(format: format, $0) }.joined()
    }
}

// string.match() in JavaScript
func matches(for regex: String, in text: String) -> [String] {
    
    do {
        let regex = try NSRegularExpression(pattern: regex)
        let results = regex.matches(in: text,
                                    range: NSRange(text.startIndex..., in: text))
        return results.map {
            String(text[Range($0.range, in: text)!])
        }
    } catch let error {
        print("invalid regex: \(error.localizedDescription)")
        return []
    }
}
