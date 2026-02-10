// MARK: - Structure for decoding tasks requests

struct TasksListForResponse: Decodable {
    let todos: [TaskForResponse]
    let total: Int
    let skip: Int
    let limit: Int
}
