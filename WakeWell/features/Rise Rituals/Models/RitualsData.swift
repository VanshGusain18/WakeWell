//
//  RitualsData.swift
//  riseRitual
//
//  Created by geu on 31/01/26.
//
import Foundation

// MARK: - Rituals Data Manager
class RitualsData: Codable {
    
    var rituals: [Ritual] = []

    init() {
        do {
            // Mirrors the initialization logic in DestinationsData
            let response = try load()
            rituals = response.rituals
        } catch {
            print("Error loading rituals: \(error.localizedDescription)")
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case rituals
    }
    
    // Helper to get all rituals for a specific category string
    func getRituals(type: String) -> [Ritual] {
        return rituals.filter { ritual in
            ritual.category == type
        }
    }
}

// MARK: - JSON Loading Helper
extension RitualsData {
    /// Load rituals from the rituals.json file
    func load(from filename: String = "Rituals") throws -> RitualsData {
        guard let url = Bundle.main.url(forResource: filename, withExtension: "json") else {
            throw NSError(domain: "RitualsResponse", code: 404,
                         userInfo: [NSLocalizedDescriptionKey: "\(filename).json not found"])
        }

        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        
        // This follows the decoding pattern used for DestinationsData
        do {
            return try decoder.decode(RitualsData.self, from: data)
        } catch {
            print("Decoding error: \(error.localizedDescription)")
            throw error
        }
    }
}

// MARK: - Filtering Extensions
extension RitualsData {
    /// Get rituals using the type-safe RitualCategory enum
    func rituals(for category: RitualCategory) -> [Ritual] {
        rituals.filter { $0.category == category.rawValue }
    }

    /// Group rituals by category for UICollectionView sections
    var ritualsByCategory: [RitualCategory: [Ritual]] {
        var grouped: [RitualCategory: [Ritual]] = [:]

        for category in RitualCategory.allCases {
            grouped[category] = rituals(for: category)
        }

        return grouped
    }
}
