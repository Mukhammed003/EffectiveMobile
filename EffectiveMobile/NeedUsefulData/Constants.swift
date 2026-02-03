import Foundation
import UIKit

// MARK: - Store Update

struct StoreUpdate: StoreUpdateProtocol {
    
    // MARK: - Move
    
    struct Move: MoveProtocol {
        let oldIndex: Int
        let newIndex: Int
    }
    
    // MARK: - Index Changes
    
    let insertedIndexes: IndexSet
    let deletedIndexes: IndexSet
    let updatedIndexes: IndexSet
    let movedIndexes: Set<Move>
}

// MARK: - App Constants

final class Constants {
    
    // MARK: - UserDefaults Keys
    
    static let firstLaunchServicekey = "hasLaunchedBefore"
    
    // MARK: - Text Attributes
    
    static let attributesWithStrikethrough: [NSAttributedString.Key: Any] = [
        .strikethroughStyle: NSUnderlineStyle.single.rawValue,
        .strikethroughColor: UIColor.semiLightWhiteForText,
        .foregroundColor: UIColor.semiLightWhiteForText
    ]
    
    static let attributesWithoutStrikethrough: [NSAttributedString.Key: Any] = [
        .foregroundColor: UIColor.whiteForText,
        .strikethroughStyle: 0
    ]
    
    // MARK: - Date Formatters
    
    static let dayMonthYear: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        formatter.locale = Locale(identifier: "en_GB")
        formatter.timeZone = .current
        
        return formatter
    }()
}
