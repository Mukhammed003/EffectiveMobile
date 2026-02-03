import XCTest
import CoreData
@testable import EffectiveMobile

final class TaskStoreTests: XCTestCase {
    
    var persistentContainer: NSPersistentContainer!
    var taskStore: TaskStore!
    
    override func setUp() {
        super.setUp()
        
        persistentContainer = NSPersistentContainer(name: "EffectiveMobile")
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        persistentContainer.persistentStoreDescriptions = [description]
        
        let expectation = self.expectation(description: "Load persistent stores")
        persistentContainer.loadPersistentStores { _, error in
            XCTAssertNil(error)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
        
        taskStore = TaskStore(persistentContainer: persistentContainer)
    }
    
    override func tearDown() {
        taskStore = nil
        persistentContainer = nil
        super.tearDown()
    }
    
    func test_add_and_get_task() throws {
        let task = SingleTask(
            id: 1,
            name: "Test Task",
            descriptionText: "Test description",
            status: false,
            date: Date()
        )
        
        let expectation = self.expectation(description: "Task saved")
        
        persistentContainer.performBackgroundTask { context in
            let coreTask = TaskCoreData(context: context)
            coreTask.id = task.id
            coreTask.name = task.name
            coreTask.descriptionText = task.descriptionText
            coreTask.status = task.status
            coreTask.date = task.date
            
            do {
                try context.save()
                expectation.fulfill()
            } catch {
                XCTFail("Failed to save task: \(error)")
            }
        }
        
        wait(for: [expectation], timeout: 1)
        
        let tasks = taskStore.getAllTasks()
        XCTAssertEqual(tasks.count, 1)
        XCTAssertEqual(tasks.first?.name, "Test Task")
    }

    
    func test_update_task() throws {
        let task = SingleTask(
            id: 1,
            name: "Task 1",
            descriptionText: "Desc 1",
            status: false,
            date: Date()
        )
        
        let addExpectation = expectation(description: "Add task")
        taskStore.addNewTask(taskForCoreData: task)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { addExpectation.fulfill() }
        wait(for: [addExpectation], timeout: 1)
        
        let updatedTask = SingleTask(
            id: 1,
            name: "Updated Task",
            descriptionText: "Updated Desc",
            status: true,
            date: Date()
        )
        
        let updateExpectation = expectation(description: "Update task")
        taskStore.updateTaskData(task: updatedTask)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { updateExpectation.fulfill() }
        wait(for: [updateExpectation], timeout: 1)
        
        let tasks = taskStore.getAllTasks()
        XCTAssertEqual(tasks.count, 1)
        XCTAssertEqual(tasks.first?.name, "Updated Task")
        XCTAssertEqual(tasks.first?.status, true)
    }

    func test_delete_task() throws {
        let task = SingleTask(
            id: 1,
            name: "Task to Delete",
            descriptionText: "Desc",
            status: false,
            date: Date()
        )
        
        let addExpectation = expectation(description: "Add task")
        taskStore.addNewTask(taskForCoreData: task)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { addExpectation.fulfill() }
        wait(for: [addExpectation], timeout: 1)
        
        XCTAssertEqual(taskStore.getAllTasks().count, 1)
        
        let deleteExpectation = expectation(description: "Delete task")
        taskStore.deleteTask(taskId: 1)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { deleteExpectation.fulfill() }
        wait(for: [deleteExpectation], timeout: 1)
        
        XCTAssertEqual(taskStore.getAllTasks().count, 0)
    }

    func test_change_status() throws {
        let task = SingleTask(
            id: 1,
            name: "Task Status",
            descriptionText: "Desc",
            status: false,
            date: Date()
        )
        
        let addExpectation = expectation(description: "Add task")
        taskStore.addNewTask(taskForCoreData: task)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { addExpectation.fulfill() }
        wait(for: [addExpectation], timeout: 1)
        
        let changeExpectation1 = expectation(description: "Change status 1")
        taskStore.changeStatusOfTask(taskId: 1)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { changeExpectation1.fulfill() }
        wait(for: [changeExpectation1], timeout: 1)
        XCTAssertEqual(taskStore.getAllTasks().first?.status, true)
        
        let changeExpectation2 = expectation(description: "Change status 2")
        taskStore.changeStatusOfTask(taskId: 1)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { changeExpectation2.fulfill() }
        wait(for: [changeExpectation2], timeout: 1)
        XCTAssertEqual(taskStore.getAllTasks().first?.status, false)
    }

    func test_isExistsSuchTrackerInCategory() throws {
        let task = SingleTask(
            id: 1,
            name: "My Task",
            descriptionText: "Desc",
            status: false,
            date: Date()
        )
        
        let addExpectation = expectation(description: "Add task")
        taskStore.addNewTask(taskForCoreData: task)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { addExpectation.fulfill() }
        wait(for: [addExpectation], timeout: 1)
        
        XCTAssertTrue(taskStore.isExistsSuchTrackerInCategory(withName: "My Task"))
        XCTAssertFalse(taskStore.isExistsSuchTrackerInCategory(withName: "Other Task"))
    }

    func test_getTheGreatestTaskId() throws {
        let task1 = SingleTask(id: 1, name: "Task1", descriptionText: "Desc", status: false, date: Date())
        let task2 = SingleTask(id: 2, name: "Task2", descriptionText: "Desc", status: false, date: Date())
        
        let addExpectation = expectation(description: "Add tasks")
        
        taskStore.addNewTask(taskForCoreData: task1)
        taskStore.addNewTask(taskForCoreData: task2)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { addExpectation.fulfill() }
        wait(for: [addExpectation], timeout: 1)
        
        let nextId = taskStore.getTheGreatestTaskId()
        XCTAssertEqual(nextId, 3)
    }

}
