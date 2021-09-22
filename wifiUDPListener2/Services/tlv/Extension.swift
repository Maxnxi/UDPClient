//
//  Extension.swift
//  wifiUDPListener2
//
//  Created by Maksim on 13.09.2021.
//

import Foundation

// extension for using string subscript as in C++
extension StringProtocol {
    subscript(offset: Int) -> Character {
        self[index(startIndex, offsetBy: offset)]
    }
}

extension String {
////: ### Base64 encoding a string
//    func base64Encoded() -> String? {
//        if let data = self.data(using: .utf8) {
//            return data.base64EncodedString()
//        }
//        return nil
//    }

//: ### Base64 decoding a string
    //
    /*func base64Decoded() -> String? {
        if let data = Data(base64Encoded: self) {
            return String(data: data, encoding: .utf8)
        }
        return nil
    }
 */

    // convert String to array of 1.0
    func convertToArrayofInt() -> [Int]? {
        let array: [Int]? = self.compactMap { char in
            //char == "0" ? 0 : char == "1" ? 1 : nil
            if char == "0" {
                return 0
            } else if char == "1" {
                return 1
            } else {
                return nil
            }
        }
        return array
    }
}

extension Array where Element == Int {
    public mutating func writeInt(value: Int, bytes: Int, direction: String? = nil) {
        let dir: Int = direction != nil && direction == "BE" ? 1 : 0
//        if (direction != nil && direction == "BE") {
//            dir = 1
//        }
        if dir == 0 {
            for idx in 0..<bytes {
                self.append((value >> (8 * idx)) & 0xFF)
            }
        } else {
            for idx in (0..<bytes-1).reversed() {
            //for (let idx=bytes -1; idx >= 0; idx --){
                self.append((value >> (8 * idx)) & 0xFF)
            }
        }
    }
}
