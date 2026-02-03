import CoreData

// MARK: - Move Protocol

protocol MoveProtocol: Hashable {
    init(oldIndex: Int, newIndex: Int)
}

// MARK: - Store Update Protocol

protocol StoreUpdateProtocol {
    associatedtype Move: MoveProtocol
    init(
        insertedIndexes: IndexSet,
        deletedIndexes: IndexSet,
        updatedIndexes: IndexSet,
        movedIndexes: Set<Move>
    )
}

// MARK: - Base Fetched Results Controller Delegate

final class BaseFetchedResultsControllerDelegate<Update: StoreUpdateProtocol>: NSObject, NSFetchedResultsControllerDelegate {
    
    // MARK: - Change Tracking Storage
    
    var insertedIndexes: IndexSet?
    var deletedIndexes: IndexSet?
    var updatedIndexes: IndexSet?
    var movedIndexes: Set<Update.Move>?
    
    // MARK: - Dependencies
    
    private let notifyHandler: (Update) -> Void
    private let ownerName: String
    
    // MARK: - Initialization
    
    init(ownerName: String, notifyHandler: @escaping (Update) -> Void) {
        self.ownerName = ownerName
        self.notifyHandler = notifyHandler
    }
    
    // MARK: - NSFetchedResultsControllerDelegate
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        insertedIndexes = IndexSet()
        deletedIndexes = IndexSet()
        updatedIndexes = IndexSet()
        movedIndexes = Set<Update.Move>()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        print("🔔 FRC didChangeContent")
        
        let update = Update(
            insertedIndexes: insertedIndexes ?? [],
            deletedIndexes: deletedIndexes ?? [],
            updatedIndexes: updatedIndexes ?? [],
            movedIndexes: movedIndexes ?? []
        )
        
        notifyHandler(update)
        
        insertedIndexes = nil
        deletedIndexes = nil
        updatedIndexes = nil
        movedIndexes = nil
    }
    
    func controller(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>,
        didChange anObject: Any,
        at indexPath: IndexPath?,
        for type: NSFetchedResultsChangeType,
        newIndexPath: IndexPath?
    ) {
        switch type {
        case .insert:
            if let indexPath = newIndexPath {
                insertedIndexes?.insert(indexPath.item)
            }
        case .delete:
            if let indexPath = indexPath {
                deletedIndexes?.insert(indexPath.item)
            }
        case .update:
            if let indexPath = indexPath {
                updatedIndexes?.insert(indexPath.item)
            }
        case .move:
            if let oldIndexPath = indexPath, let newIndexPath = newIndexPath {
                movedIndexes?.insert(
                    .init(
                        oldIndex: oldIndexPath.item,
                        newIndex: newIndexPath.item
                    )
                )
            }
        @unknown default:
            print("⚠️ \(ownerName): неизвестный NSFetchedResultsChangeType")
        }
    }
}
