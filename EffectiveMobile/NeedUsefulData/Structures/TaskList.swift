// MARK: - Structure for decoding tasks requests

struct TasksList: Codable {
    let todos: [Task]
    let total: Int
    let skip: Int
    let limit: Int
}
