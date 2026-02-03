import XCTest
import CoreData
@testable import EffectiveMobile

final class BaseFRCDelegateTests: XCTestCase {
    
    let frc = NSFetchedResultsController<NSFetchRequestResult>(
        fetchRequest: NSFetchRequest<NSFetchRequestResult>(entityName: "DummyEntity"),
        managedObjectContext: NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType),
        sectionNameKeyPath: nil,
        cacheName: nil
    )
    
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
    
    private func makeDelegate(capture: @escaping (TestUpdate) -> Void) -> BaseFetchedResultsControllerDelegate<TestUpdate> {
        return BaseFetchedResultsControllerDelegate<TestUpdate>(
            ownerName: "TestOwner",
            notifyHandler: capture
        )
    }
    
    func test_insert_index() {
        var capturedUpdate: TestUpdate?
        let delegate = makeDelegate { update in
            capturedUpdate = update
        }
        delegate.controllerWillChangeContent(frc)
        
        delegate.controller(
            frc,
            didChange: NSObject(),
            at: nil,
            for: .insert,
            newIndexPath: IndexPath(item: 0, section: 0)
        )
        
        delegate.controllerDidChangeContent(frc)
        
        XCTAssertEqual(capturedUpdate?.insertedIndexes, IndexSet([0]))
    }
    
    func test_delete_index() {
        var capturedUpdate: TestUpdate?
        let delegate = makeDelegate { update in
            capturedUpdate = update
        }
        delegate.controllerWillChangeContent(frc)
        
        delegate.controller(
            frc,
            didChange: NSObject(),
            at: IndexPath(item: 1, section: 0),
            for: .delete,
            newIndexPath: nil
        )
        
        delegate.controllerDidChangeContent(frc)
        
        XCTAssertEqual(capturedUpdate?.deletedIndexes, IndexSet([1]))
    }
    
    func test_update_index() {
        var capturedUpdate: TestUpdate?
        let delegate = makeDelegate { update in
            capturedUpdate = update
        }
        delegate.controllerWillChangeContent(frc)
        
        delegate.controller(
            frc,
            didChange: NSObject(),
            at: IndexPath(item: 2, section: 0),
            for: .update,
            newIndexPath: nil
        )
        
        delegate.controllerDidChangeContent(frc)
        
        XCTAssertEqual(capturedUpdate?.updatedIndexes, IndexSet([2]))
    }
    
    func test_move_index() {
        var capturedUpdate: TestUpdate?
        let delegate = makeDelegate { update in
            capturedUpdate = update
        }
        delegate.controllerWillChangeContent(frc)
        
        delegate.controller(
            frc,
            didChange: NSObject(),
            at: IndexPath(item: 3, section: 0),
            for: .move,
            newIndexPath: IndexPath(item: 4, section: 0)
        )
        
        delegate.controllerDidChangeContent(frc)
        
        XCTAssertEqual(capturedUpdate?.movedIndexes, [TestMove(oldIndex: 3, newIndex: 4)])
    }
    
    func test_indexes_are_reset_after_notify() {
        var capturedUpdate: TestUpdate?
        let delegate = makeDelegate { update in
            capturedUpdate = update
        }
        delegate.controllerWillChangeContent(frc)
        
        delegate.controller(
            frc,
            didChange: NSObject(),
            at: IndexPath(item: 0, section: 0),
            for: .insert,
            newIndexPath: IndexPath(item: 0, section: 0)
        )
        
        delegate.controllerDidChangeContent(frc)
        
        XCTAssertNil(delegate.insertedIndexes)
        XCTAssertNil(delegate.deletedIndexes)
        XCTAssertNil(delegate.updatedIndexes)
        XCTAssertNil(delegate.movedIndexes)
    }
}

