//
//  Type.swift
//  iOS Bootcamp Challenge
//
//  Created by Sandra Herrera on 12/10/21.
//

import Foundation

struct Type: Decodable {
    let name: String
    let url: String
    
    enum CodingKeys: String, CodingKey {
        case name, url
    }
}

struct Types: Decodable {
    let type: Type
    let slot: Int
    
    enum CodingKeys: String, CodingKey {
        case type
        case slot
    }
}
