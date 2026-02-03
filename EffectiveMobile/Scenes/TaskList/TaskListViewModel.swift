// MARK: - Task List View Model

final class TaskListViewModel {
    
    // MARK: - Properties
    
    var listOfTasks: [SingleTask] {
        taskStore.getAllTasks()
    }
    
    var needTasksForSelector: [SingleTask] = []
    var isSearching = false
    let taskStore: TaskStore
    
    // MARK: - Initialization
    
    init(taskStore: TaskStore) {
        self.taskStore = taskStore
    }
    
    // MARK: - Task Operations
    
    func addNewTaskToCoreData(task: SingleTask) {
        taskStore.addNewTask(taskForCoreData: task)
    }
    
    func calculateIdForNewTask() -> Int16 {
        taskStore.getTheGreatestTaskId()
    }
    
    func isExistsSuchTask(name: String) -> Bool {
        taskStore.isExistsSuchTrackerInCategory(withName: name)
    }
    
    func updateTask(task: SingleTask) {
        taskStore.updateTaskData(task: task)
    }
    
    func deleteTask(taskId: Int16) {
        taskStore.deleteTask(taskId: taskId)
    }
    
    func changeStatusOfTask(taskId: Int16) {
        taskStore.changeStatusOfTask(taskId: taskId)
    }
}
