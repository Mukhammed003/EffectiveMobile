import Foundation

// MARK: - Structure of tasks's info (Need for tasks list page)
struct TasksListViewData {
    let todos: [Task]
    let total: Int
    let skip: Int
    let limit: Int
    
    init(tasksList: TasksList) {
        self.todos = tasksList.todos
        self.total = tasksList.total
        self.skip = tasksList.skip
        self.limit = tasksList.limit
    }
}
