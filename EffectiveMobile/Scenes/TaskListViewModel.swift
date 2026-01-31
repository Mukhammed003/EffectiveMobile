final class TaskListViewModel {
    
    private let taskStore: TaskStore
    
    var listOfTasks: [SingleTask] = []
    
    init(taskStore: TaskStore) {
        self.taskStore = taskStore
    }
    
    func loadDataFromCoreDate() {
        listOfTasks = taskStore.getAllTasks()
        print("Количество задач на фронте: \(listOfTasks.count)")
    }
    
}
