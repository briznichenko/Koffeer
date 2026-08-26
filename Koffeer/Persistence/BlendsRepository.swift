import Foundation
import SwiftData

@MainActor
protocol BlendsRepository {
    func fetchBlends() async throws -> [CoffeeBlend]
    func insert(_ blend: CoffeeBlend) async throws
    func update(_ blend: CoffeeBlend) async throws
    func delete(_ blend: CoffeeBlend) async throws
}
