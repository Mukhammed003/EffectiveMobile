import Foundation

final class FirstLaunchService {
    
    weak var presenter: LoadingPresentable?
    
    private var servicesAssembly: ServicesAssembly?
    private var taskStore: TaskStore?
    private var currentTask: NetworkTask?
    
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
        
        DispatchQueue.main.async { [weak self] in
            self?.presenter?.showLoader()
        }
        
        currentTask = servicesAssembly?.tasksService.getUsers { [weak self] result in
            guard let self else { return }
            
            switch result {
            case .success(let tasks):
                DispatchQueue.global(qos: .userInitiated).async {
                    let listOfTasks = TasksListViewData(tasksList: tasks)
                    print("Данные для списка задач загружены: \(listOfTasks.todos.count)")
                    
                    let convertedData = self.convertToCoreDataModel(listOfTasks: listOfTasks)
                    
                    DispatchQueue.main.async {
                        self.addFetchedDataToCoreData(convertedData)
                        self.presenter?.hideLoader()
                    }
                }
            case .failure (_):
                DispatchQueue.main.async {
                    print("Ошибка во время загрузки данных для списка задач")
                    self.presenter?.hideLoader()
                    self.presenter?.showError {
                        self.loadData()
                    }
                }
            }
        }
    }
    
    private func convertToCoreDataModel(listOfTasks: TasksListViewData) -> [SingleTask] {
        return listOfTasks.todos.compactMap { task in
            SingleTask(
                id: Int16(task.id),
                name: task.todo,
                descriptionText: "",
                status: task.completed,
                date: Date.now
            )
        }
    }
    
    private func addFetchedDataToCoreData(_ tasks: [SingleTask]) {
        tasks.forEach { task in
            taskStore?.addNewTask(taskForCoreData: task)
        }
        
        taskStore?.debugPrintAllTasks()
    }
}

