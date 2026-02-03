// MARK: - Imports
@testable import EffectiveMobile
import XCTest
import CoreData

// MARK: - TaskListViewModel Tests
final class TaskListViewModelTests: XCTestCase {

    // MARK: - Properties
    private var persistentContainer: NSPersistentContainer!
    private var taskStore: TaskStore!
    private var viewModel: TaskListViewModel!

    // MARK: - Setup & Teardown
    override func setUp() {
        super.setUp()

        persistentContainer = NSPersistentContainer(name: "EffectiveMobile")

        let storeDescription = NSPersistentStoreDescription()
        storeDescription.type = NSInMemoryStoreType
        persistentContainer.persistentStoreDescriptions = [storeDescription]

        let expectation = expectation(description: "Load store")

        persistentContainer.loadPersistentStores { _, error in
            XCTAssertNil(error)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1)

        taskStore = TaskStore(persistentContainer: persistentContainer)
        viewModel = TaskListViewModel(taskStore: taskStore)
    }

    override func tearDown() {
        persistentContainer = nil
        taskStore = nil
        viewModel = nil
        super.tearDown()
    }

    // MARK: - Tests

    func testAddNewTask_SavesTask() {
        // MARK: - Given
        let task = SingleTask(
            id: 1,
            name: "Test",
            descriptionText: "Desc",
            status: false,
            date: Date()
        )

        // MARK: - When
        viewModel.addNewTaskToCoreData(task: task)

        let expectation = expectation(description: "Wait for save")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1)

        // MARK: - Then
        let tasks = viewModel.listOfTasks
        XCTAssertEqual(tasks.count, 1)
        XCTAssertEqual(tasks.first?.name, "Test")
    }

    func testCalculateIdForNewTask_ReturnsIncrementedId() {
        // MARK: - When
        let id = viewModel.calculateIdForNewTask()
        
        // MARK: - Then
        XCTAssertEqual(id, 1)
    }

    func testIsExistsSuchTask_ReturnsTrue() {
        // MARK: - Given
        let task = SingleTask(
            id: 1,
            name: "Unique",
            descriptionText: "",
            status: false,
            date: Date()
        )

        viewModel.addNewTaskToCoreData(task: task)

        let expectation = expectation(description: "Wait for save")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1)

        // MARK: - Then
        XCTAssertTrue(viewModel.isExistsSuchTask(name: "Unique"))
    }
}
