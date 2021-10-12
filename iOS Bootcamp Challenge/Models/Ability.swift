//
//  Ability.swift
//  iOS Bootcamp Challenge
//
//  Created by Sandra Herrera on 12/10/21.
//

import Foundation


struct Ability: Decodable {
    let name: String
    let url: String
    
    enum CodingKeys: String, CodingKey {
        case name, url
    }
}

struct Abilities: Decodable {
    let ability: Ability
    let isHidden: Bool
    let slot: Int
    
    enum CodingKeys: String, CodingKey {
        case ability
        case slot
        case isHidden = "is_hidden"
    }
}
