import Foundation
import UIKit

struct StoreUpdate: StoreUpdateProtocol {
    struct Move: MoveProtocol {
        let oldIndex: Int
        let newIndex: Int
    }
    let insertedIndexes: IndexSet
    let deletedIndexes: IndexSet
    let updatedIndexes: IndexSet
    let movedIndexes: Set<Move>
}

final class Constants {
    static let firstLaunchServicekey = "hasLaunchedBefore"
    
    static let attributesWithStrikethrough: [NSAttributedString.Key: Any] = [
        .strikethroughStyle: NSUnderlineStyle.single.rawValue,
        .strikethroughColor: UIColor.semiLightWhiteForText,
        .foregroundColor: UIColor.semiLightWhiteForText
    ]
    
    static let attributesWithoutStrikethrough: [NSAttributedString.Key: Any] = [
        .foregroundColor: UIColor.whiteForText,
        .strikethroughStyle: 0
    ]
    
    static let dayMonthYear: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        formatter.locale = Locale(identifier: "en_GB")
        formatter.timeZone = .current
        
        return formatter
    }()
}
