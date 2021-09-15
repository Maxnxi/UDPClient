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
