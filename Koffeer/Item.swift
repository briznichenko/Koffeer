//
//  Item.swift
//  Koffeer
//
//  Created by Andrii Bryzhnychenko on 10/23/25.
//

import Foundation
import SwiftData

@Model
final class CoffeeBlend {
    var name: String
    var sweetness: Int
    var sourness: Int
    var bitterness: Int
    var imageData: Data?
    
    init(name: String, sweetness: Int? = nil, sourness: Int? = nil, bitterness: Int? = nil, imageData: Data? = nil) {
        self.name = name
        self.sweetness = sweetness ?? 0
        self.sourness = sourness ?? 0
        self.bitterness = bitterness ?? 0
        self.imageData = imageData
    }
}

@Model
final class Item {
    enum ItemType: String, Codable {
        case v60
        case aeropress
    }
    
    var timestamp: Date
    var type: ItemType?
    var coffeeBlend: CoffeeBlend
    
    var steps: [Int]
    
    init(timestamp: Date, type: ItemType, steps: [Int]) {
        self.timestamp = timestamp
        self.type = type
        self.steps = steps.sorted()
        self.coffeeBlend = .init(name: "New Blend")
    }
}
