//
//  TestStructure.swift
//  Waadsu
//
//  Created by Assylzhan Nurlybekuly on 22.09.2021.
//

import Foundation



// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let welcome = try? newJSONDecoder().decode(Welcome.self, from: jsonData)

import Foundation

// MARK: - TestStructure
struct TestStructure: Codable {
    let json: JSON
    let binary: Binary

    enum CodingKeys: String, CodingKey {
        case json = "JSON"
        case binary = "Binary"
    }
}

enum Binary: Codable {
    case string(String)
    case stringArray([String])

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let x = try? container.decode([String].self) {
            self = .stringArray(x)
            return
        }
        if let x = try? container.decode(String.self) {
            self = .string(x)
            return
        }
        throw DecodingError.typeMismatch(Binary.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for Binary"))
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .string(let x):
            try container.encode(x)
        case .stringArray(let x):
            try container.encode(x)
        }
    }
}

// MARK: - JSON
struct JSON: Codable {
    let cmd: Cmd?
    let ack: ACK?
    let sno: Sno?
    let idsDev: String?
    let pktsProgram: PktsProgram?

    enum CodingKeys: String, CodingKey {
        case cmd, ack, sno
        case idsDev = "ids_dev"
        case pktsProgram = "pkts_program"
    }
}

// MARK: - ACK
struct ACK: Codable {
    let devInfo: DevInfo?
    let paramDev: ParamDev?
    let light: Light?

    enum CodingKeys: String, CodingKey {
        case devInfo = "dev_info"
        case paramDev = "param_dev"
        case light
    }
}

// MARK: - DevInfo
struct DevInfo: Codable {
    let idDev, version, model: String

    enum CodingKeys: String, CodingKey {
        case idDev = "id_dev"
        case version, model
    }
}

// MARK: - Light
struct Light: Codable {
    let type, valueFix: Int

    enum CodingKeys: String, CodingKey {
        case type
        case valueFix = "value_fix"
    }
}

// MARK: - ParamDev
struct ParamDev: Codable {
    let width, height, polarData, polarOe: Int
    let typeColor, gray, decoder, typeScan: Int
    let lineBank, segment, delayFrame, rateFrame: Int
    let backgroup, countIo: Int
    let dataOut: [Int]

    enum CodingKeys: String, CodingKey {
        case width, height
        case polarData = "polar_data"
        case polarOe = "polar_oe"
        case typeColor = "type_color"
        case gray, decoder
        case typeScan = "type_scan"
        case lineBank = "line_bank"
        case segment
        case delayFrame = "delay_frame"
        case rateFrame = "rate_frame"
        case backgroup
        case countIo = "count_io"
        case dataOut = "data_out"
    }
}

// MARK: - Cmd
struct Cmd: Codable {
    let cmdGet: String

    enum CodingKeys: String, CodingKey {
        case cmdGet = "get"
    }
}

// MARK: - PktsProgram
struct PktsProgram: Codable {
    let idPro: Int
    let listRegion: [ListRegion]
    let propertyPro: [String: Int]

    enum CodingKeys: String, CodingKey {
        case idPro = "id_pro"
        case listRegion = "list_region"
        case propertyPro = "property_pro"
    }
}

// MARK: - ListRegion
struct ListRegion: Codable {
    let infoPos: InfoPos
    let listItem: [ListItem]

    enum CodingKeys: String, CodingKey {
        case infoPos = "info_pos"
        case listItem = "list_item"
    }
}

// MARK: - InfoPos
struct InfoPos: Codable {
    let h, w, x, y: Int
}

// MARK: - ListItem
struct ListItem: Codable {
    let infoAnimate: InfoAnimate
    let infoBorder: InfoBorder
    let isGIF: Int
    let typeItem: String
    let zipBMP, zipGIF: String?

    enum CodingKeys: String, CodingKey {
        case infoAnimate = "info_animate"
        case infoBorder = "info_border"
        case isGIF = "isGif"
        case typeItem = "type_item"
        case zipBMP = "zip_bmp"
        case zipGIF = "zip_gif"
    }
}

// MARK: - InfoAnimate
struct InfoAnimate: Codable {
    let modelNormal, speed, timeStay: Int

    enum CodingKeys: String, CodingKey {
        case modelNormal = "model_normal"
        case speed
        case timeStay = "time_stay"
    }
}

// MARK: - InfoBorder
struct InfoBorder: Codable {
    let fixedValue: Int
    let type: String

    enum CodingKeys: String, CodingKey {
        case fixedValue = "fixed_value"
        case type
    }
}

enum Sno: Codable {
    case integer(Int)
    case string(String)

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let x = try? container.decode(Int.self) {
            self = .integer(x)
            return
        }
        if let x = try? container.decode(String.self) {
            self = .string(x)
            return
        }
        throw DecodingError.typeMismatch(Sno.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for Sno"))
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .integer(let x):
            try container.encode(x)
        case .string(let x):
            try container.encode(x)
        }
    }
}

typealias Tests = [TestStructure]
