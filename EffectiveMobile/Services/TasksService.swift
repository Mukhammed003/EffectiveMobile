// MARK: - Tasks Service Protocol

protocol TasksService {
    func getUsers(completion: @escaping (Result<TasksListForResponse, Error>) -> Void) -> NetworkTask?
}

// MARK: - Tasks Service Implementation

final class TaskServiceImpl: TasksService {
    
    private let networkClient: NetworkClient

    // MARK: - Init
    init(networkClient: NetworkClient) {
        self.networkClient = networkClient
    }
    
    // MARK: - TasksService
    @discardableResult
    func getUsers(completion: @escaping (Result<TasksListForResponse, any Error>) -> Void) -> NetworkTask? {
        let request = GetTasksListRequest()
        return networkClient.send(request: request, type: TasksListForResponse.self) { result in
            completion(result)
        }
    }
}
