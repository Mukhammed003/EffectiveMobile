// MARK: - Base FRC Delegate Tests

// MARK: - Imports
import XCTest
import CoreData
@testable import EffectiveMobile

// MARK: - BaseFRCDelegateTests
final class BaseFRCDelegateTests: XCTestCase {
    
    // MARK: - FRC Setup
    let frc = NSFetchedResultsController<NSFetchRequestResult>(
        fetchRequest: NSFetchRequest<NSFetchRequestResult>(entityName: "DummyEntity"),
        managedObjectContext: NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType),
        sectionNameKeyPath: nil,
        cacheName: nil
    )
    
    // MARK: - Test Models
    struct TestMove: MoveProtocol {
        let oldIndex: Int
        let newIndex: Int
    }
    
    struct TestUpdate: StoreUpdateProtocol {
        typealias Move = TestMove
        let insertedIndexes: IndexSet
        let deletedIndexes: IndexSet
        let updatedIndexes: IndexSet
        let movedIndexes: Set<TestMove>
    }
    
    // MARK: - Helpers
    private func makeDelegate(capture: @escaping (TestUpdate) -> Void) -> BaseFetchedResultsControllerDelegate<TestUpdate> {
        return BaseFetchedResultsControllerDelegate<TestUpdate>(
            ownerName: "TestOwner",
            notifyHandler: capture
        )
    }
    
    // MARK: - Insert Tests
    func test_insert_index() {
        // MARK: - Given
        var capturedUpdate: TestUpdate?
        let delegate = makeDelegate { update in
            capturedUpdate = update
        }
        delegate.controllerWillChangeContent(frc)
        
        // MARK: - When
        delegate.controller(
            frc,
            didChange: NSObject(),
            at: nil,
            for: .insert,
            newIndexPath: IndexPath(item: 0, section: 0)
        )
        delegate.controllerDidChangeContent(frc)
        
        // MARK: - Then
        XCTAssertEqual(capturedUpdate?.insertedIndexes, IndexSet([0]))
    }
    
    // MARK: - Delete Tests
    func test_delete_index() {
        // MARK: - Given
        var capturedUpdate: TestUpdate?
        let delegate = makeDelegate { update in
            capturedUpdate = update
        }
        delegate.controllerWillChangeContent(frc)
        
        // MARK: - When
        delegate.controller(
            frc,
            didChange: NSObject(),
            at: IndexPath(item: 1, section: 0),
            for: .delete,
            newIndexPath: nil
        )
        delegate.controllerDidChangeContent(frc)
        
        // MARK: - Then
        XCTAssertEqual(capturedUpdate?.deletedIndexes, IndexSet([1]))
    }
    
    // MARK: - Update Tests
    func test_update_index() {
        // MARK: - Given
        var capturedUpdate: TestUpdate?
        let delegate = makeDelegate { update in
            capturedUpdate = update
        }
        delegate.controllerWillChangeContent(frc)
        
        // MARK: - When
        delegate.controller(
            frc,
            didChange: NSObject(),
            at: IndexPath(item: 2, section: 0),
            for: .update,
            newIndexPath: nil
        )
        delegate.controllerDidChangeContent(frc)
        
        // MARK: - Then
        XCTAssertEqual(capturedUpdate?.updatedIndexes, IndexSet([2]))
    }
    
    // MARK: - Move Tests
    func test_move_index() {
        // MARK: - Given
        var capturedUpdate: TestUpdate?
        let delegate = makeDelegate { update in
            capturedUpdate = update
        }
        delegate.controllerWillChangeContent(frc)
        
        // MARK: - When
        delegate.controller(
            frc,
            didChange: NSObject(),
            at: IndexPath(item: 3, section: 0),
            for: .move,
            newIndexPath: IndexPath(item: 4, section: 0)
        )
        delegate.controllerDidChangeContent(frc)
        
        // MARK: - Then
        XCTAssertEqual(capturedUpdate?.movedIndexes, [TestMove(oldIndex: 3, newIndex: 4)])
    }
    
    // MARK: - Reset Tests
    func test_indexes_are_reset_after_notify() {
        // MARK: - Given
        var capturedUpdate: TestUpdate?
        let delegate = makeDelegate { update in
            capturedUpdate = update
        }
        delegate.controllerWillChangeContent(frc)
        
        // MARK: - When
        delegate.controller(
            frc,
            didChange: NSObject(),
            at: IndexPath(item: 0, section: 0),
            for: .insert,
            newIndexPath: IndexPath(item: 0, section: 0)
        )
        delegate.controllerDidChangeContent(frc)
        
        // MARK: - Then
        XCTAssertNil(delegate.insertedIndexes)
        XCTAssertNil(delegate.deletedIndexes)
        XCTAssertNil(delegate.updatedIndexes)
        XCTAssertNil(delegate.movedIndexes)
    }
}
