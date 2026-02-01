
enum TaskMode {
    case add
    case edit(task: SingleTask)
}

final class TaskViewModel {
    
    var isTitleFieldFilled = false
    var isDescriptionFieldFilled = false
    var newTaskId: Int16 = 0
    let taskMode: TaskMode
    
    init(taskMode: TaskMode ) {
        self.taskMode = taskMode
    }
}
