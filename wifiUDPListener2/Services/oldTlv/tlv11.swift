////
////  tlv.swift
////  Waadsu
////
////  Created by Assylzhan Nurlybekuly on 01.08.2021.
////
//
//import Foundation
//import Compression
//import UIKit
//import CoreGraphics
//
//extension Array where Element == Int {
//    public mutating func writeInt(_ value:Int,_ bytes:Int,_ direction:String?) {
//        var dir = 0
//        if (direction != nil && direction=="BE"){
//            dir = 1
//        }
//        if dir == 0 {
//            for idx in 0..<bytes{
//                self.append((value >> (8 * idx)) & 0xFF)
//            }
//        }else{
//            for idx in (0..<bytes).reversed(){
//                self.append((value >> (8 * idx)) & 0xFF)
//            }
//        }
//    }
//}
//final class tlv {
//    static let shared = tlv()
//    private let commandToCode : [AnyHashable:Any] = [
//        "param_net": 0x01,
//        "param_gprs": 0x02,
//        "param_svr": 0x03,
//        "power": 0x04,
//        "light": 0x06,
//        "dev_info": 0x0A,
//        "param_dev": 0xB,
//        "config_res": 0x1a,
//        "param_dev_ex": 0x1B,
//        "baudrate": 0x1E,
//        "param_wifi": 0x20,
//        "param_timing": 0x21,
//        "sync": 0x25,
//        "delay_start": 0x28,
//        "param_inspect": 0x2B,
//        "pgm_flicker": 0x2D,
//        "imsi": 0x12C
//    ]
//    private func parseCommand(_ obj:[String:Any]? , _ sno:Int)->[[Int]]?{
//        var pkt = [Int]()
//        var bin_code:Int? = nil
//        if let cmd = obj?["cmd"] as? [String:Any]{
//            if let value = cmd["get"] as? String {
//                guard let b = commandToCode[value] as? Int else {
//                    print("Error while parsing command, value of the key GET is not defined")
//                    return nil
//                }
//                print("The bin code: \(b)")
//                bin_code =  b
//                // TO DO
//                // is value supposed to be String ? if String then we can not pass to the parameters
//                pkt.writeInt(bin_code!, 1, nil)
//                pkt.writeInt(0, 1, nil)
//                var flag:Bool? = nil
//                
//                pkt = makePacket(pkt, sno, 0xC1, 3, &flag)
//            }
//        }
//        return [pkt]
//    }
//    
//    
//    private func getColorMatrix(_ img:[UInt8], _ offset:Int, _ outImg: inout [Int], _ width:Int, _ height:Int,_ rowStripe:Int, _ color_plane:Int, _ bit:Int){
//        for cur_y in (0..<height).reversed(){
//            var set_bit = 0
//            var out_color = 0
//            for cur_x in 0..<width {
//                let y = cur_y * rowStripe + offset
//                let x = cur_x * 3 + color_plane
//                let in_color = img[x+y]
//                if (((in_color >> bit) & 1) == 1) {
//                    out_color |= (1 << set_bit);
//                }
//                set_bit += 1
//                if (set_bit > 7) {
//                    outImg.append(out_color)
//                    set_bit = 0;
//                    out_color = 0;
//                }
//            }
//            if (set_bit > 0) {
//                outImg.append(out_color);
//            }
//        }
//    }
//    private func writeDataTag(_ pkt: inout [Int], _ tag:Int, _ value:Int) {
//        pkt.append(tag);
//        pkt.append(1);
//        pkt.append(value);
//    }
//    private func writePropertyTags(_ pkt: inout [Int], _ data_save:Int, _ id_pro:Int, _ id_rect:Int, _ id_item:Int) {
//        writeDataTag(&pkt, 9, 1 - data_save);
//        writeDataTag(&pkt, 0xC, id_pro);
//        writeDataTag(&pkt, 0xD, id_rect);
//        writeDataTag(&pkt, 0xE, id_item);
//    }
//    private func writeImageFrameHeader(_ pkt: inout [Int], _ item:[String:Any], _ prop:[String:Any], _ width:Int, _ height:Int, _ frameNo: Int, _ typeColor:Int, _ gray: Int) {
//        if let ani = item["info_animate"] as? [String:Any] {
//            pkt.append(0x14)
//            pkt.append(3)
//            pkt.append(ani["model_normal"]! as! Int)
//            pkt.append(ani["speed"]! as! Int - 1)
//            pkt.append(((item["isGif"]! as! Int) != 0) ? 0 : ani["time_stay"]! as! Int)
//        }
//        
//        // Writing data item control block
//        pkt.append(0x11)
//        pkt.append(0x10)
//        var timeDelay = 1
//        var timeType = 0
//        
//        
//        if let play_fixed_time = prop["play_fixed_time"] as? Int{
//            timeType = 1
//            timeDelay = play_fixed_time
//        }else if let play_loop = prop["play_loop"]  as? Int{
//            timeDelay = play_loop
//        }
//        
//        pkt.append(timeType)
//        pkt.writeInt(timeDelay, 2, nil)
//        pkt.append(7)
//        pkt.append(typeColor)
//        pkt.append(gray + 1)
//        pkt.writeInt(frameNo, 2,nil)
//        pkt.writeInt(0xFFFF, 2, nil)
//        pkt.writeInt(width, 2,nil)
//        pkt.writeInt(height, 2,nil)
//        // TODO: check animation type and use width or height based on those flags
//        pkt.writeInt(height, 2, nil)
//    }
//    private func writeGifImageFrameHeader(_ pkt: inout [Int], _ item:[String:Any], _ prop:[String: Any],_  width:UInt32, _ height:UInt32, _ countPage:Int, _ typeColor:Int, _ gray:Int) {
//        if let ani = item["info_animate"] as? [String:Any]{
//            pkt.append(0x14)
//            pkt.append(3)
//            pkt.append(ani["model_normal"]! as! Int)
//            pkt.append(ani["speed"]! as! Int - 1)
//            pkt.append((item["isGif"] as! Int != 0) ? 0 : ani["time_stay"]! as! Int)
//        }
//        
//        // Writing data item control block
//        pkt.append(0x11)
//        pkt.append(0xC)
//        var timeDelay = 1
//        var timeType = 0
//        if let play_fixed_time = prop["play_fixed_time"] as? Int {
//            timeType = 1
//            timeDelay = play_fixed_time
//        } else if let play_loop = prop["play_loop"] as? Int {
//            timeDelay = play_loop
//        }
//        pkt.append(timeType)
//        pkt.writeInt(timeDelay, 2,nil)
//        pkt.append(8)
//        pkt.append(typeColor)
//        pkt.append(gray + 1)
//        pkt.writeInt(countPage, 2,nil)
//        pkt.writeInt(Int(width), 2,nil)
//        pkt.writeInt(Int(height), 2, nil)
//    }
//    private func writeLenLen(_ pkt: inout [Int],  _ size:Int) {
//        if (size < 0x80) {
//            pkt.append(size)
//        } else if (size < 0x100) {
//            pkt.append(0x81)
//            pkt.append(size)
//        } else {
//            pkt.append(0x82)
//            pkt.writeInt(size, 2, nil)
//        }
//    }
//    private func makePacket(_ pkt:[Int], _ sno:Int, _ version:Int,_ cmd: Int, _ writeLengthFlag: inout Bool?)->[Int]{
//        if writeLengthFlag == nil {
//            writeLengthFlag = false
//        }
//        var result = [Int]()
//        var packetLength = pkt.count
//        var offset = 0
//        if  writeLengthFlag == true {
//            packetLength += 2
//            result.writeInt(packetLength + 10,2, nil)
//            offset = 2
//        }
//        result.writeInt(0x55AA, 2, nil)
//        result.writeInt(((Int(UInt64(sno))/0x10000) & 0xFFFF) , 2, nil) //result.writeInt(Number((BigInt(sno) / 0x10000n) & 0xFFFFn),2, nil)
//        result.writeInt(packetLength + 4,2, nil)
//        result.writeInt((Int(UInt64(sno)) & 0xFFFF), 2, nil)// result.writeInt(Number(BigInt(sno) & 0xFFFFn), 2, nil)
//        result.append(version)
//        result.append(cmd)
//        result = result + pkt
//        if (version & 0x80 == 0x80) {
//            var cs = 0
//            for idx in offset..<result.count {
//                cs += result[idx]
//            }
//            result.writeInt(cs, 2, nil)
//        }
//        return result
//    }
//    private func makeDataPropertyProgram(_ propertyPro:[String:Any?],_ infoPos:[String:Any], _ idPro:Int,_ width:Int, _ height:Int, _ dataSave:Int)-> [Int] {
//        var result = [Int]()
//        
//        if (idPro < 255) {
//            result.writeInt(0x208, 3, nil)
//            result.append(idPro);
//        }
//        writeDataTag(&result, 9, 1 - dataSave);
//        writeDataTag(&result, 0xC, idPro);
//        result.writeInt(0x61C, 2, nil);
//        result.append(propertyPro["type_bg"]! as! Int);
//        result.append(0);
//        result.writeInt(((propertyPro["play_loop"] as? Int) != nil) ? propertyPro["play_loop"]! as! Int : 1, 2, nil)
//        
//        
//        result.writeInt(((propertyPro["time_sync"] as? Int) != nil) ? propertyPro["time_sync"]! as! Int :3, 2, nil)
//        result.writeInt(0x10D, 2, nil)
//        result.append(0); // TODO: region index
//        result.writeInt(0x91D, 2, nil)
//        result.writeInt(infoPos["x"]! as! Int, 2, nil)
//        result.writeInt(infoPos["y"]! as! Int, 2, nil)
//        result.writeInt(((infoPos["w"] as? Int) != nil) ? infoPos["w"]! as! Int:width, 2, nil)
//        result.writeInt(((infoPos["h"] as? Int) != nil) ? infoPos["h"]! as! Int:height,2, nil)
//        result.append(0)  // TODO: background
//        return result
//    }
//    private func makeBmpData(_ pkts: inout [[Int]], _ img: inout [UInt8], _ outImg: inout [Int], _ item:[String:Any], _ prop:[String: Any], _ region: [String:Any], _ idPro: Int, _ idRect:Int, _ idItem:Int, _ dataSave:Int, _ sno: inout Int) {
//        var delay_frame = [Int]()
//        var width = readUInt32LE(img, 0x12)
//        var height = readUInt32LE(img, 0x16)
//        if height > 0xffff{
//            height ^= 0xffffffff
//            height += 1
//        }
////        print("width: \(width) and height: \(height)")
//        width = 64
//        height = 64
//        let tmp:Double = Double((width * 3) / 4)
//        let rowStripe = (tmp - floor(tmp)) > 0 ? (Int(tmp + 1) * 4) : Int(tmp * 4)
//        let imgSize = rowStripe * Int(height)
////        print("Row stripe: \(rowStripe) and image size: \(imgSize)")
//        let countPage = Int(img.count / imgSize)
//        print("Img count: \(img.count)")
//        print("Count page: \(countPage)")
//        let typeColor = (prop["type_color"] as? Int) != nil ? prop["type_color"]! as! Int : 3
//        let gray = (prop["gray"] as? Int) != nil ? prop["gray"]! as! Int : 4
//        
//        var pkt = makeDataPropertyProgram(prop , region["info_pos"]! as! [String:Any], idPro, prop["width"]! as! Int, prop["height"]! as! Int, dataSave)
//        var writeLengthFlag :Bool? = nil
//        pkt = makePacket(pkt, sno, 0x41, 2, &writeLengthFlag)
//        sno += 1
//        pkts.append(pkt);
//       
//        
//        pkt = [Int]()
//        writePropertyTags(&pkt, dataSave, idPro, idRect, idItem)
//        if let df = item["delay_frame"] as? [Int] {
//            if (df.count>0){
//                for delay in df {
//                delay_frame.writeInt(delay*10, 2, nil)
//                }
//            }
//        }
//       
//        for i in 0..<30 {
//            delay_frame.writeInt(i*100, 2, nil)
//        }
//        
//        if (delay_frame.count >= 0) {
//            outImg += delay_frame
//            writeGifImageFrameHeader(&pkt, item, prop, UInt32(width), UInt32(height), countPage, typeColor, gray)
//        } else {
//            writeImageFrameHeader(&pkt, item, prop, Int(width), Int(height), countPage, typeColor, gray)
//        }
//        var flag:Bool? = nil
//        pkt = makePacket(pkt, sno, 0x41, 2, &flag)
////        sno += 1
//        pkts.append(pkt);
//        
//        var gamma = [Int]()
//        var gammaCoeff:Double = 1.6
//        if let g = item["gamma"] as? Double{
//            gammaCoeff = g
//        }
//        for idx in 0..<256 {
//            var gammaVal = pow(((Double(idx) + 0.5)/256.0), gammaCoeff)
//            gammaVal = (gammaVal * 256.0) - 0.5;
//            gamma.append((Int(gammaVal)));
//        }
//        print("Gray: \(gray)")
//       
//        for pageNo in 0..<countPage {
//            let offset = pageNo * imgSize
//            
//            for idx in 0..<img.count-offset{
//                img[offset + idx] = UInt8(gamma[Int(img[offset + idx])])
//            }
//            for bit in 0..<(gray+1) {
//                getColorMatrix(img, offset, &outImg, Int(width), Int(height), rowStripe, 2, 7 - bit);
//                if ( typeColor > 1) {
//                    getColorMatrix(img, offset, &outImg, Int(width), Int(height), rowStripe, 1, 7 - bit);
//                    if ( typeColor > 2) {
//                        getColorMatrix(img, offset, &outImg, Int(width), Int(height), rowStripe, 0, 7 - bit);
//                    }
//                }
//            }
//        }
//    }
//    private func makeGifData(_ pkts: inout [[Int]], _ img:[UInt8], _ outImg: inout [Int], _ item:[String:Any], _  prop:[String:Any], _ region:[String:Any], _ idPro:Int,_  idRect:Int, _ idItem:Int, _ dataSave:Int, _ sno: inout Int) {
//        let tmp = (prop["width"]! as! Int * 3) / 4
//        let rowStripe = (tmp - Int(tmp)) > 0 ? Int(tmp + 1) * 4 : tmp * 4
//        let imgSize = rowStripe * (prop["height"]! as! Int) + 0x36
//        let countPage = Int(img.count / 0x400);
//        
//        var typeColor = 3
//        if (prop["type_color"] as? Int) != nil {
//            typeColor = prop["type_color"]! as! Int
//        }
//        var gray = 4
//        if (prop["gray"] as? Int) != nil {
//            gray = prop["gray"]! as! Int
//        }
//        
//        
//        
//        var pkt = makeDataPropertyProgram(prop, region["info_pos"]! as! [String:Any], idPro, prop["width"]! as! Int, prop["height"]! as! Int, dataSave)
//        var flag:Bool? = nil
//        pkt = makePacket(pkt, sno, 0xC1, 2, &flag)
//        sno += 1
//        pkts.append(pkt)
//        pkt = [Int]()
//        writePropertyTags(&pkt, dataSave, idPro, idRect, idItem)
//        if let ani = item["info_animate"] as? [String:Any] {
//            pkt.append(0x14)
//            pkt.append(3)
//            pkt.append(ani["model_normal"]! as! Int)
//            pkt.append(ani["speed"]! as! Int - 1)
//            pkt.append(((item["isGif"] as? Int) != nil) ? 0 : ani["time_stay"]! as! Int)
//        }
//        
//        pkt.writeInt(0x411,2, nil)
//        pkt.writeInt(0x100,3, nil)
//        pkt.append(10)
//        var flag2:Bool? = nil
//        pkt = makePacket(pkt, sno, 0xC1, 2, &flag2)
//        sno += 1
//        pkts.append(pkt)
//        for byte in img {
//            outImg.append(Int(byte))
//        }
////        outImg += img   //        img.map(val => outImg.push(val))
//    }
//    private func  parsePacketsProgram(_ obj:[String:Any], _ sno: inout Int)->[[Int]]? {
//
//        guard let pgm = obj["pkts_program"] as? [String:Any]  else {return nil}
//        guard let prop = pgm["property_pro"] as? [String:Any]  else {return nil}
//        
//        var pkts = [[Int]]()
//        var pkt = [Int]()
//        let idPro = (pgm["id_pro"]! as! Int ) - 1
//        var dataSave = 0
//        var outImg = [Int]()
//        
//        if let ds = pgm["data_save"] as? Int{
//            dataSave = ds
//        }
//        let region = (pgm["list_region"]! as! [[String:Any]]).first
//        var idRect = 0
//        
//        if let id_rect = region?["id_rect"] as? Int {
//            idRect = id_rect - 1
//        }
//
//        let item = (region?["list_item"]! as! [[String:Any]]).first
//        var idItem = 0
//        if let id_item = region?["id_item"] as? Int {
//            idItem = id_item - 1
//        }
//    
//        guard let zipBmp = item?[(prop["send_gif_src"] as! Int != 0) ? "zip_gif" : "zip_bmp"] as? String else {
//            print("Error there is no base64String?")
//            return nil
//        }
//
//        guard let data = Data(base64Encoded: zipBmp) else { return nil }
//        
//        
//        var img = [UInt8]()
//        var count = 0
//        CGifManager.shared.getSequence(imageData: data) { allFrames in    // allFrames = [UIImage] = все фреймы в гифк
//            for frame in allFrames {
//                
//                guard let bmp_data = frame.toData(options: [:], type: .bmp) else {return}
//                
//                var frame_bytes = [UInt8](bmp_data)
//                frame_bytes.removeFirst(54) // remove header only raw data
//                if (count>=42 && count<72){
//                    img += frame_bytes
//                }
//                
//                
//                
//                count += 1
//            }
//        }
//        
//        
//            print("FRAMES ADDED: \(count)")
//        
//            // тут будет идти только makeBmpData    TO DO: поменять if statement чтобы она выбирала функцию по модели рюкзака
//        if prop["send_gif_src"] as! Int != nil {
//            makeBmpData(&pkts, &img, &outImg, item!, prop, region!, idPro, idRect, idItem, dataSave, &sno)
//            //                    sno += 2
//        }
//        else{
//            makeGifData(&pkts, img, &outImg, item!, prop, region!, idPro, idRect, idItem, dataSave, &sno)
//            //            sno += 2
//        }
//
//        
//        let totalImgDataSize = outImg.count
//        let maxBlockSize = 0x400
//        let totalBlocks = Int((totalImgDataSize + maxBlockSize - 1) / maxBlockSize)
//        
//        for currentBlock in 0..<totalBlocks {
//            let data_slice = outImg[0..<min(outImg.count,maxBlockSize)]  //var data = outImg.splice(0, maxBlockSize)
//            let block = Array(data_slice)
//            outImg.removeFirst(min(outImg.count,maxBlockSize))
//            var pkt = [Int]()
//            writePropertyTags(&pkt, dataSave, idPro, idRect, idItem)
//            pkt.writeInt(0x712,2,nil)
//            pkt.writeInt(totalBlocks,2,nil)
//            pkt.writeInt(currentBlock,2, nil)
//            pkt.writeInt(maxBlockSize,2,nil)
//            pkt.writeInt(0x1300,2, nil)
//            writeLenLen(&pkt, block.count)
//            
//            pkt += block
//            var flag:Bool? = nil
//            pkt = makePacket(pkt, sno, 0x41, 2, &flag)
//            //                    sno += 1
//            pkts.append(pkt)
//        }
//        return pkts
//        
//        //          TO DO:
//        //        require('fs').writeFileSync(`./img.${prop.send_gif_src ? "gif" : "bmp"}`, img)
//    }
//    
//    public func parseJson(_ obj:[String:Any], _ sno: inout Int) -> [String]?{
//        var p: [[Int]]? = nil
//        if obj["pkts_program"] != nil {
//            p = parsePacketsProgram(obj, &sno)
//        }else if obj["cmd"] != nil {
//            p =  parseCommand(obj, sno)
//        }else{
//            print("Incorrect object passed")
//        }
//        guard let pkts = p else {return nil}
//        var str = ""
//        var output = [String]()
//        for pkt in pkts{
//            for byte in pkt {
//                str += String(format:"%02X", byte)
//            }
//            output.append(str)
//            str = ""
//        }
//        return output
//    }
//    private func readDevInfo(_ payload:[UInt8], _ sno:Int)->[AnyHashable:Any]? {
//        //let string = payload.toString("ascii");
//        var string = ""
//        for part in payload {
//            string.append(Character(UnicodeScalar(part) ?? "?"))
//        }
//        print(string)
//        // let parts = string.match(/^([^,]*),([^,]*),([^,]*),(.*)$/)
////        let parts = matches(for: "/^([^,]*),([^,]*),([^,]*),(.*)$/", in: string)
//        
//        // manual matching for regex
//        
//        var parts = [String]()
//        var count = 0
//        var current = ""
//        for char in string {
//            if char == "," {
//                if (count == 3){
//                    continue
//                }else{
//                    parts.append(current)
//                    current = ""
//                }
//                count += 1
//            }else{
//                current += String(char)
//            }
//        }
//        if current != "" {
//            parts.append(current)
//        }
//        print(parts)
//        let result:[AnyHashable:Any] = [
//            "ack": [
//                "dev_info": [
//                    "id_dev": parts[0],
//                    "version": String(parts[1]+"_"+parts[2]),
//                    "model": parts[3]
//                ]
//            ],
//            "sno":sno
//        ]
//        return result
//    }
//    private func readLight(_ payload: [UInt8], _ sno: Int)->[AnyHashable:Any]? {
//        let type = payload[0]
//        var result:[AnyHashable:Any]? = nil
//        if type == 0{
//            result = ["ack":[
//                "light":
//                    ["type":0,"value_fix":payload[1]]
//            ],
//            "sno": sno
//            ]
//        }
//        return result
//    }
//    private func readParamDevEx(_ payload: [UInt8], _ sno: Int)->[AnyHashable:Any] {
//        let slice = payload[0x10...]
//        let data_out = Array(slice)
//        let result:[AnyHashable:Any] = [
//            "ack": [
//                "param_dev": [
//                    "width": readUInt16LE(payload, 1), //payload.readInt16LE(1)
//                    "height": readUInt16LE(payload, 3), // payload.readInt16LE(3)
//                    "polar_data": payload[5],
//                    "polar_oe": payload[6],
//                    "type_color": payload[7] == 0 ? 1 : payload[7],
//                    "gray": payload[8] - 1,
//                    "decoder": 1,
//                    "type_scan": 1,
//                    "line_bank": payload[0xB],
//                    "segment": payload[0xC],
//                    "delay_frame":payload[0xD],
//                    "rate_frame": payload[0xE],
//                    "backgroup": payload[0xF],
//                    "count_io": payload.count - 0x10,
//                    "data_out": data_out
//                ]
//            ],
//            "sno": sno
//        ]
//        return result
//    }
//    private func readParamDev(_ payload:[UInt8], _ sno:Int)->[AnyHashable:Any] {
//        let result:[AnyHashable:Any] = [
//            "ack": [
//                "param_dev": [
//                    "width": readUInt16LE(payload, 0), // payload.readInt16LE(0)
//                    "height": readUInt16LE(payload, 2), //payload.readInt16LE(2)
//                    "type_color": payload[4],
//                    "polar_data": payload[5],
//                    "polar_oe": payload[6],
//                    "type_scan": payload[7],
//                    "angle_rotate": payload[8],
//                    "rate_frame": payload[9],
//                    "delay_frame":payload[10]
//                ]
//            ],
//            "sno":sno
//        ]
//        return result
//    }
//    private func readNet(_ payload:[UInt8], _ sno:Int)->[AnyHashable:Any]?{
//        var result:[AnyHashable:Any]? = nil
//        var  parts = [String]()
//        var string = ""
//        for part in payload {                                    //   let parts = payload.toString("ascii").split(",");
//            let ascii_char = Character(UnicodeScalar(part) ?? "?")
//            if ascii_char != "," {
//                string.append(ascii_char)
//            }else{
//                parts.append(string)
//                string = ""
//            }
//        }
//        if string != "" {
//            parts.append(string)
//        }
//        result = [
//            "ack": [
//                "param_net": [
//                    "mac": parts[0],
//                    "port_udp_svr": parts[1],
//                    "port_udp_dev": parts[2],
//                    "type": parts[3],
//                    "ip": parts[4],
//                    "mask": parts[5],
//                    "gateway": parts[6],
//                    "dns": parts[7]
//                ]
//            ]
//        ]
//        
//        return result
//    }
//    private func readGprs(_ payload:[UInt8], _ sno:Int)->[AnyHashable:Any]?{
//        var result:[AnyHashable:Any]? = nil
//        var parts = [String]()
//        var string = ""
//        for part in payload {                                    //   let parts = payload.toString("ascii").split(",");
//            let ascii_char = Character(UnicodeScalar(part) ?? "?")
//            if ascii_char != "," {
//                string.append(ascii_char)
//            }else{
//                parts.append(string)
//                string = ""
//            }
//        }
//        if string != "" {
//            parts.append(string)
//        }
//        
//        result = [
//            "ack": [
//                "param_gprs": [
//                    "apn": parts[0],
//                    "user": parts[1],
//                    "pwd": parts[2]
//                ]
//            ]
//        ]
//        
//        return result
//    }
//    private func readSvr(_ payload:[UInt8], _ sno:Int)->[AnyHashable:Any]? {
//        var result:[AnyHashable:Any]? = nil
//        var  parts = [String]()
//        var string = ""
//        for part in payload {                                    //   let parts = payload.toString("ascii").split(",");
//            let ascii_char = Character(UnicodeScalar(part) ?? "?")
//            if ascii_char != "," {
//                string.append(ascii_char)
//            }else{
//                parts.append(string)
//                string = ""
//            }
//        }
//        if string != "" {
//            parts.append(string)
//        }
//        result = [
//            "ack": [
//                "param_svr": [
//                    "type": parts[0],
//                    "ip": parts[1],
//                    "port": parts[2],
//                    "sec_hb": parts[3]
//                ]
//            ]
//        ]
//        
//        return result
//    }
//    private func readPower(_ payload:[UInt8], _ sno:Int)->[AnyHashable:Any]? {
//        var result:[AnyHashable:Any]? = nil
//        if (payload[0] == 0) {
//            result = [
//                "ack": [
//                    "power": [
//                        "type": payload[1]
//                    ]
//                ]
//            ]
//        } else {
//            result = [
//                "ack": [
//                    "payload":payload,
//                    "power": []
//                ]
//            ]
//        }
//        
//        return result
//    }
//    private func readConfigRes(_ payload:[UInt8], _ sno:Int)->[AnyHashable:Any]?{
//        let result:[AnyHashable:Any] = [
//            "ack": [
//                "config_res": [
//                    "max_count_pgm": payload[0],
//                    "max_count_rect": payload[1],
//                    "max_count_item": payload[2]
//                ]
//            ]
//        ]
//        return result
//    }
//    private func readBaudRate(_ payload:[UInt8], _ sno:Int)->[AnyHashable:Any]?{
//        let result:[AnyHashable:Any] = [
//            "ack": [
//                "baudrate": readUInt32LE(payload, 0) // payload.readUInt32LE(0)
//            ]
//        ]
//        
//        return result
//    }
//    private func readWiFi(_ payload:[UInt8], _ sno:Int)->[AnyHashable:Any]?{
//        var result :[AnyHashable:Any]? = nil
//        var  parts = [String]()
//        var string = ""
//        for part in payload {                                    //   let parts = payload.toString("ascii").split(",");
//            let ascii_char = Character(UnicodeScalar(part) ?? "?")
//            if ascii_char != "," {
//                string.append(ascii_char)
//            }else{
//                parts.append(string)
//                string = ""
//            }
//        }
//        if string != "" {
//            parts.append(string)
//        }
//        result = [
//            "ack": [
//                "param_wifi": [
//                    "type": parts[0],
//                    "user": parts[1],
//                    "pwd": parts[2],
//                    "user_coe": parts[3],
//                    "pwd_coe": parts[4]
//                ]
//            ]
//        ]
//        
//        return result
//    }
//    private func readParamTiming(_ payload:[UInt8], _ sno:Int)->[AnyHashable:Any]?{
//        let result:[AnyHashable:Any] = [
//            "ack": [
//                "param_timing": [
//                    "interval":readUInt32LE(payload, 0) , // payload.readUInt16LE(0)
//                    "timezone": payload[2]/4
//                ]
//            ]
//        ]
//        
//        return result;
//    }
//    private func readSync(_ payload:[UInt8], _ sno: Int)-> [AnyHashable:Any]?{
//        let result :[AnyHashable:Any] = [
//            "ack": [
//                "sync": payload[0]
//            ]
//        ]
//        
//        return result
//    }
//    private func readDelayStart(_ payload:[UInt8], _ sno: Int)-> [AnyHashable:Any]?{
//        let result:[AnyHashable:Any] = [
//            "ack": [
//                "delay_start": readUInt32LE(payload, 0) // payload.readUInt32LE(0)
//            ]
//        ]
//        
//        return result
//    }
//    private func readParamInspect(_ payload:[UInt8], _ sno: Int)-> [AnyHashable:Any]? {
//        var result: [AnyHashable:Any]? = nil
//        if (payload[0] == 0) {
//            result = [
//                "ack": [
//                    "param_inspect": [
//                        "type": payload[0]
//                    ]
//                ]
//            ]
//        } else {
//            result = [
//                "ack": [
//                    "param_inspect": [
//                        "type":  payload[0],
//                        "interval": readUInt32LE(payload, 1) // payload.readUInt32LE(1)
//                    ]
//                ]
//            ]
//        }
//        
//        return result
//    }
//    public func parseBin(_ pkt:[UInt8], _ pktLen: inout Int?)->[AnyHashable:Any]? {
//        var result:[AnyHashable:Any]? = [:]
//        
//        if pktLen == nil {
//            pktLen = pkt.count
//        }
//        if (pkt.count != pktLen) {
//            return nil
//        }
//        if (pkt[0] != 170 || pkt[1] != 85) {
//            return nil
//        }
//    
//        let snoHigh = readUInt16LE(pkt, 6)
//        let snoLow = readUInt16LE(pkt, 2)
//        let sno = UInt64(snoHigh) + UInt64(snoLow)*0x10000 // let sno = Number(BigInt(snoHigh) + BigInt(snoLow) * 0x10000n);
////        let pkt_len = readUInt16LE(pkt, 4) // pkt.readInt16LE(4);
//        let pkt_len = readUInt16LE(pkt, 4)
//        if (pkt_len != pktLen! - 6) {
//            print("PKT_LEN != pktLEN")
//            return nil
//        }
//        
//        if ([0x82, 0x84].contains(pkt[9])) {
//            if (pkt[10] == 0) {
//                return [
//                    "cmd": "ok",
//                    "sno":sno
//                ]
//            } else {
//                return [
//                    "cmd": "failed",
//                    "errcode": pkt[10],
//                    "sno":sno
//                ]
//            }
//        }
//        else if (pkt[9] == 0x83) {
//            if (pkt.count == 10) {
//                return [
//                    "cmd": "failed",
//                    "errcode": 255,
//                    "sno": sno
//                ]
//            }
//          
//            let payload_len = readUInt8(pkt, 0xB) // pkt.readUInt8(0xB)
//            if (payload_len + 0xC + (((pkt[8] >> 7) != 0) ? 2 : 0) != pktLen!) {
//                print("payload_len + 0XC != ... ")
//                return nil
//            }
//            
//            let cmd = pkt[10]
//            // console.log(`sno=${sno}`);
//            // console.log(`type=${pkt[9].toString(16)}`);
//            // console.log(`cmd=${cmd.toString(16)}`);
//            
//            let payload_slice = pkt[0xC...]
//            let payload = Array(payload_slice)
//            
//            print("The payload: \(payload)")
//            
//            switch(cmd) {
//            case 1:
//                result = readNet(payload, Int(sno))
//                break;
//            case 2:
//                result = readGprs(payload, Int(sno));
//                break;
//            case 3:
//                result = readSvr(payload, Int(sno));
//                break;
//            case 4:
//                result = readPower(payload, Int(sno));
//                break;
//            case 6:
//                result = readLight(payload, Int(sno));
//                break;
//            case 10:
//                result = readDevInfo(payload, Int(sno))
//                break;
//            case 0xB:
//                result = readParamDev(payload, Int(sno));
//                break;
//            case 0x1A:
//                result = readConfigRes(payload, Int(sno));
//                break;
//            case 0x1B:
//                result = readParamDevEx(payload, Int(sno));
//                break;
//            case 0x1E:
//                result = readBaudRate(payload, Int(sno));
//                break;
//            case 0x20:
//                result = readWiFi(payload, Int(sno));
//                break;
//            case 0x21:
//                result = readParamTiming(payload, Int(sno));
//                break;
//            case 0x25:
//                result = readSync(payload, Int(sno));
//                break;
//            case 0x28:
//                result = readDelayStart(payload, Int(sno));
//                break;
//            case 0x2B:
//                result = readParamInspect(payload, Int(sno));
//                break;
//            default:
//                result = [
//                    "notImplemented": true,
//                    "cmd":0,
//                    "payload":0,
//                    "sno":sno
//                ]
//            }
//            result?["sno"] = sno
//        } else {
//            print("The 9th index of packet neither 130,131 or 132")
//            return nil
//        }
//        
//        return result
//    }
//    private func readUInt32LE(_ img:[UInt8], _ offset: Int) -> Int{
//        if offset+3>=img.count {return 0}
//        var str = ""
//        str += String(img[offset+3],radix: 16)
//        str += String(img[offset+2],radix: 16)
//        str += String(img[offset+1],radix: 16)
//        str += String(img[offset],radix: 16)
//        return Int(str, radix: 16) ?? 0
//    }
//    private func readUInt16LE(_ img:[UInt8], _ offset: Int) -> Int{
//        if offset+1>=img.count {return 0}
//        var str = ""
//        str += String(img[offset+1],radix: 16)
//        str += String(img[offset],radix: 16)
//        return Int(str, radix: 16) ?? 0
//    }
//    private func readUInt8(_ img:[UInt8], _ offset: Int) -> UInt8 {
//        return img[offset]
//    }
//    
////    private func pixelValuesFromImage(cgImage: CGImage?) -> ([UInt8]?, width: Int, height: Int)
////    {
////        var width = 0
////        var height = 0
////        var pixelValues: [UInt8]?
////        
////        guard let imageRef = cgImage else {return (nil,0,0)}
////        width = imageRef.width
////        height = imageRef.height
////        let bitsPerComponent = imageRef.bitsPerComponent
////        let bytesPerRow = imageRef.bytesPerRow
////        let totalBytes = height * bytesPerRow
////        
////        let colorSpace = CGColorSpaceCreateDeviceGray()
////        //        let colorSpace = CGColorSpaceCreateDeviceRGB()
////        var buffer = [UInt8]()
////        for i in 0..<totalBytes {
////            buffer.append(0)
////        }
////        let mutablePointer = UnsafeMutablePointer<UInt8>(mutating: buffer)
////        
////        let contextRef = CGContext(data: mutablePointer, width: width, height: height, bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: 0)
////        CGContextDrawImage(contextRef, CGRectMake(0.0, 0.0, CGFloat(width), CGFloat(height)), imageRef)
////        
////        let bufferPointer = UnsafeBufferPointer<UInt8>(start: mutablePointer, count: totalBytes)
////        pixelValues = Array<UInt8>(arrayLiteral: bufferPointer)
////        
////
////        return (pixelValues, width, height)
////    }
//}
//
//
//
//
