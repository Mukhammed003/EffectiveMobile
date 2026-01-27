import UIKit
final class AppCoordinator {

    private let window: UIWindow
    private let servicesAssembly: ServicesAssembly
    private let firstLaunchService: FirstLaunchService
    private let taskStore: TaskStore

    init(window: UIWindow, servicesAssembly: ServicesAssembly, taskStore: TaskStore) {
        self.window = window
        self.servicesAssembly = servicesAssembly
        self.taskStore = taskStore
        self.firstLaunchService = FirstLaunchService(
            servicesAssembly: servicesAssembly,
            taskStore: taskStore
        )
    }

    func start() {
        let taskListViewModel = TaskListViewModel(taskStore: taskStore)
        
        let rootVc = TasksListViewController(viewModel: taskListViewModel)
        window.rootViewController = rootVc
        window.makeKeyAndVisible()
        
        firstLaunchService.presenter = rootVc
        
        firstLaunchService.checkFirstLaunch()
    }
}
