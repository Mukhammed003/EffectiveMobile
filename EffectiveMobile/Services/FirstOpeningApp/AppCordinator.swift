import UIKit

// MARK: - App Coordinator

final class AppCoordinator {

    // MARK: - Properties

    private let window: UIWindow
    private let servicesAssembly: ServicesAssembly
    private let firstLaunchService: FirstLaunchService
    private let taskStore: TaskStore

    // MARK: - Initialization

    init(window: UIWindow, servicesAssembly: ServicesAssembly, taskStore: TaskStore) {
        self.window = window
        self.servicesAssembly = servicesAssembly
        self.taskStore = taskStore
        self.firstLaunchService = FirstLaunchService(
            servicesAssembly: servicesAssembly,
            taskStore: taskStore
        )
    }

    // MARK: - Start Coordinator

    func start() {
        let taskListViewModel = TaskListViewModel(taskStore: taskStore)
        
        let rootVc = TaskListViewController(viewModel: taskListViewModel)
        let navVc = UINavigationController(rootViewController: rootVc)
        
        window.rootViewController = navVc
        window.makeKeyAndVisible()
        
        firstLaunchService.presenter = rootVc
        
        firstLaunchService.checkFirstLaunch()
    }
}
