//
//  CoffeeRecipe.swift
//  Koffeer
//
//  Created by Andrii Bryzhnychenko on 10/28/26.
//

import Foundation

struct CoffeeRecipe: Decodable, Identifiable {
    enum Method: String, Decodable {
        case v60
        case aeropress
    }

    struct Step: Decodable {
        enum Action: String, Decodable {
            case pour
            case wait
            case stir
            case press
        }

        let action: Action
        let instruction: String
        let startTimeSeconds: Int?
        let waterToAddGrams: Double?
    }

    let id: String
    let name: String
    let method: Method
    let author: String
    let sourceURL: URL?
    let coffeeGrams: Double
    let waterGrams: Double
    let waterTemperatureCelsius: Double
    let grind: String
    let targetDurationSeconds: Int
    let steps: [Step]
}
