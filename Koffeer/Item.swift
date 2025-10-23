//
//  Item.swift
//  Koffeer
//
//  Created by Andrii Bryzhnychenko on 10/23/25.
//

import Foundation
import SwiftData

@Model
final class Item {
    enum ItemType: String, Codable {
        case v60
        case aeropress
    }
    
    var timestamp: Date
    var type: ItemType?
    var imageData: Data?
    var steps: [Int]
    
    init(timestamp: Date, type: ItemType, steps: [Int]) {
        self.timestamp = timestamp
        self.type = type
        self.steps = steps.sorted()
    }
}
