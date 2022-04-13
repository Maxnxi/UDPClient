//
//  IntReader.swift
//  wifiUDPListener2
//
//  Created by Maksim on 13.09.2021.
//

import Foundation

class IntReader {
   
    func readUInt32LE(arrayOfInts ints: [UInt8], offset: Int = 0) -> Int? {
        guard offset >= 0,
              offset+3 <= ints.count else {
            print("Error in readUInt32LE - out of range")
            return nil
        }
        //вариант 2
        var str = ""
        str += String(ints[offset+3])
        str += String(ints[offset+2])
        str += String(ints[offset+1])
        str += String(ints[offset])
        // возвращаем в десятичном формате
        return Int(str)
    }
    
    func readInt16LE(arrayOfInts ints: [UInt8], offset: Int = 0) -> Int? {
        guard offset >= 0,
              offset+1 <= ints.count else {
            print("Error in readInt16LE - out of range")
            return nil
        }
        //version 2
        var str = ""
        str += String(ints[offset+1])
        str += String(ints[offset])
        return Int(str)
    }

    
    func EXreadUInt16LE(arrayOfInts ints: [Int], offset: Int = 0) -> UInt16? {
        
        return nil
    }
    
    func readUInt8(arrayOfInts ints: [UInt8], offset: Int = 0) -> UInt8? {
        guard offset >= 0,
              offset <= ints.count else {
            print("Error in readUInt8 - out of range")
            return nil
        }
        let obj = ints[offset]
        if obj < 0 {
            var result = obj
            repeat {
                result = 255 - (obj+1)
            } while (result < 0)
            print("readUInt8 is ok - ", result)
            return result
        } else if obj > 255 {
            print("Error in readUInt8: obj - is more than 255 - ", obj)
            return 255
        } else {
            print("readUInt8 is ok - ", obj)
            return obj
        }
    }

}
