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
    //let type: TypeOfPacket
    var dictionaryTmp: [String: Any] = [:]
    //var idsDev: Int
    //var imageBMP: UIImage? // todo check if BMP
    //var imageString64: String?
    //var sno: Int = 0

    
    init(type: TypeOfPacket) { //sno: Int = 4294901762, ids: Int = 4195311083
        //self.type = type
//        self.idsDev = ids
//        self.sno = sno
        
        if type == .devInfo {
            self.dictionaryTmp = devInfoRequest
        } else if type == .paramDev {
            self.dictionaryTmp = paramDevInfo
        } else if type == .pktsProgram {
            self.dictionaryTmp = pktsProgram
        }
    }
    
    func createBinaryStringFirstCheck(type: TypeOfPacket, sno: Int) -> [String] {
        let stringArr: [String] = ["0"]
        var sno = sno
        if type == .devInfo {
            let res = CodeLib.shared.parseJson(obj: dictionaryTmp, sno: &sno)
            guard let result = convertIntArrToStringArr(intArr: res) else {
                print("error in createBinaryString")
                return ["0"]
            }
            return result
        }
    return stringArr
    }
    
    func createBinaryStringGetParameters(type: TypeOfPacket, deviceId: String, sno: Int) -> [String] {
        let stringArr: [String] = ["0"]
        var sno = sno
        if type == .paramDev {
            dictionaryTmp["ids_dev"] = deviceId
            dictionaryTmp["sno"] = sno
            let res = CodeLib.shared.parseJson(obj: dictionaryTmp, sno: &sno)
            guard let result = convertIntArrToStringArr(intArr: res) else {
                print("error in createBinaryString")
                return ["0"]
            }
            return result
        }
        return stringArr
    }
    
    func createBinaryStringToSetImage(//self
                                        type: TypeOfPacket,isBmp: Int,
                                        //
                                        deviceId: String, sno: Int,
                                        //pkts_program
                                        idPro: Int = 1,
                                        //list_region
                                        //info_pos
                                        heightPos: Int = 64, weightPos: Int = 64, xPos: Int = 0, yPos: Int = 0,
                                        //list_item
                                        //info_animate
                                        modelNormal: Int = 1, speed: Int = 10, timeStay: Int = 3,
                                        //info_border
                                        borderValue: Int = 0,
                                        borderType: String = "fixed",
                                        //
                                        isGif: Int,/*IMPORTANT*/ typeItem: String = "graphic", image: UIImage, /*IMPORTANT*/
                                        //property_pro
                                        grayClr: Int = 4,
                                        heightPro: Int = 64,
                                        playLoop: Int = 1,
                                        sendGifSrc: Int, /*IMPORTANT*/
                                        timeSync: Int = 3,
                                        timeSyncEx: Int = 0,
                                        typeBackGround: Int = 0,
                                        typeColor: Int = 3, /*???*/
                                        typePro: Int = 0, /*???*/
                                        widthPro: Int = 64
        
        
                                        ) -> [String] {
        let stringArr: [String] = ["0"]
        var sno = sno
        if type == .pktsProgram {
            if isBmp == 1 {
                let zipFormatString: String = "zip_bmp"
                //convert image to base64String
                guard let imageData: Data = image.toData(options: [:], type: .bmp) else { return ["0"] }
                let imageString64 = imageData.base64EncodedString()
                //
                dictionaryTmp["ids_dev"] = deviceId
                dictionaryTmp["sno"] = sno
                
                guard var pktsProgram = dictionaryTmp["pkts_program"] as? [String: Any],
                      let listRegion = pktsProgram["list_region"] as? [[String: Any]],
                      var propertyPro = pktsProgram["property_pro"] as? [String: Any],
                      var infoPos = listRegion.first?["info_pos"] as? [String: Any],
                      var listItem = listRegion.first?["list_item"] as? [[String: Any]],
                      var listItemFirst = listItem.first as? [String: Any],
                      var infoAnimate = listItem.first?["info_animate"] as? [String: Any],
                      var infoBorder = listItem.first?["info_border"] as? [String: Any],
                      var zipImg = listItem.first else { return ["0"] }
                //zipImg["zip_bmp"] = image
                //pkts_program
                pktsProgram["id_pro"] = idPro
                //list_region
                //info_pos
                infoPos["h"] = heightPos
                infoPos["w"] = weightPos
                infoPos["x"] = xPos
                infoPos["y"] = yPos
                
                //list_item
                //info_animate
                infoAnimate["model_normal"] = modelNormal
                infoAnimate["speed"] = speed
                infoAnimate["time_stay"] = timeStay
                
                //info_border
                infoBorder["fixed_value"] = borderValue
                infoBorder["type"] = borderType
                //
                listItemFirst["isGif"] = isGif
                listItemFirst["type_item"] = typeItem
                listItemFirst[zipFormatString] = imageString64
                
                //property_pro
                propertyPro["gray"] = grayClr
                propertyPro["height"] = heightPro
                propertyPro["play_loop"] = playLoop
                propertyPro["send_gif_src"] = sendGifSrc
                propertyPro["time_sync"] = timeSync
                propertyPro["time_sync_ex"] = timeSyncEx
                propertyPro["type_bg"] = typeBackGround
                propertyPro["type_color"] = typeColor
                propertyPro["type_pro"] = typePro
                propertyPro["width"] = widthPro
                
                
                let res = CodeLib.shared.parseJson(obj: dictionaryTmp, sno: &sno)
                guard let result = convertIntArrToStringArr(intArr: res) else {
                    print("error in createBinaryString")
                    return ["0"]
                }
                return result
                
            } else if isBmp == 0 {
                
            }
        }
        
        return stringArr
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

