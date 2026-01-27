// MARK: - Structure for decoding tasks requests

struct TasksListForResponse: Codable {
    let todos: [TaskForResponse]
    let total: Int
    let skip: Int
    let limit: Int
}
