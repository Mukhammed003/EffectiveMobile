import XCTest
@testable import EffectiveMobile
import CoreData

final class FirstLaunchServiceTests: XCTestCase {

    private var service: FirstLaunchService!
    private var mockNetworkClient: MockNetworkClient!
    private var taskStore: TaskStore!
    private var presenter: MockPresenter!
    private var persistentContainer: NSPersistentContainer!

    override func setUp() {
        super.setUp()

        // 1️⃣ Создаём in-memory CoreData container
        persistentContainer = NSPersistentContainer(name: "EffectiveMobile") // <- имя твоей модели
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        persistentContainer.persistentStoreDescriptions = [description]
        persistentContainer.loadPersistentStores { storeDescription, error in
            XCTAssertNil(error)
        }

        // 2️⃣ Создаём TaskStore с in-memory container
        taskStore = TaskStore(persistentContainer: persistentContainer)

        // 3️⃣ Создаём мок NetworkClient
        mockNetworkClient = MockNetworkClient()
        let servicesAssembly = ServicesAssembly(networkClient: mockNetworkClient)

        // 4️⃣ Создаём мок Presenter
        presenter = MockPresenter()

        // 5️⃣ Создаём сервис
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

    func testFirstLaunch_SuccessfulLoad() {
        mockNetworkClient.shouldFail = false

        // очищаем UserDefaults, чтобы симулировать первый запуск
        UserDefaults.standard.removeObject(forKey: Constants.firstLaunchServicekey)

        let expectation = self.expectation(description: "Completion called")

        service.checkFirstLaunch()

        // Делаем паузу, чтобы async-загрузка успела выполниться
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            XCTAssertTrue(self.presenter.loaderShown)
            XCTAssertTrue(self.presenter.loaderHidden)
            XCTAssertFalse(self.presenter.errorShown)

            // Проверяем, что задачи действительно добавились в CoreData
            let tasks = self.taskStore.getAllTasks()
            XCTAssertEqual(tasks.count, 3)

            expectation.fulfill()
        }

        waitForExpectations(timeout: 2)
    }

    func testFirstLaunch_FailedLoad_ShowsError() {
        mockNetworkClient.shouldFail = true
        UserDefaults.standard.removeObject(forKey: Constants.firstLaunchServicekey)

        let expectation = self.expectation(description: "Completion called")

        service.checkFirstLaunch()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            XCTAssertTrue(self.presenter.loaderShown)
            XCTAssertTrue(self.presenter.loaderHidden)
            XCTAssertTrue(self.presenter.errorShown)

            // Данные не должны добавиться
            let tasks = self.taskStore.getAllTasks()
            XCTAssertEqual(tasks.count, 0)

            expectation.fulfill()
        }

        waitForExpectations(timeout: 2)
    }

    func testNotFirstLaunch_DoesNothing() {
        // Симулируем, что первый запуск уже был
        UserDefaults.standard.set(true, forKey: Constants.firstLaunchServicekey)

        let expectation = self.expectation(description: "Completion called")

        service.checkFirstLaunch()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            XCTAssertFalse(self.presenter.loaderShown)
            XCTAssertFalse(self.presenter.loaderHidden)
            XCTAssertFalse(self.presenter.errorShown)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1)
    }
}

// MARK: - Mocks

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
            completionQueue.async {
                onResponse(.success(data))
            }
        }
        return nil
    }

    func send<T>(request: NetworkRequest,
                 type: T.Type,
                 completionQueue: DispatchQueue = .main,
                 onResponse: @escaping (Result<T, Error>) -> Void) -> NetworkTask? where T : Decodable {

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

private class MockPresenter: LoadingPresentable {
    var loaderShown = false
    var loaderHidden = false
    var errorShown = false

    func showLoader() { loaderShown = true }
    func hideLoader() { loaderHidden = true }
    func showError(retryAction: @escaping () -> Void) { errorShown = true }
}

