import XCTest
@testable import EffectiveMobile

final class TaskServiceImplTests: XCTestCase {

    private var service: TaskServiceImpl!
    private var mockNetworkClient: MockNetworkClient!

    override func setUp() {
        super.setUp()
        mockNetworkClient = MockNetworkClient()
        service = TaskServiceImpl(networkClient: mockNetworkClient)
    }

    override func tearDown() {
        service = nil
        mockNetworkClient = nil
        super.tearDown()
    }

    func testGetUsers_Success() {
        mockNetworkClient.shouldFail = false

        let expectation = self.expectation(description: "Completion called")

        _ = service.getUsers { result in
            switch result {
            case .success(let response):
                XCTAssertEqual(response.todos.count, 2)
            case .failure:
                XCTFail("Expected success")
            }
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1)
    }

    func testGetUsers_Failure() {
        mockNetworkClient.shouldFail = true

        let expectation = self.expectation(description: "Completion called")

        _ = service.getUsers { result in
            switch result {
            case .success:
                XCTFail("Expected failure")
            case .failure:
                XCTAssertTrue(true)
            }
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1)
    }
}

// MARK: - Mocks

private class MockNetworkClient: NetworkClient {
    var shouldFail = false

    func send<T>(request: NetworkRequest, type: T.Type, completionQueue: DispatchQueue, onResponse: @escaping (Result<T, Error>) -> Void) -> NetworkTask? where T : Decodable {
        if shouldFail {
            completionQueue.async { onResponse(.failure(NSError(domain: "Test", code: 1))) }
        } else {
            let mockResponse = TasksListForResponse.mock() as! T
            completionQueue.async { onResponse(.success(mockResponse)) }
        }
        return nil
    }

    func send(request: NetworkRequest, completionQueue: DispatchQueue, onResponse: @escaping (Result<Data, Error>) -> Void) -> NetworkTask? {
        return nil
    }
}

// Mock response
private extension TasksListForResponse {
    static func mock() -> TasksListForResponse {
        return TasksListForResponse(todos: [
            .init(id: 1, todo: "Task 1", completed: false, userId: 12),
            .init(id: 2, todo: "Task 2", completed: true, userId: 21)
        ], total: 2, skip: 2, limit: 2)
    }
}
