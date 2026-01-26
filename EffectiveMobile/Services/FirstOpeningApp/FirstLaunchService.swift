import Foundation
import UIKit

final class FirstLaunchService {
    
    private static let key = "hasLaunchedBefore"
    private var servicesAssembly: ServicesAssembly?
    private var currentTask: NetworkTask?
    
    weak var presenter: UIViewController?
    
    init(servicesAssembly: ServicesAssembly?) {
        self.servicesAssembly = servicesAssembly
    }
    
    func checkFirstLaunch() {
        let defaults = UserDefaults.standard

        if !defaults.bool(forKey: FirstLaunchService.key) {
            defaults.set(true, forKey: FirstLaunchService.key)

            print("Первый запуск приложения")
            
            fetchProfileInfo()
        }
    }
    
    private func fetchProfileInfo() {
        print("Дошло")
        
        currentTask = servicesAssembly?.tasksService.getUsers { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }
                
                switch result {
                case .success(let tasks):
                    let listOfTasks = TasksListViewData(tasksList: tasks)
                    print("Данные для списка задач загружены: \(listOfTasks.todos.count)")
                case .failure (_):
                    print("Ошибка во время загрузки данных для списка задач")
                    self.showErrorAlert()
                }
            }
        }
    }
    
    private func showErrorAlert() {
        let repeatAction = UIAlertAction(title: "Повторить", style: .default) { [weak self] _ in
            self?.fetchProfileInfo()
        }
        let cancelAction = UIAlertAction(title: "Отменить", style: .cancel)
        
        
        let alert = UIAlertController(
            title: "Ошибка во время загрузки данных",
            message: nil,
            preferredStyle: .alert
        )
        
        alert.addAction(repeatAction)
        alert.addAction(cancelAction)
        
        presenter?.present(alert, animated: true)
    }
}

