// MARK: - Structure for single task 

import Foundation

struct Task: Codable {
    let id: Int
    let todo: String
    let completed: Bool
    let userId: Int
}
