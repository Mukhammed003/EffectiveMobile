import Foundation
import UIKit

final class FirstLaunchService {
    
    weak var presenter: LoadingPresentable?
    
    private var servicesAssembly: ServicesAssembly?
    private var taskStore: TaskStore?
    private var currentTask: NetworkTask?
    private var convertedData: [TaskForCoreData] = []
    
    init(servicesAssembly: ServicesAssembly?, taskStore: TaskStore?) {
        self.servicesAssembly = servicesAssembly
        self.taskStore = taskStore
    }
    
    func checkFirstLaunch() {
        let defaults = UserDefaults.standard

        if !defaults.bool(forKey: Constants.firstLaunchServicekey) {
            defaults.set(true, forKey: Constants.firstLaunchServicekey)

            print("Первый запуск приложения")
            
            loadData()
        }
    }
    
    private func loadData() {
        print("Дошло")
        
        presenter?.showLoader()
        
        currentTask = servicesAssembly?.tasksService.getUsers { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }
                
                switch result {
                case .success(let tasks):
                    let listOfTasks = TasksListViewData(tasksList: tasks)
                    print("Данные для списка задач загружены: \(listOfTasks.todos.count)")
                    
                    self.convertedData = self.convertToCoreDataModel(listOfTasks: listOfTasks)
                    
                    self.addFetchedDataToCoreData()
                    self.presenter?.hideLoader()
                case .failure (_):
                    print("Ошибка во время загрузки данных для списка задач")
                    self.presenter?.hideLoader()
                    self.presenter?.showError {
                        self.loadData()
                    }
                }
            }
        }
    }
    
    private func convertToCoreDataModel(listOfTasks: TasksListViewData) -> [TaskForCoreData] {
        return listOfTasks.todos.compactMap { task in
            TaskForCoreData(
                id: Int16(task.id),
                name: task.todo,
                descriptionText: "",
                status: task.completed,
                date: Date.now
            )
        }
    }
    
    private func addFetchedDataToCoreData() {
        convertedData.forEach { task in
            taskStore?.addNewTask(taskForCoreData: task)
        }
        
        taskStore?.debugPrintAllTasks()
    }
}

