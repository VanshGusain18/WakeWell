//
//  Activities.swift
//  riseRitual
//
//  Created by geu on 31/01/26.
//
import Foundation

// MARK: - Ritual Card
struct Ritual: Codable, Identifiable {
    let id: String
    let name: String
    let description: String
    let imagePath: String
    let scienceReference: String
    let category: String
    
    enum CodingKeys: String, CodingKey {
        case id, name, category
        case description = "description"
        case imagePath = "image_path"
        case scienceReference = "science_reference"
    }
}

// MARK: - Ritual Category
enum RitualCategory: String, CaseIterable {
    case mindfulness = "mindfulness"
    case physical = "physical"
    case nutrition = "nutrition"
    case productivity = "productivity"
    
    var displayName: String {
        switch self {
        case .mindfulness: return "mindfulness"
        case .physical: return "physical"
        case .nutrition: return "nutrition"
        case .productivity: return "productivity"
        }
    }
    
    var icon: String {
        switch self {
        case .mindfulness: return "🧘"
        case .physical: return "🏃"
        case .nutrition: return "🍳"
        case .productivity: return "📑"
        }
    }
}
