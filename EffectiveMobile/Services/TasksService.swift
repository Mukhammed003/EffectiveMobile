import Foundation

protocol TasksService {
    
}

final class TaskServiceImpl: TasksService {
    
    private let networkClient: NetworkClient

    init(networkClient: NetworkClient) {
        self.networkClient = networkClient
    }
    
}


