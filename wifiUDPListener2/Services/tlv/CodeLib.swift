//
//  CodeLib.swift
//  wifiUDPListener2
//
//  Created by Maksim on 16.09.2021.
//

import Foundation

final class CodeLib: IntReader {
    static let shared = CodeLib()
    
    private let commandToCode: [String: Any] = [
        "param_net": 0x01,
        "param_gprs": 0x02,
        "param_svr": 0x03,
        "power": 0x04,
        "light": 0x06,
        "dev_info": 0x0A,
        "param_dev": 0xB,
        "config_res": 0x1a,
        "param_dev_ex": 0x1B,
        "baudrate": 0x1E,
        "param_wifi": 0x20,
        "param_timing": 0x21,
        "sync": 0x25,
        "delay_start": 0x28,
        "param_inspect": 0x2B,
        "pgm_flicker": 0x2D,
        "imsi": 0x12C
    ]
    
    //MARK: -> // Public func
    
    public func parseJson(obj: [String: Any], sno: inout Int) -> [[Int]]? {
        if obj["pkts_program"] != nil {
            print("Choose to parse pkts_program")
            //return nil
            return parsePacketsProgram(obj: obj, sno: &sno)
        } else if obj["cmd"] != nil {
            print("Choose to parse command")
            return parseCommand(obj: obj, sno: sno)
        } else {
            fatalError("Incorrect object passed")
        }
    }
    
    
  
    
    //MARK: -> Private func
    // make request with get
    
    private func parseCommand(obj: [String: Any] , sno: Int) -> [[Int]]? {
        var pkt: [Int] = []
        guard let cmd = obj["cmd"] as? [String: Any],
              let value = cmd["get"] as? String,
              let bin_code = commandToCode[value] as? Int else {
            print("Error while parsing command, value of the key GET is not defined")
            return nil
        }
        pkt.writeInt(value: bin_code, bytes: 1) // (bin_code!, 1, nil)
        pkt.writeInt(value: 0, bytes: 1)    // (0, 1, nil)
        pkt = makePacket(pkt: pkt, sno: sno, version: 0xC1, cmd: 3) //(pkt, sno, 0xC1, 3, &flag)
            // version - is flag for checksum C1 - means - Yes (adding 4 digits - 2 bytes), 41 - means - NO
        
        // To Do:
        // Buffer from integer Array
//        let buffer = UnsafeMutablePointer<Int>.allocate(capacity: pkt.count)
//        buffer.initialize(from: &pkt, count: pkt.count)
//        print("THE BUFFER: \(buffer)")
        
        
        // printштп just for testing
//        let t = pkt[2...]
//        let temp = Array(t)
//        let data = Data(bytes: temp, count: pkt.count)
        //print("BELOW IS THE HEX STRING")
        //print(data.hexEncodedString(options: .upperCase))
        var str = ""
        for i in 0..<pkt.count{
            str += String(format:"%02X", pkt[i])
        }
        print(str)
        print("need - \nAA55FFFF0600020041030A00")

        return [pkt]
    }
    // end request get
    
    
    //MARK: -> request for sending image
    private func  parsePacketsProgram(obj: [String: Any], sno: inout Int) -> [[Int]]? {
        guard let pktsProgram = obj["pkts_program"] as? [String: Any],
              let idProTMP = pktsProgram["id_pro"] as? Int,
              let listRegion = pktsProgram["list_region"] as? [[String: Any]],
              let propertyPro = pktsProgram["property_pro"] as? [String: Any] else {
            print("Error in parsePacketsProgram")
            return nil
        }
        var pkts: [[Int]] = []
        //var pkt: [Int] = []
        let idPro = idProTMP - 1
        var outImg: [Int] = []

        let dataSave = pktsProgram["data_save"] as? Int ?? 0
        print("dataSave is - ", dataSave)

        var idRect = 0
        var idItem = 0
        
        guard let firstListRegion = listRegion.first else {
            print("Error # 1.2 in parsePacketsProgram")
            return nil
        }
        
//        if let firstListRegion = (pktsProgram["list_region"] as? [String: Any])?.first {
            if let id_rect = firstListRegion["id_rect"] as? Int {   //"id_rect"
                idRect = Int(id_rect) - 1
            } else {
                print("Error #2 in parsePacketsProgram, There is no id_rect")
            }

            if let firstListItem = (firstListRegion["list_item"] as? [[String:Any]])?.first {

                //MARK: ->//One of two ways // TODO
                if let id_item = firstListRegion["id_item"] as? Double {
                    idItem = Int(id_item) - 1
                } else {
                    print("Error #4 in parsePacketsProgram, There is no id_item ")
                }
                
                // TODO to check what is right?
                if let id_item = firstListItem["id_item"] as? Double {
                    idItem = Int(id_item) - 1
                    print("Need to fix region in parsePacketsProgram")
                } else {
                    print("Error #5 in parsePacketsProgram, There is no id_item")
                }

                //continue
                let zipImageFormat = propertyPro["send_gif_src"] as? Int == 1 ? "zip_gif" : "zip_bmp"
                guard let zipImageString = firstListItem[zipImageFormat] as? String else {
                    print("Error #5.2 there is no base64String?")
                    return nil
                }
                //print("parsePacketsProgram - zipImageString is - ", zipImageString)
                
                /*
                var binaryString = ""
                if let tmpBinaryString = zipImageString as? String/*.base64Decoded()*/ {
                    let index = tmpBinaryString.index(tmpBinaryString.startIndex, offsetBy: 0)
                    binaryString = String(tmpBinaryString[index...])
                } else {
                    print("Error #6 in parsePacketsProgram")
                }
                
                print("BINARY STRING: "+(binaryString ))
                //if var img = binaryString.convertToArrayofInt() {
                guard let tmpImg = stringToBytes(binaryString) else {
                    print("Error # 6.2 in parsePacketsProgram, fail convert img to byte array")
                    return nil
                }
                var img = tmpImg
                print("Going deep img is - ", img as Any)
                */
                guard let imgData = Data(base64Encoded: zipImageString) else {
                    print("Error #5.3 ?")
                    return nil
                }
                var img = [UInt8](imgData)
                
                if propertyPro["send_gif_src"] as? Int == 0 {
                    makeBmpData(&pkts, &img, &outImg, firstListItem, propertyPro, firstListRegion, idPro, idRect, idItem, dataSave, &sno)
                    sno += 2
                } else {
                    makeGifData(&pkts, &img, &outImg, firstListItem, propertyPro, firstListRegion, idPro, idRect, idItem, dataSave, &sno)
                    sno += 2
                }

                    let totalImgDataSize = outImg.count
                    let maxBlockSize = 0x400
                    let totalBlocks = Int((totalImgDataSize + maxBlockSize - 1) / maxBlockSize)
                    for currentBlock in 0..<totalBlocks {
                        let data_slice = outImg[0..<maxBlockSize]
                        //var data = outImg.splice(0, maxBlockSize)
                        let data = Array(data_slice)
                        outImg.removeFirst(maxBlockSize)
                        var pkt = [Int]()
                        writePropertyTags(pkt: &pkt, data_save: dataSave, id_pro: idPro, id_rect: idRect, id_item: idItem)
                        pkt.writeInt(value: 0x712,bytes: 2)
                        pkt.writeInt(value: totalBlocks,bytes: 2)
                        pkt.writeInt(value: currentBlock,bytes: 2)
                        pkt.writeInt(value: maxBlockSize,bytes: 2)
                        pkt.writeInt(value: 0x1300,bytes: 2)
                        writeLenLen(&pkt, data.count)
                        pkt.append(contentsOf: data)// += data
//                        var flag:Bool? = nil
                        
                        pkt = makePacket(pkt: pkt, sno: sno, version: 0xC1, cmd: 2)
                        sno += 1
                        pkts.append(pkt)
                    }

//                } else {
//                    print("Error #7 in parsePacketsProgram")
//                }

//            } else {
//                print("Error #3 in parsePacketsProgram")
//            }
        } else {
            print("Error #1 in parsePacketsProgram")
        }
        return pkts
    }
    //end request for sending image
    
    
    //MARK: -> common sub function
    private func makePacket(pkt: [Int], sno: Int, version: Int, cmd: Int, writeLengthFlag: Bool = true) -> [Int] {
        var result: [Int] = []
        var packetLength = pkt.count
        var offset = 0
        if writeLengthFlag == true {
            packetLength += 2
            result.writeInt(value: packetLength + 10, bytes: 2)
            offset = 2
        }
        result.writeInt(value: 0x55AA, bytes: 2)    //AA55
        result.writeInt(value: (Int((Int(sno) / 0x10000) & 0xFFFF)) , bytes: 2) // FFFF
        //result.writeInt(Number((BigInt(sno) / 0x10000n) & 0xFFFFn),2, nil)
        print("#1 -", result)
        result.writeInt(value: packetLength + 4, bytes: 2) //
        print("#2 -", result)
        result.writeInt(value: Int(Int(sno) & 0xFFFF), bytes: 2)
        print("#3 -", result)
        // result.writeInt(Number(BigInt(sno) & 0xFFFFn), 2, nil)
        result.append(version)
        print("#4 -", result)
        result.append(cmd)
        print("#5 -", result)
        result.append(contentsOf: pkt)//result = result + pkt
        print("#6 -", result)
        
        if (version & 0x80 == 0x80) {
            var cs = 0
            for index in offset..<result.count {
                cs += result[index]
            }
            result.writeInt(value: cs, bytes: 2)
        }
        print("#7 -", result)
        return result
    }
    
    //MARK: -> parsePacketsProgram - sub functions
    // Make BMP image
    private func makeBmpData(_ pkts: inout [[Int]], _ img: inout [UInt8], _ outImg: inout [Int], _ item: [String: Any], _ prop: [String: Any], _ region: [String: Any], _ idPro: Int, _ idRect: Int, _ idItem: Int, _ dataSave: Int, _ sno: inout Int) {
        //var delay_frame: [UInt32] = []
        guard let width = readUInt32LE(arrayOfInts: img, offset: 0x12),    // makeLittle(img, 0x12)
              var height = readUInt32LE(arrayOfInts: img, offset: 0x16) else { // 0x16
            print("Error in makeBmpData width and height")
            return
        }
        if height > 0xffff{
            height ^= 0xffffffff
            height += 1
        }
        print("width and height")
        print(width)
        print(height)
        //makeLittle(img, 0x16)

        let tmp: Double = Double((width * 3) / 4)
        let rowStripe = Int((tmp - floor(tmp)) > 0 ? floor(tmp + 1) * 4 : tmp * 4)
        print(rowStripe)
        let imgSize = rowStripe * Int(height) + 0x36
        print(imgSize)
        let countPage = Int(floor(Double(img.count / imgSize)))
        print("countPage", countPage)

        let typeColor = prop["type_color"] as? Int ?? 3
        let gray = prop["gray"] as? Int ?? 4
// создали
        var pkt = makeDataPropertyProgram(propertyPro: prop , infoPos: region["info_pos"]! as! [String: Any], idPro: idPro, width: prop["width"]! as! Int, height: prop["height"]! as! Int, dataSave: dataSave)

        //var writeLengthFlag: Bool? = nil
// дополнили
        pkt = makePacket(pkt: pkt, sno: sno, version: 0xC1, cmd: 2)
        sno += 1
        pkts.append(pkt)
// обнулили
        pkt = []

        writePropertyTags(pkt: &pkt, data_save: dataSave, id_pro: idPro, id_rect: idRect, id_item: idItem)
        guard var delay_frame = item["delay_frame"] as? [Int] else { return }
        if (delay_frame.count > 0) {
            for delay in delay_frame {
                delay_frame.writeInt(value: (delay * 10), bytes: 2)
            }
        }

        if (delay_frame.count > 0) {
            outImg.append(contentsOf: delay_frame)  // += delay_frame
            writeGifImageFrameHeader(&pkt, item, prop, width, height, countPage, typeColor, gray)
        } else {
            writeImageFrameHeader(&pkt, item, prop, Int(width), Int(height), countPage, typeColor, gray)
        }
        //var flag:Bool? = nil
        pkt = makePacket(pkt: pkt, sno: sno, version: 0xC1, cmd: 2)
        sno += 1
        pkts.append(pkt);

        var gamma: [Int] = []
        var gammaCoeff: Double = 1.6
        if let g = item["gamma"] as? Double {
            gammaCoeff = g
        }
        // just original code in js
//        if ("gamma" in item) {
//            gammaCoeff = item.gamma || 1.6;
//        }
        for idx in 0..<256 {
            var gammaVal = pow(((Double(idx) + 0.5)/256.0), gammaCoeff)
            gammaVal = (gammaVal * 256.0) - 0.5;
            gamma.append(Int(gammaVal))
        }

        for pageNo in 0..<countPage {
            let offset = pageNo * imgSize + 0x36;

            for idx in 0..<imgSize-offset {
                img[offset + idx] = UInt8(gamma[Int(img[offset + idx])])
            }
            for bit in 0..<(gray+1) {
                getColorMatrix(img: img, offset: offset, outImg: &outImg, width: Int(width), height: Int(height), rowStripe: rowStripe, color_plane: 2, bit: 7 - bit);
                if ( typeColor > 1) {
                    getColorMatrix(img: img, offset: offset, outImg: &outImg, width: Int(width), height: Int(height), rowStripe: rowStripe, color_plane: 1, bit: 7 - bit);
                    if ( typeColor > 2) {
                        getColorMatrix(img: img, offset: offset, outImg: &outImg, width: Int(width), height: Int(height), rowStripe: rowStripe, color_plane: 0, bit: 7 - bit);
                    }
                }
            }
        }
    }
    
    private func writeLenLen(_ pkt: inout [Int],  _ size: Int) {
        if (size < 0x80) {
            pkt.append(size)
        } else if (size < 0x100) {
            pkt.append(0x81)
            pkt.append(size)
        } else {
            pkt.append(0x82)
            pkt.writeInt(value: size, bytes: 2)
        }
    }
    
    //MARK: -> Make GIF Image
    private func  makeGifData(_ pkts: inout [[Int]], _ img: inout [UInt8], _ outImg: inout [Int], _ item: [String: Any], _  prop: [String: Any], _ region: [String: Any], _ idPro: Int, _ idRect: Int, _ idItem: Int, _ dataSave: Int, _ sno: inout Int) {

//        let countPage = Int(img.count / 0x400);
//        var typeColor = prop["type_color"] as? Int ?? 3
//        var gray = prop["gray"] as? Int ?? 4

// создали
        var pkt = makeDataPropertyProgram(propertyPro: prop, infoPos: region["info_pos"]! as! [String: Any], idPro: idPro, width: prop["width"]! as! Int, height: prop["height"]! as! Int, dataSave: dataSave)
        //var flag:Bool? = nil
//дополнили
        pkt = makePacket(pkt: pkt, sno: sno, version: 0xC1, cmd: 2)
        sno += 1
        pkts.append(pkt)
//обнулили
        pkt = []

        writePropertyTags(pkt: &pkt, data_save: dataSave, id_pro: idPro, id_rect: idRect, id_item: idItem)

        guard let ani = item["info_animate"] as? [String: Any],
              let aniModelNormal = ani["model_normal"] as? Int,
              let aniSpeed = ani["speed"] as? Int,
              let aniTimeStay = ani["time_stay"] as? Int else {
            print("Error #303")
            return
        }
        pkt.append(0x14)
        pkt.append(3)
        pkt.append(aniModelNormal)
        pkt.append(aniSpeed - 1)
        pkt.append((item["isGif"] != nil) ? 0 : aniTimeStay)

        pkt.writeInt(value: 0x411, bytes: 2)
        pkt.writeInt(value: 0x100,bytes: 3)
        pkt.append(10)

        //var flag2: Bool? = nil
        pkt = makePacket(pkt: pkt, sno: sno, version: 0xC1, cmd: 2)
        sno += 1
        pkts.append(pkt)
        let imgTmp: [Int] = img.map({Int($0)})
        outImg.append(contentsOf: imgTmp) // += img   //        img.map(val => outImg.push(val))
    }


    //MARK: -> common makeGIF makeBMP sub-sub functions

    private func makeDataPropertyProgram(propertyPro: [String: Any?], infoPos: [String: Any], idPro: Int, width: Int, height: Int, dataSave: Int) -> [Int] {
        var result: [Int] = []

        if (idPro < 255) {
            result.writeInt(value: 0x208, bytes: 3)
            result.append(idPro);
        }
        writeDataTag(&result, 9, (1 - dataSave))
        writeDataTag(&result, 0xC, idPro)
        result.writeInt(value: 0x61C, bytes: 2)

        guard let propertyProTypeBG = propertyPro["type_bg"] as? Int else {
            print("Error in makeDataPropertyProgram")
            return [0]
        }

        result.append(propertyProTypeBG)
        result.append(0)

        result.writeInt(value: (propertyPro["play_loop"] as? Int) ?? 1, bytes: 2)
        result.writeInt(value: (propertyPro["time_sync"] as? Int) ?? 3, bytes: 2)
        result.writeInt(value: 0x10D, bytes: 2)
        result.append(0) // TODO: region index
        result.writeInt(value: 0x91D, bytes: 2)
        result.writeInt(value: infoPos["x"]! as! Int, bytes: 2)
        result.writeInt(value: infoPos["y"]! as! Int, bytes: 2)
        result.writeInt(value: (infoPos["w"] as? Int) ?? width, bytes: 2)
        result.writeInt(value: (infoPos["h"] as? Int) ?? height, bytes: 2)
        result.append(0)  // TODO: background
        return result
    }
    
    private func writePropertyTags(pkt: inout [Int], data_save: Int, id_pro: Int, id_rect: Int, id_item: Int) {
        writeDataTag(&pkt, 9, 1 - data_save)
        writeDataTag(&pkt, 0xC, id_pro)
        writeDataTag(&pkt, 0xD, id_rect)
        writeDataTag(&pkt, 0xE, id_item)
    }
    
    

    //MARK: -> make BMP sub-functions
    private func writeImageFrameHeader(_ pkt: inout [Int], _ item: [String: Any], _ prop: [String: Any], _ width: Int, _ height: Int, _ frameNo: Int, _ typeColor: Int, _ gray: Int) {
        guard let ani = item["info_animate"] as? [String: Any],
              let aniModelNormal = ani["model_normal"] as? Int,
              let aniSpeed = ani["speed"] as? Int,
              let aniTimeStay = ani["time_stay"] as? Int else {
            print("Error in writeImageFrameHeader")
            return
        }
        pkt.append(0x14)
        pkt.append(3)
        pkt.append(aniModelNormal)
        pkt.append(aniSpeed - 1)
        pkt.append((item["isGif"] != nil) ? 0 : aniTimeStay)

        // Writing data item control block
        pkt.append(0x11)
        pkt.append(0x10)
        var timeDelay = 1
        var timeType = 0

        if let play_fixed_time = prop["play_fixed_time"] as? Int{
            timeType = 1
            timeDelay = play_fixed_time
        } else if let play_loop = prop["play_loop"] as? Int{
            timeDelay = play_loop
        }

        pkt.append(timeType)
        pkt.writeInt(value: timeDelay, bytes: 2)
        pkt.append(7)
        pkt.append(typeColor)
        pkt.append(gray + 1)
        pkt.writeInt(value: frameNo, bytes: 2)
        pkt.writeInt(value: 0xFFFF, bytes: 2)
        pkt.writeInt(value: width, bytes: 2)
        pkt.writeInt(value: height, bytes: 2)
        // TODO: check animation type and use width or height based on those flags
        pkt.writeInt(value: height, bytes: 2)
    }

    private func writeGifImageFrameHeader(_ pkt: inout [Int], _ item: [String: Any], _ prop: [String: Any],_  width: Int, _ height: Int, _ countPage: Int, _ typeColor: Int, _ gray: Int) {
        guard let ani = item["info_animate"] as? [String: Any],
              let aniModelNormal = ani["model_normal"] as? Int,
              let aniSpeed = ani["speed"] as? Int,
              let aniTimeStay = ani["time_stay"] as? Int else {
            print("Error in writeGifImageFrameHeader")
            return
        }
            pkt.append(0x14)
            pkt.append(3)
            pkt.append(aniModelNormal)
            pkt.append(aniSpeed - 1)
            pkt.append((item["isGif"] != nil) ? 0 : aniTimeStay)

        // Writing data item control block
        pkt.append(0x11)
        pkt.append(0xC)
        var timeDelay = 1
        var timeType = 0
        if let play_fixed_time = prop["play_fixed_time"] as? Int {
            timeType = 1
            timeDelay = play_fixed_time
        } else if let play_loop = prop["play_loop"] as? Int {
            timeDelay = play_loop
        }

        pkt.append(timeType)
        pkt.writeInt(value: timeDelay, bytes: 2)
        pkt.append(8)
        pkt.append(typeColor)
        pkt.append(gray + 1)
        pkt.writeInt(value: countPage, bytes: 2)
        pkt.writeInt(value: Int(width), bytes: 2)
        pkt.writeInt(value: Int(height), bytes: 2)
    }

    private func getColorMatrix(img: [UInt8], offset: Int, outImg: inout [Int], width: Int, height: Int, rowStripe: Int, color_plane: Int, bit: Int) {
        for cur_y in (0..<height).reversed(){
            var set_bit = 0
            var out_color = 0
            for cur_x in 0..<width {
                let y = cur_y * rowStripe + offset
                let x = cur_x * 3 + color_plane
                let in_color = img[x+y]
                if ((in_color >> bit) & 1 == 1) {
                    out_color |= 1 << set_bit;
                }
                set_bit += 1
                if (set_bit > 7) {
                    outImg.append(out_color)
                    set_bit = 0;
                    out_color = 0;
                }
            }
            if (set_bit > 0) {
                outImg.append(out_color);
            }
        }
    }
    
    private func writeDataTag(_ pkt: inout [Int],_ tag: Int,_ value: Int) {
        pkt.append(tag)
        pkt.append(1)
        pkt.append(value)
    }

    
    func stringToBytes(_ string: String) -> [Int]? {
        guard var data = Data(base64Encoded: string) else { return nil }
        var byteArray: [UInt8] = [UInt8](data)
        let bytesArr = byteArray.map({Int($0)})
        return bytesArr
    }
    
//    func stringToBytes(_ string: String) -> [Int]? {
//        let length = string.count
//        if length & 1 != 0 {
//            print("error length")
//            return nil
//        }
//        var bytes: [UInt8] = []
//        bytes.reserveCapacity(length/2)
//        var index = string.startIndex
//        for _ in 0..<length/2 {
//            let nextIndex = string.index(index, offsetBy: 2)
//            if let b = UInt8(string[index..<nextIndex], radix: 16) {
//                bytes.append(b)
//            } else {
//                return nil
//            }
//            index = nextIndex
//        }
//        let bytesArr = bytes.map({Int($0)})
//        return bytesArr
//    }
    
}
