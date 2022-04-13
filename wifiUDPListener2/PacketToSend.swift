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
    
//    func createBinaryStringFirstCheck(type: TypeOfPacket, sno: Int) -> [String] {
//        let stringArr: [String] = ["0"]
//        var sno = sno
//        if type == .devInfo {
//            let res = CodeLib.shared.parseJson(obj: dictionaryTmp, sno: &sno)
//            guard let result = convertIntArrToStringArr(intArr: res) else {
//                print("error in createBinaryString")
//                return ["0"]
//            }
//            return result
//        }
//    return stringArr
//    }
//
//    func createBinaryStringGetParameters(type: TypeOfPacket, deviceId: String, sno: Int) -> [String] {
//        let stringArr: [String] = ["0"]
//        var sno = sno
//        if type == .paramDev {
//            dictionaryTmp["ids_dev"] = deviceId
//            dictionaryTmp["sno"] = sno
//            let res = CodeLib.shared.parseJson(obj: dictionaryTmp, sno: &sno)
//            guard let result = convertIntArrToStringArr(intArr: res) else {
//                print("error in createBinaryString")
//                return ["0"]
//            }
//            return result
//        }
//        return stringArr
//    }
    
    func createBinaryStringToSetImage(//self
                                        type: TypeOfPacket,isBmp: Int,
                                        //sno: Int = 4294901762, ids: Int = 4195311083
                                        deviceId: String = "4195311083", sno: Int = 4294901762,
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
                guard let imageData: Data = image.toData(options: [:], type: .bmp) else {
                    print("Error #5 in imageData ")
                    return ["0"]
                }
                let imageString64 = imageData.base64EncodedString()// base64EncodedString()
                print("imageString64", imageString64)
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
                
                
                //let res = CodeLib.shared.parseJson(obj: dictionaryTmp, sno: &sno)
                //let res = tlv.shared.parseJson(dictionaryTmp, &sno)
                //guard let result = convertIntArrToStringArr(intArr: res) else {
//                        print("error in createBinaryStringToSetImage")
//                        return ["0"]
//                }
//                return result
                
            } else if isBmp == 0 {
                print("Not done yet!")
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
        var str = ""
        var output: [String] = []
        for element in pkts {
            //version #3
            //let stringFormatted = element.map({ (String(format: "%02X", $0)) })
            //output.append(stringFormatted.joined())
            //version #2
//            element.forEach { str += String(format:"%02X", $0) }
//            output.append(str)
//            str = ""
            //version #1
            for byte in element {
                str += String(format:"%02X", byte)
            }
            output.append(str)
            str = ""
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
                                    "zip_bmp": "Qk2KQAAAAAAAAIoAAAB8AAAAQAAAAMD///8BACAAAwAAAABAAAAAAAAAAAAAAAAAAAAAAAAAAAD/AAD/AAD/AAAAAAAA/0JHUnMAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////Cv77/vLy7/9TT1P/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////s7Oz/xMHB/8TBwf/s7Oz///////T09P/Jxsf/xL/A/8TBwf/EwcH/xMHB/8TBwf/EwcH/xMHB/8TBwf/EwcH/xMHB/8TBwf/EwcH/xMHB/8S/wP/l5eT//////////////////////+zs7P/EwcH/xMHB//Dv7/////////////////////////////T09P+3vLn/KUk9/wMQCv9mZWP/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////uLe2/woQDP8TKS7/j5ea/9HMzP+0s7L/KUk9/xY7Lv8WOy7/Fjsu/xY7Lv8WOy7/Fjsu/xY7Lv8WOy7/Fjsu/xY7Lv8WOy7/Fjsu/xY7Lv8WOy7/c4N8/9HMzP/Nycr/zcnK/9HMzP+Pl5r/Eyku/xIQDv/EwcH//////////////////////+Xl5P+Lh4n/Eh0X/zPrtP8JPy3/ZFxd/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////7Szsv8LEhL/IXWW/x1ZYf8dNy3/JFpH/zTdrP8z67T/M+u0/zPrtP8z67T/M+u0/zPrtP8z67T/M+u0/zPrtP8z67T/M+u0/zPrtP8z67T/M+u0/zWRdP8dNy3/HT0x/x09Mf8TFBD/HERV/yiMt/8LEhL/vLy7/////////////////9zc3P9zg3z/EjQo/x1DNf859b7/C0Uy/2RcXf////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////+0s7L/CQoG/xMpLv8usYr/M+u0/zPrtP82977/NvrB/zb6wf82+sH/NvrB/zb6wf82+sH/NvrB/zb5vv82+sH/NvrB/zb6wf82+sH/NvrB/zb5vv82977/Muey/zLnsv82977/F19F/x1ZYf8poLz/CxIS/8K/vv///////////+zs7P9CPj3/I45s/zXuuv8z67T/Of7E/wk/Lf9kXF3/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////tLOy/woaDf8xzJ3/Nve+/zb6wf82+sH/Nve+/zPrtP8y6q3/Muqt/zLqrf8y6q3/Muqt/zPrtP82+sH/Nve+/zb3vv82977/Nve+/zb3vv82977/Nvm+/zb5vv82+b7/NvrB/zPrtP817rr/M9Kj/xEoFf+srKv/9PT0///////s7Oz/Ky0r/xyOa/86/8v/NvrB/zn+xP8JPy3/ZFxd////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////9PT0/6ysq/8WLyT/NOKt/zb6wf82977/Nve+/zPrtP8pq2H/IZNF/yGTRf8hk0X/IZNF/yGTRf8lrW3/Nve+/zb3vv82977/Nve+/zb3vv82977/Nve+/zb3vv82977/Nve+/zb3vv82+b7/NvrB/zPlpP8UfDD/ESgV/4uHif//////7Ozs/0I+Pf8jjmz/Nve+/zPrtP85/sT/FE47/2ZlY//09PT//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////3Vycf8cTj3/M+u0/zb3vv82977/Nve+/zPlpP8mm1H/o9i7/9Hy6f/N8ub/zfLm/83y5v/R8un/lc+t/xqZTP8z67T/Nve+/zb3vv82977/Nve+/zb3vv82977/Nve+/zb3vv82977/Nve+/zb6wf804q3/Eow8/wAgBP96dnb////////////s7Oz/bXp1/wYiGP8SNCj/M+u0/zXuuv8qlnX/Qj49//T09P////////////////////////////////////////////////////////////////////////////////////////////////////////////////9kXF3/C0Uy/zn+xP82+b7/NvrB/yfMhP8xnU//vOXR/978+f/j/v7/3vz5/978+f/e/Pn/3vz5/9759P+y4cv/IZNF/yzXkv82+sH/Nve+/zb3vv82977/Nve+/zb3vv82977/Nve+/zb3vv82977/Nve+/zLqrf8XlUz/FkUf/0xNTP/w7+///////+zs7P+cl5j/Eh0X/zTirf86/8v/I5p0/y0kI//09PT///////////////////////////////////////////////////////////////////////////////////////////////////////////9DRD7/Kots/zPrtP82+b7/Nvm+/zn+xP8jwHX/MJJI/9Hy6f/j/v7/i5qX/ystK/8sNTD/Ky0r/yUqJf9tenX/0PLm/yCIOf8s1I3/NvrB/zb3vv82977/Nve+/zb3vv82977/Nve+/zb3vv82977/Nve+/zb3vv82977/GqhZ/wZCFP8JCgb/JSol/yUqJf+dn57/9PT0/8bIx/8dNy3/MsaY/yWifP8xLiv/7fDw////////////////////////////////////////////////////////////////////////////////////////////////////////////KBwc/yOObP86/8v/Nve+/zb6wf8btmn/XbJ8/8Tt3f/d9vL/Ym1p/05XTf9+h3X/fod1/xIQDv8AAAD/ExQQ/y1CNf8Peir/LNSN/zb6wf82977/Nve+/zb3vv82977/Nve+/zb3vv82977/Nve+/zb3vv82977/Nve+/zLqrf8dp2T/F4I8/y3Flf8u0aH/PHtl/zU0Mv81NDL/AAAA/y6xiv82977/NrWQ/zxFQP/U09T//////////////////////////////////////////////////////////////////////////////////////////////////////y0kI/8jk3D/Of7E/zb3vv82+sH/E6RU/2Wyff/j/v7/3vn0/zw7O/9DRD7/i5iC/yUqJf8ECgT/AAAA/wAAAP8ECgT/EHMq/yzUjf82+sH/Nve+/zb3vv82977/Nve+/zb3vv82977/Nve+/zb3vv82977/Nve+/zb3vv85/sT/Muqt/zPlpP82+b7/NvrB/zPYpf8uu4//LruP/zS+lf856LX/Of7E/y7Rof8KEAz/ycbH////////////////////////////////////////////////////////////////////////////////////////////3Nzc/0xNTP8zqIP/NOKt/zb6wf82977/NvrB/xOkVP9lsn3/4/7+/9759P88RUD/ExQQ/yUqJf8AAAD/AAAA/wAAAP8AAAD/CBEH/w96Kv8s1I3/NvrB/zb3vv82977/Nve+/zb3vv82977/Nve+/zb3vv82977/Nve+/zb3vv82977/NvrB/yisg/8cTj3/FE47/xROO/8UTjv/FE47/xxlTf808bf/NvrB/zb6wf8xzJ3/ExQQ/8nGx///////////////////////////////////////////////////////////////////////////////////////tLOy/0I+Pf8AAAD/M9Kj/zb6wf82977/Nve+/zb3vv8u5aP/OL19/2i1gf/N8ub/RkhF/wAAAP8AAAD/AAAA/wAAAP8AAAD/AAAA/wgRB/8Peir/LNSN/zb6wf82977/Nve+/zb3vv82977/Nve+/zb3vv82977/Nve+/zb3vv82977/Nve+/zb6wf8lrW3/C1Mb/wtTG/8ECgT/ZFxd/7Krrf+joJ//JFpH/xROO/8UTjv/MmBR/6ysq//s7Oz/////////////////////////////////////////////////////////////////////////////////i4eJ/zJVOP8GQhT/BAoE/zPSo/82+sH/Nve+/zb3vv82977/NvrB/yPEef8wkkj/zfLm/7TFxv9VVlT/AAAA/wAAAP8AAAD/AAAA/wUcC/8SZiv/KcV//zLqrf82+b7/Nve+/zb3vv82977/Nve+/zb3vv82977/Nve+/zb3vv82977/Nve+/zb3vv82+sH/LuWj/yWtbf8NNxf/BAoE/5WRkP///////////6ysq/+joJ//o6Cf/7Szsv/////////////////////////////////////////////////////////////////////////////////s7Oz/cHNv/x1QKf8LZSH/EHMq/wQKBP8z0qP/NvrB/zb3vv82977/Nve+/zb6wf8z5aT/MMWC/12yfP9lsn3/O4VO/wZOFf8JThf/CU4X/wlOF/8Vez3/LNeS/zn1vv82+sH/Nve+/zb3vv82977/Nve+/zb3vv82977/Nve+/zb3vv82977/Nve+/zb3vv82977/Nve+/zb6wf8z67T/KpZ1/wwcFP+Oior////////////////////////////////////////////////////////////////////////////////////////////////////////////RzMz/Ym1p/yuDZv8SjDz/C2Uh/wUkDP8ECgT/M9Kj/zb6wf82977/Nve+/zb3vv82977/NvrB/zTxt/8jxHn/I8B1/yPEef8nyX3/J8l9/yfJff8jxHn/LNeS/zn+xP82977/Nve+/zb3vv82977/Nve+/zb3vv82977/Nve+/zb3vv82977/Nve+/zb3vv82977/Nve+/zb3vv82977/NvrB/zb3vv8SNCj/joqK//////////////////////////////////////////////////////////////////////////////////////////////////////+srKv/VnVr/yOTcP82977/GnlI/0RdRv91cnH/BAoE/zPSo/85/sT/Nve+/zb3vv82977/Nve+/zb3vv82977/NvrB/zr/y/86/8v/Ov/L/zr/y/86/8v/Ov/L/zr/y/85/sT/Of7E/zn+xP85/sT/Of7E/zn+xP85/sT/NvrB/zb3vv82977/Nve+/zb3vv82977/Nve+/zb3vv82977/Nve+/zb6wf8z67T/DjQn/46Kiv//////////////////////////////////////////////////////////////////////////////////////////////////////VUxN/w1MOP86/8v/OfW+/xY7Lv99bnH/7Ozs/wkKBv8in17/M+Wk/zn+xP82977/Nve+/zb3vv82+sH/Of7E/zb6wf8jmnT/FnZY/xZ2WP8Wdlj/FnZY/xZ2WP8Wdlj/FnZY/xZ2WP8Wdlj/FnZY/xZ2WP8Wdlj/FnZY/y3Flf86/8v/Of7E/zb5vv82977/Nve+/zb3vv82977/Nve+/zb3vv82+sH/Nve+/wYtH/+JhIT//////////////////////////////////////////////////////////////////////////////////////////////////////7Szsv9deXD/HI5r/zb3vv8orIP/THts/2RcXf8AAAD/BSwH/xeHSP8s1I3/Nve+/zb3vv85/sT/Mcyd/x2AYv8Yelv/bXp1/4F5ev+BeXr/gXl6/4F5ev+BeXr/gXl6/4F5ev+BeXr/gXl6/4F5ev+BeXr/gXl6/4F5ev9Me2z/GHpb/yOObP8z67T/Nvm+/zb3vv82977/Nve+/zb3vv82+sH/NOKt/yqLbP9zg3z/zcnK////////////////////////////////////////////////////////////////////////////////////////////////////////////1NPU/3Bzb/8rg2b/M+u0/zHMnf8TcFP/Intf/wgHCP8GQhT/GqhZ/zn+xP85/sT/NvrB/yOTcP8SEA7/enZ2/+zs7P//////////////////////////////////////////////////////////////////////ycbH/1VWVP8KEAz/NN2s/zb6wf82977/Nvm+/zb6wf85/sT/LuWj/x2UWf8SEA7/1NPU///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////w7+//f318/zV9Zf8uu4//Ov/L/zr/y/8qi2z/ElYw/xVwNv8nyX3/I8R5/zXxr/8llnj/GhMV/4mEhP+Ri4r/kYuK/5GLiv+Ri4r/kYuK/5GLiv+Ri4r/kYuK/5GLiv+Ri4r/kYuK/5GLiv+Ri4r/kYuK/5WRkP9waWr/ChAM/zTdrP82+sH/NvrB/zTxt/8pxX//J8l9/xeHSP8WRR//dXJx/+Xl5P////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////+Ri4r/THts/yWifP8jmnT/OvfA/xxwVf8CEQL/Bk4V/w96Kv8fumn/HZRZ/w8/HP8cZU3/HGZQ/xxlTf8cZU3/HGVN/xxlTf8cZU3/HGVN/xxlTf8cZU3/HGVN/xxlTf8cZU3/HGVN/xxlTf8cZU3/HGZQ/yJ7X/817rr/Lt2a/yfMhP8jxHn/Docv/wtcHv8yVTj/iYSE/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////46Kiv8DEAr/HGVN/zb3vv8ccFX/ExQQ/1VWVP8XWyf/C1Mb/wtlIf8Ykz3/J8yE/yzUjf8s1I3/LNSN/yzUjf8s1I3/LNSN/yzUjf8s1I3/LNSN/yzUjf8s1I3/LNSN/yzUjf8s1I3/LNSN/yzUjf8s1I3/LNeS/xV7Pf8LUxv/C1Mb/wtTG/8CEQL/f318//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////+Oior/BRwL/yisg/8orIP/PHtl/4mEhP/l5eT/IBwb/wUcC/8PPxz/C1we/wtcHv8GWRn/BlYX/wZWF/8GVhf/BlYX/wZWF/8GVhf/BlYX/wZWF/8GVhf/BlYX/wZWF/8GVhf/BlYX/wZWF/8GVhf/BlYX/wZZGf8KGg3/CBEH/wosEP8FLQ3/BAoE/399fP//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////rKyr/0ZGQ/9GSEX/RkZD/7Szsv//////5eXk/yAcG/8LXB7/C2Uh/wUkDP8AAAD/NTQy/0ZIRf9GRkP/RkZD/0ZGQ/9GRkP/RkZD/0ZGQ/9GRkP/RkZD/0ZGQ/9GRkP/RkZD/0ZGQ/9GRkP/RkZD/0ZGQ/9GSEX/GhMV/wUtDf8Ohy//D3oq/wAgBP9/fXz//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////+zs7P8gHBv/C1Mb/w96Kv8XWyf/Q0Q+/83Jyv///////////////////////////////////////////////////////////////////////////////////////////3p2dv8lQyr/EHMq/xqZTP8FJAz/gXl6//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////T09P+8vLv/KUk9/w5cKP8GQhT/MS4r/+jn5///////////////////////////////////////////////////////////////////////////////////////////////////////o6Cf/wYiGP8z67T/GmpO/216df/c3Nz///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////+0s7L/Eh0X/zrarf8ie1//BhYQ/zEuK//s7Oz//////////////////////////////////////////////////////////////////////////////////////////////////////6Ogn/8GIhj/Ne66/zn+xP8dgGL/PDs7//T09P//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////uLe2/wwcFP803az/NvrB/yOObP8xLiv/7Ozs//////////////////////////////////////////////////////////////////////////////////////////////////////+srKv/HT0x/zPSo/82+sH/HYBi/zo1Nf/09PT/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////8e/w/6Ogn/8MHBT/MsaY/zb6wf8jk3D/MS4r/+zs7P//////////////////////////////////////////////////////////////////////////////////////////////////////9PT0/73Bv/8dPTH/LruP/xZ2WP8xLiv/3Nzc////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////7Ozs/216df8SHRf/AAAA/xMqHv8usYr/I5Nw/zA9Nf/U09T/////////////////////////////////////////////////////////////////////////////////////////////////7Ozs/52fnv8dQzX/Mcyd/xxlTf8LEhL/AAAA/yw1MP+/xMD/9PT0/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////1VMTf8+nYD/PqyL/yUqJf9Ey6L/MW5Z/zV9Zf9Ey6L/PEVA/83Jyv///////////////////////////////////////////////////////////////////////////////////////////3Bpav8xbln/RMui/y1CNf9EuZT/K4Nm/x1DNf9Ey6L/NldJ/6Ogn//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////c3Nz/3fDs/9328v/c4t//3vn0/9zn5P/c5+T/3vn0/9zc3P/09PT////////////////////////////////////////////////////////////////////////////////////////////l5eT/3Ofk/9759P/c3Nz/3fby/93w7P/c5+T/3vn0/9zi3//s7Oz//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////w=="
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

