@testable import EffectiveMobile
import Foundation
import XCTest

final class TaskForResponseTests: XCTestCase {
    
    func testTaskForResponseDecoding() throws {
        let json = """
    {
        "id": 1,
        "todo": "Buy milk",
        "completed": false,
        "userId": 5
    }
    """.data(using: .utf8)!
        
        let task = try JSONDecoder().decode(TaskForResponse.self, from: json)
        
        XCTAssertEqual(task.id, 1)
        XCTAssertEqual(task.todo, "Buy milk")
        XCTAssertFalse(task.completed)
        XCTAssertEqual(task.userId, 5)
    }
    
}
