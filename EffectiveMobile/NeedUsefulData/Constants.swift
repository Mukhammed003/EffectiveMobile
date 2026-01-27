import Foundation

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
}
