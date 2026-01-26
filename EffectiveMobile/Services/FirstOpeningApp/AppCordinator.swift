import UIKit
final class AppCoordinator {

    private let window: UIWindow
    private let servicesAssembly: ServicesAssembly
    private let firstLaunchService: FirstLaunchService

    init(window: UIWindow, servicesAssembly: ServicesAssembly) {
        self.window = window
        self.servicesAssembly = servicesAssembly
        self.firstLaunchService = FirstLaunchService(
            servicesAssembly: servicesAssembly
        )
    }

    func start() {
        let rootVc = ViewController()
        window.rootViewController = rootVc
        window.makeKeyAndVisible()
        
        firstLaunchService.presenter = rootVc
        firstLaunchService.checkFirstLaunch()
    }
}
