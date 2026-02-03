// MARK: - FirstLaunchService Tests

// MARK: - Imports
import XCTest
@testable import EffectiveMobile
import CoreData

// MARK: - FirstLaunchServiceTests
final class FirstLaunchServiceTests: XCTestCase {

    // MARK: - Properties
    private var service: FirstLaunchService!
    private var mockNetworkClient: MockNetworkClient!
    private var taskStore: TaskStore!
    private var presenter: MockPresenter!
    private var persistentContainer: NSPersistentContainer!

    // MARK: - Setup / Teardown
    override func setUp() {
        super.setUp()

        persistentContainer = NSPersistentContainer(name: "EffectiveMobile")
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        persistentContainer.persistentStoreDescriptions = [description]
        persistentContainer.loadPersistentStores { storeDescription, error in
            XCTAssertNil(error)
        }

        taskStore = TaskStore(persistentContainer: persistentContainer)

        mockNetworkClient = MockNetworkClient()
        let servicesAssembly = ServicesAssembly(networkClient: mockNetworkClient)

        presenter = MockPresenter()

        service = FirstLaunchService(servicesAssembly: servicesAssembly, taskStore: taskStore)
        service.presenter = presenter
    }

    override func tearDown() {
        service = nil
        mockNetworkClient = nil
        taskStore = nil
        presenter = nil
        persistentContainer = nil
        super.tearDown()
    }

    // MARK: - Tests

    func testFirstLaunch_SuccessfulLoad() {
        // MARK: - Given
        mockNetworkClient.shouldFail = false
        UserDefaults.standard.removeObject(forKey: Constants.firstLaunchServicekey)
        let expectation = self.expectation(description: "Completion called")

        // MARK: - When
        service.checkFirstLaunch()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            // MARK: - Then
            XCTAssertTrue(self.presenter.loaderShown)
            XCTAssertTrue(self.presenter.loaderHidden)
            XCTAssertFalse(self.presenter.errorShown)

            let tasks = self.taskStore.getAllTasks()
            XCTAssertEqual(tasks.count, 3)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 2)
    }

    func testFirstLaunch_FailedLoad_ShowsError() {
        // MARK: - Given
        mockNetworkClient.shouldFail = true
        UserDefaults.standard.removeObject(forKey: Constants.firstLaunchServicekey)
        let expectation = self.expectation(description: "Completion called")

        // MARK: - When
        service.checkFirstLaunch()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            // MARK: - Then
            XCTAssertTrue(self.presenter.loaderShown)
            XCTAssertTrue(self.presenter.loaderHidden)
            XCTAssertTrue(self.presenter.errorShown)

            let tasks = self.taskStore.getAllTasks()
            XCTAssertEqual(tasks.count, 0)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 2)
    }

    func testNotFirstLaunch_DoesNothing() {
        // MARK: - Given
        UserDefaults.standard.set(true, forKey: Constants.firstLaunchServicekey)
        let expectation = self.expectation(description: "Completion called")

        // MARK: - When
        service.checkFirstLaunch()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            // MARK: - Then
            XCTAssertFalse(self.presenter.loaderShown)
            XCTAssertFalse(self.presenter.loaderHidden)
            XCTAssertFalse(self.presenter.errorShown)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1)
    }
}

// MARK: - Mock Network Client
private class MockNetworkClient: NetworkClient {

    var shouldFail = false

    func send(request: NetworkRequest,
              completionQueue: DispatchQueue = .main,
              onResponse: @escaping (Result<Data, Error>) -> Void) -> NetworkTask? {
        if shouldFail {
            completionQueue.async {
                onResponse(.failure(NSError(domain: "Test", code: 1)))
            }
        } else {
            let json = """
            {
              "todos": [
                { "id": 1, "todo": "Task 1", "completed": false, "userId": 1 },
                { "id": 2, "todo": "Task 2", "completed": true, "userId": 1 },
                { "id": 3, "todo": "Task 3", "completed": false, "userId": 1 }
              ],
              "total": 3,
              "skip": 0,
              "limit": 3
            }
            """
            let data = Data(json.utf8)
            completionQueue.async { onResponse(.success(data)) }
        }
        return nil
    }

    func send<T>(request: NetworkRequest,
                 type: T.Type,
                 completionQueue: DispatchQueue = .main,
                 onResponse: @escaping (Result<T, Error>) -> Void) -> NetworkTask? where T: Decodable {

        return send(request: request, completionQueue: completionQueue) { result in
            switch result {
            case .success(let data):
                do {
                    let decoded = try JSONDecoder().decode(T.self, from: data)
                    onResponse(.success(decoded))
                } catch {
                    onResponse(.failure(error))
                }
            case .failure(let error):
                onResponse(.failure(error))
            }
        }
    }
}

// MARK: - Mock Presenter
private class MockPresenter: LoadingPresentable {
    var loaderShown = false
    var loaderHidden = false
    var errorShown = false

    func showLoader() { loaderShown = true }
    func hideLoader() { loaderHidden = true }
    func showError(retryAction: @escaping () -> Void) { errorShown = true }
}
