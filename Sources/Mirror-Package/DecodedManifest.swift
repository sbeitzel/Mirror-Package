//
//  DecodedManifest.swift
//  
//
//  Created by Stephen Beitzel on 6/4/22.
//

import Foundation

struct DecodedManifest: Decodable {
    enum CodingKeys: CodingKey { case pins, version }

    let version: Int
    let pins: [Pin]

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let fileVersion = try container.decode(Int.self, forKey: .version)
        if fileVersion != 2 {
            print("Unknown Package.resolved version! Got \(fileVersion) but I only handle version 2 (swift-tools-version:5.6)")
            throw ReadError.incompatibleVersion
        }
        self.version = fileVersion
        self.pins = try container.decode([Pin].self, forKey: .pins)
    }

}

enum ReadError: Error {
    case incompatibleVersion
    case unreadable
}

struct Pin: Decodable {
    enum CodingKeys: CodingKey { case identity, kind, location, state }

    let identity: String
    let kind: String
    let location: String

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.identity = try container.decode(String.self, forKey: .identity)
        self.kind = try container.decode(String.self, forKey: .kind)
        self.location = try container.decode(String.self, forKey: .location)
    }
}
