// MARK: - Task Mode

enum TaskMode {
    case add
    case edit(task: SingleTask)
}

// MARK: - Task ViewModel

final class TaskViewModel {
    
    // MARK: - Properties
    
    var isTitleFieldFilled = false
    var isDescriptionFieldFilled = false
    var newTaskId: Int16 = 0
    let taskMode: TaskMode
    
    // MARK: - Initialization
    
    init(taskMode: TaskMode ) {
        self.taskMode = taskMode
    }
}
