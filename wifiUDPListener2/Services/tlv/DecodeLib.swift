//
//  DecodeLib.swift
//  wifiUDPListener2
//
//  Created by Maksim on 13.09.2021.

//2 - частая ошибка, 9 - когда не поддерживал формат

import Foundation

class DecodeLib: IntReader {
        static let shared = DecodeLib()
    
    public func parseBinAndReturnView(string: String) -> [String: Any] {
        var length: Int? = nil
        var current = ""
        var pkt = [UInt8]()
        var i = 0
        while i < string.count {
            current += String(string[i])
            current += String(string[i+1])
            pkt.append(UInt8(Int(current,radix: 16) ?? -1))
            current = ""
            i += 2
        }
        
        guard let result = parseBin(pkt: pkt, pktLen: &length) as? [String: Any] else { return ["cmd": "failedGuard"] }
        print("Result of ParseBin is - ", result)
        return result
    }
        
        public func parseBin(pkt: [UInt8], pktLen: inout Int?) -> [String: Any]? {
            var result: [String: Any] = [:]
            let packetLength = pktLen ?? pkt.count

            if packetLength != pkt.count || pkt[0] != 170 || pkt[1] != 85 {
                print("Error #1 in parseBin")
                return nil
            }
            
            guard let snoHigh = readInt16LE(arrayOfInts: pkt, offset: 6), //makeLittle16(pkt, 6) // pkt.readUInt16LE(6)
                  let snoLow = readInt16LE(arrayOfInts: pkt, offset: 2) else {
                print("Error in parseBin - snoHigh and snoLow")
                return nil
            }
            //makeLittle16(pkt, 2) //pkt.readUInt16LE(2)
            
            let sno = Int(UInt64(snoHigh) + UInt64(snoLow)*0x10000)
            print("Sno in parseBin is \(sno)")
            // let sno = Number(BigInt(snoHigh) + BigInt(snoLow) * 0x10000n);
            guard let pkt_len = readInt16LE(arrayOfInts: pkt, offset: 4) else {
                print("Error in ParseBin in pkt_len")
                return nil
            }
            print("pkt_len" ,pkt_len)
            //makeLittle16(pkt, 4) // pkt.readInt16LE(4);
            
            if (pkt_len != packetLength - 6) {
                print("Error #2 in parseBin")
                return nil
            }
            
            if ([0x82, 0x84].contains(pkt[9])) {
                if (pkt[10] == 0) {
                    return [
                        "cmd": "ok",
                        "sno": sno
                    ]
                } else {
                    return [
                        "cmd": "failed",
                        "errcode": pkt[10],
                        "sno": sno
                    ]
                }
            } else if (pkt[9] == 0x83) {
                if (pkt.count == 10) {
                    return [
                        "cmd": "failed",
                        "errcode": 255,
                        "sno": sno
                    ]
                }
                
                guard let payload_len = readUInt8(arrayOfInts: pkt, offset: 0xB) else {
                    print("Error in parseBin - readUInt8")
                    return nil
                }
                // pkt.readUInt8(0xB)
                let valForPkt8: UInt8 = ((pkt[8] >> 7) != 0) ? 2 : 0
                if (payload_len + 0xC + valForPkt8 != packetLength) {
                    print("Error #3 in parseBin")
                    return nil
                }
                
                let cmd = pkt[10]
                // console.log(`sno=${sno}`);
                // console.log(`type=${pkt[9].toString(16)}`);
                // console.log(`cmd=${cmd.toString(16)}`);
                
                let index = pkt.index(pkt.startIndex, offsetBy: 12) //0xC
                let payload: [UInt8] = Array(pkt[index...])
                
                switch(cmd) {
                case 1:
                    result = readNet(payload: payload, sno: sno)
                    break;
                case 2:
                    result = readGprs(payload: payload, sno: sno);
                    break;
                case 3:
                    result = readSvr(payload: payload, sno: sno);
                    break;
                case 4:
                    result = readPower(payload: payload, sno: sno);
                    break;
                case 6:
                    result = readLight(payload: payload, sno: sno);
                    break;
                case 10:
                    result = readDevInfo(payload: payload, sno: sno);
                    break;
                case 0xB:
                    result = readParamDev(payload: payload, sno: sno);
                    break;
                case 0x1A:
                    result = readConfigRes(payload: payload, sno: sno);
                    break;
                case 0x1B:
                    result = readParamDevEx(payload, sno);
                    break;
                case 0x1E:
                    result = readBaudRate(payload: payload, sno: sno);
                    break;
                case 0x20:
                    result = readWiFi(payload: payload, sno: sno);
                    break;
                case 0x21:
                    result = readParamTiming(payload: payload, sno: sno);
                    break;
                case 0x25:
                    result = readSync(payload: payload, sno: sno);
                    break;
                case 0x28:
                    result = readDelayStart(payload: payload, sno: sno);
                    break;
                case 0x2B:
                    result = readParamInspect(payload: payload, sno: sno);
                    break;
                default:
                    result = [
                        "notImplemented": true,
                        "cmd":0,
                        "payload":0,
                        "sno":sno
                    ]
                }
                result["sno"] = sno
            } else {
                print("ParseBin return nil")
                return nil
            }
            
            return result
        }
        
        // sub - functions
        // 01
            private func readNet(payload: [UInt8], sno: Int) -> [String: Any] {
                let parts = payload.map(String.init)
                let result: [String: Any] = [
                    "ack": [
                        "param_net": [
                            "mac": parts[0],
                            "port_udp_svr": parts[1],
                            "port_udp_dev": parts[2],
                            "type": parts[3],
                            "ip": parts[4],
                            "mask": parts[5],
                            "gateway": parts[6],
                            "dns": parts[7]
                        ]
                    ]
                ]
                return result
            }
        
        // 02
            private func readGprs(payload: [UInt8], sno: Int) -> [String: Any] {
                let parts = payload.map(String.init)
                let result: [String: Any] = [
                    "ack": [
                        "param_gprs": [
                            "apn": parts[0],
                            "user": parts[1],
                            "pwd": parts[2]
                        ]
                    ]
                ]
                return result
            }
        
        // 03
            private func readSvr(payload: [UInt8], sno: Int) -> [String: Any] {
                let parts = payload.map(String.init)
                let result: [String: Any] = [
                    "ack": [
                        "param_svr": [
                            "type": parts[0],
                            "ip": parts[1],
                            "port": parts[2],
                            "sec_hb": parts[3]
                        ]
                    ]
                ]
                return result
            }
        
        // 04
            private func readPower(payload: [UInt8], sno: Int) -> [String: Any] {
                var result: [String: Any] = [:]
                if (payload[0] == 0) {
                    result = [
                        "ack": [
                            "power": [
                                "type": payload[1]
                            ]
                        ]
                    ]
                } else {
                    result = [
                        "ack": [
                            "payload": payload,
                            "power": []
                        ]
                    ]
                }
                return result
            }
        
        // 05
            private func readLight(payload: [UInt8], sno: Int) -> [String: Any] {
                guard payload[0] == 0  else {
                    print("Error in readLight")
                    return [:]
                }
                let result: [String: Any] = [
                        "ack": [
                        "light": [
                            "type": 0,
                            "value_fix": payload[1]]
                        ],
                        "sno": sno
                    ]
                return result
            }
        
        // 06
        private func readDevInfo(payload: [UInt8], sno: Int) -> [String: Any] {
            //let tmpString = payload.map { String($0) }.joined(separator: ",")
            var tmpString = ""
            for part in payload {
                tmpString.append(Character(UnicodeScalar(part) ?? "?"))
            }
            print("tmpString is - ", tmpString)
            //let parts = matcheStrings(for: "/^([^,]*),([^,]*),([^,]*),(.*)$/", in: tmpString)
            
            // manual matching for regex
            var parts: [String] = []
            var count = 0
            var current = ""
            
            for char in tmpString {
                if char == "," {
                    if (count == 3){
                        continue
                    }else{
                        parts.append(current)
                        current = ""
                    }
                    count += 1
                }else{
                    current += String(char)
                }
            }
            if current != "" {
                parts.append(current)
            }
            print(parts)
            //end manual
            
            let result: [String: Any] = [
                    "ack": [
                        "dev_info": [
                            "id_dev": parts[0],
                            "version": String(parts[1]+"_"+parts[2]),
                            "model": parts[3]
                        ]
                    ],
                    "sno": sno
                ]
                return result
            }
        
        // 07
            private func readParamDev(payload: [UInt8], sno: Int) -> [String: Any] {
                let result: [String: Any] = [
                    "ack": [
                        "param_dev": [
                            "width": readUInt32LE(arrayOfInts: payload) as Any,
                            //makeLittle(payload, 0), // payload.readInt16LE(0)
                            "height": readUInt32LE(arrayOfInts: payload, offset: 2) as Any,
                            //makeLittle(payload, 2), //payload.readInt16LE(2)
                            "type_color": payload[4],
                            "polar_data": payload[5],
                            "polar_oe": payload[6],
                            "type_scan": payload[7],
                            "angle_rotate": payload[8],
                            "rate_frame": payload[9],
                            "delay_frame":payload[10]
                        ]
                    ],
                    "sno":sno
                ]
                return result
            }
        
        // 08
            private func readConfigRes(payload: [UInt8], sno: Int) -> [String: Any] {
                let result: [String: Any] = [
                    "ack": [
                        "config_res": [
                            "max_count_pgm": payload[0],
                            "max_count_rect": payload[1],
                            "max_count_item": payload[2]
                        ]
                    ]
                ]
                return result
            }
        
        // 09
            private func readParamDevEx(_ payload: [UInt8], _ sno: Int) -> [String: Any] {
                let index = payload.index(payload.startIndex, offsetBy: 16) // 0x10
                let newPayload = payload[index...]
        
                let result: [String: Any] = [
                    "ack": [
                        "param_dev": [
                            "width": readUInt32LE(arrayOfInts: payload, offset: 1) as Any,
                                //makeLittle(payload, 1), //payload.readInt16LE(1)
                            "height": readUInt32LE(arrayOfInts: payload, offset: 3) as Any,
                                //makeLittle(payload, 3), // payload.readInt16LE(3)
                            "polar_data": payload[5],
                            "polar_oe": payload[6],
                            "type_color": payload[7] == 0 ? 1 : payload[7],
                            "gray": payload[8] - 1,
                            "decoder": 1,
                            "type_scan": 1,
                            "line_bank": payload[0xB],
                            "segment": payload[0xC],
                            "delay_frame":payload[0xD],
                            "rate_frame": payload[0xE],
                            "backgroup": payload[0xF],
                            "count_io": payload.count - 0x10,
                            "data_out": [newPayload]
                            //DONE 1 // TO DO: [...payload.slice(0x10)] how to convert this ?
                        ]
                    ],
                    "sno": sno
                ]
                return result
            }
        
        // 10
            private func readBaudRate(payload: [UInt8], sno: Int) -> [String: Any] {
                let result: [String: Any] = [
                    "ack": [
                        "baudrate": readUInt32LE(arrayOfInts: payload)
                        //makeLittle(payload, 0) // payload.readUInt32LE(0)
                    ]
                ]
                return result
            }
        // 11
            private func readWiFi(payload: [UInt8], sno: Int) -> [String: Any] {
                let parts = payload.map(String.init)
                let result: [String: Any] = [
                    "ack": [
                        "param_wifi": [
                            "type": parts[0],
                            "user": parts[1],
                            "pwd": parts[2],
                            "user_coe": parts[3],
                            "pwd_coe": parts[4]
                        ]
                    ]
                ]
                return result
            }
        // 12
            private func readParamTiming(payload: [UInt8], sno: Int) -> [String: Any] {
                let result: [String: Any] = [
                    "ack": [
                        "param_timing": [
                            "interval": readUInt32LE(arrayOfInts: payload) as Any,
                            //makeLittle(payload, 0) , // payload.readUInt16LE(0)
                                    "timezone": payload[2]/4
                        ]
                    ]
                ]
                return result
            }
        // 13
            private func readSync(payload: [UInt8], sno: Int) -> [String: Any] {
                let result: [String: Any] = [
                    "ack": [
                        "sync": payload[0]
                    ]
                ]
        
                return result
            }
        // 14
            private func readDelayStart(payload: [UInt8], sno: Int) -> [String: Any] {
                let result: [String: Any] = [
                    "ack": [
                        "delay_start": readUInt32LE(arrayOfInts: payload, offset: 0)
                        //makeLittle(payload, 0) // payload.readUInt32LE(0)
                    ]
                ]
                return result
            }
        // 15
            private func readParamInspect(payload: [UInt8], sno: Int) -> [String: Any] {
                var result: [String: Any] = [:]
                if (payload[0] == 0) {
                    result = [
                        "ack": [
                            "param_inspect": [
                                "type": payload[0]
                            ]
                        ]
                    ]
                } else {
                    result = [
                        "ack": [
                            "param_inspect": [
                                "type": payload[0],
                                "interval": readUInt32LE(arrayOfInts: payload, offset: 1) as Any
                                // makeLittle(payload, 1) // payload.readUInt32LE(1)
                            ]
                        ]
                    ]
                }
                return result
            }
        

    }

//MARK: -> Extension
extension DecodeLib {
        
        // string.match() in JavaScript
        public func matcheStrings(for regex: String, in text: String) -> [String] {
        
            do {
                let regex = try NSRegularExpression(pattern: regex)
                let results = regex.matches(in: text, range: NSRange(text.startIndex..., in: text))
                return results.map { String(text[Range($0.range, in: text)!]) }
        
        //        return results.map { str in
        //            if let range = Range(str.range, in: text) {
        //                let tmpStr = String(text[range])
        //
        //            } else {
        //                print("Error in matcheStrings")
        //            }
        //            return tmpStr
        //        }
        
            } catch let error {
                print("invalid regex: \(error.localizedDescription)")
                return []
            }
        }
}

    


