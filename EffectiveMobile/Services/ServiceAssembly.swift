final class ServicesAssembly {

    private let networkClient: NetworkClient

    init(
        networkClient: NetworkClient
    ) {
        self.networkClient = networkClient
    }

    var tasksService: TasksService {
        TaskServiceImpl(
            networkClient: networkClient
        )
    }
}
