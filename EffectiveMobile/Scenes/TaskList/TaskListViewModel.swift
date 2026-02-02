final class TaskListViewModel {
    
    var listOfTasks: [SingleTask] {
        taskStore.getAllTasks()
    }
    let taskStore: TaskStore
    
    init(taskStore: TaskStore) {
        self.taskStore = taskStore
    }
    
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
}
