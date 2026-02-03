// MARK: - Imports
@testable import EffectiveMobile
import Foundation
import XCTest

// MARK: - TaskForResponse Decoding Tests
final class TaskForResponseTests: XCTestCase {
    
    // MARK: - Test Methods
    func testTaskForResponseDecoding() throws {
        // MARK: - Given
        let json = """
        {
            "id": 1,
            "todo": "Buy milk",
            "completed": false,
            "userId": 5
        }
        """.data(using: .utf8)!
        
        // MARK: - When
        let task = try JSONDecoder().decode(TaskForResponse.self, from: json)
        
        // MARK: - Then
        XCTAssertEqual(task.id, 1)
        XCTAssertEqual(task.todo, "Buy milk")
        XCTAssertFalse(task.completed)
        XCTAssertEqual(task.userId, 5)
    }
}
