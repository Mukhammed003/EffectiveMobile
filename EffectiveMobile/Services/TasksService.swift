import Foundation

protocol TasksService {
    func getUsers(completion: @escaping (Result<TasksList, Error>) -> Void) -> NetworkTask?
}

final class TaskServiceImpl: TasksService {
    
    private let networkClient: NetworkClient

    init(networkClient: NetworkClient) {
        self.networkClient = networkClient
    }
    
    @discardableResult
    func getUsers(completion: @escaping (Result<TasksList, any Error>) -> Void) -> NetworkTask? {
        let request = GetTasksListRequest()
        return networkClient.send(request: request, type: TasksList.self) { result in
            completion(result)
        }
    }
    
}


