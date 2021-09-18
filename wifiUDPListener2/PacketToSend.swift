//
//  PacketToSend.swift
//  wifiUDPListener2
//
//  Created by Maksim on 17.09.2021.
//

import Foundation
import UIKit

enum TypeOfPacket {
    case devInfo, paramDev, pktsProgram
}

class CreateBinaryPacketToSend {
    let type: TypeOfPacket
    var dictionaryTmp: [String: Any] = [:]
    var idsDev: Int
    var imageBMP: UIImage? // todo check if BMP
    var imageString64: String?
    var sno: Int = 0

    
    init(type: TypeOfPacket, sno: Int = 4294901762, ids: Int = 4195311083, imageBMP: UIImage = UIImage()){
        self.type = type
        self.idsDev = ids
        self.sno = sno
        //convert image to base64String
        self.imageBMP = imageBMP
        guard let imageData: Data = imageBMP.toData(options: [:], type: .bmp) else { return }
        self.imageString64 = imageData.base64EncodedString()
        //
        if type == .devInfo {
            self.dictionaryTmp = devInfoRequest
        } else if type == .paramDev {
            self.dictionaryTmp = paramDevInfo
        } else if type == .pktsProgram {
            self.dictionaryTmp = pktsProgram
        }
    }
    
    func createBinaryString() -> [String] {
        var stringArr: [String] = []
        if type == .devInfo {
            let res = CodeLib.shared.parseJson(obj: dictionaryTmp, sno: &sno)
            guard let result = convertIntArrToStringArr(intArr: res) else {
                print("error in createBinaryString")
                return ["0"]
            }
            return result
        } else if type == .paramDev {
            let idDevice = String(describing: idsDev)
            print("id`Device is - ", idDevice)
            dictionaryTmp["ids_dev"] = idDevice
            let res = CodeLib.shared.parseJson(obj: dictionaryTmp, sno: &sno)
            guard let result = convertIntArrToStringArr(intArr: res) else {
                print("error in createBinaryString")
                return ["0"]
            }
            return result
        } else if type == .pktsProgram && imageString64 != nil {
            
            let idDevice = String(describing: idsDev)
            print("id`Device is - ", idDevice)
            dictionaryTmp["ids_dev"] = idDevice
            if let image = imageString64 {
                guard let pktsProgram = dictionaryTmp["pkts_program"] as? [String: Any],
                      let listRegion = pktsProgram["list_region"] as? [[String: Any]],
                      let listItem = listRegion.first?["list_item"] as? [[String: Any]],
                      var zipImg = listItem.first else { return ["0"] }
                zipImg["zip_bmp"] = image
            } else {
                print("Error - with imageString64 ")
            }
            let res = CodeLib.shared.parseJson(obj: dictionaryTmp, sno: &sno)
            guard let result = convertIntArrToStringArr(intArr: res) else {
                print("error in createBinaryString")
                return ["0"]
            }
            return result
        }
    return stringArr
    }
    
    func createBinaryStringToSetImage() {
        
    }
    
    //sub-function
    func convertIntArrToStringArr(intArr: [[Int]]?) -> [String]? {
        guard let pkts = intArr else {
            print("Error in convertIntArrToStringArr")
            return nil
        }
        //var str = ""
        var output: [String] = []
        for element in pkts {
            let stringFormatted = element.map({ (String(format: "%02X", $0)) })
            output.append(stringFormatted.joined())
//            element.forEach { str += String(format:"%02X", $0) }
//            output.append(str)
//            str = ""
        }
        print("\(output) <- My Output")
        return output
    }
    
}

let devInfoRequest = [
                    "cmd": [
                        "get": "dev_info"
                        ]
                    ]

let paramDevInfo: [String: Any] = [
                    "cmd": [
                        "get": "param_dev"
                        ],
                    "ids_dev": "4195311083",
                    "sno": 2
                    ]
let pktsProgram: [String: Any] = [
                    "ids_dev": "4195311083",
                    "pkts_program": [
                        "id_pro": 1,
                        "list_region": [
                            [
                                "info_pos": [
                                    "h": 64,
                                    "w": 64,
                                    "x": 0,
                                    "y": 0
                                ],
                                "list_item": [
                                [
                                    "info_animate": [
                                        "model_normal": 1,
                                        "speed": 10,
                                        "time_stay": 3
                                    ],
                                    "info_border": [
                                        "fixed_value": 0,
                                        "type": "fixed"
                                    ],
                                    "isGif": 0,
                                    "type_item": "graphic",
                                    "zip_bmp": " "
                                    ]
                                ]
                            ]
                        ],
                        "property_pro": [
                            "gray": 4,
                            "height": 64,
                            "play_loop": 1,
                            "send_gif_src": 0,
                            "time_sync": 3,
                            "time_sync_ex": 0,
                            "type_bg": 0,
                            "type_color": 3,
                            "type_pro": 0,
                            "width": 64
                        ]
                    ],
                    "sno": 4294901762
                ]

