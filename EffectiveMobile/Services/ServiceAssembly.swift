// MARK: - Services Assembly

final class ServicesAssembly {

    private let networkClient: NetworkClient

    // MARK: - Init
    init(
        networkClient: NetworkClient
    ) {
        self.networkClient = networkClient
    }

    // MARK: - Services
    var tasksService: TasksService {
        TaskServiceImpl(
            networkClient: networkClient
        )
    }
}
