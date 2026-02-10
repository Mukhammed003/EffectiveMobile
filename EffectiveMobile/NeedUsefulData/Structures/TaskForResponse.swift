// MARK: - Structure for single task in response

import Foundation

struct TaskForResponse: Decodable {
    let id: Int
    let todo: String
    let completed: Bool
    let userId: Int
}
