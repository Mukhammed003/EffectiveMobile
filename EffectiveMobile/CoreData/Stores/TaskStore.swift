import UIKit
import CoreData

enum TaskStoreError: Error {
    case decodingErrorInvalidId
    case decodingErrorInvalidName
    case decodingErrorInvalidDescriptionText
    case decodingErrorInvalidDate
    case decodingErrorInvalidStatus
}

protocol TaskStoreDelegate: AnyObject {
    func store(
        _ store: TaskStore,
        didUpdate: StoreUpdate
    )
}

final class TaskStore: NSObject {
    private let context: NSManagedObjectContext
    private var fetchedResultController: NSFetchedResultsController<TaskCoreData>?
    
    weak var delegate: TaskStoreDelegate?
    private var frcDelegate: BaseFetchedResultsControllerDelegate<StoreUpdate>?
    
    convenience override init() {
        let context: NSManagedObjectContext
        
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            context = appDelegate.persistentContainer.viewContext
        } else {
            context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
            print("⚠️ Не удалось получить AppDelegate. Используется fallback context (TaskStore)") }
        self.init(context: context)
    }
    
    init(context: NSManagedObjectContext) {
        self.context = context
        super.init()
        
        let fetchRequest = TaskCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \TaskCoreData.id, ascending: true)]
        let controller = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        
        let delegate = BaseFetchedResultsControllerDelegate<StoreUpdate>(
            ownerName: "TaskStore"
        ) { [weak self] update in
            guard let self else { return }
            self.delegate?.store(self, didUpdate: update)
        }
        
        controller.delegate = delegate
        frcDelegate = delegate
        fetchedResultController = controller
        
        do {
            try controller.performFetch()
        }
        catch {
            print("⚠️ TaskStore: performFetch failed: \(error)")
        }
    }
    
    func addNewTask(taskForCoreData: TaskForCoreData) {
        let task = TaskCoreData(context: context)
        
        task.id = taskForCoreData.id
        task.name = taskForCoreData.name
        task.descriptionText = taskForCoreData.descriptionText
        task.status = taskForCoreData.status
        task.date = taskForCoreData.date
    }
    
    func debugPrintAllTasks() {
        let request: NSFetchRequest<TaskCoreData> = TaskCoreData.fetchRequest()
        
        do {
            let tasks =  try context.fetch(request)
            print("=== Все записи в TaskCoreData ===")
            tasks.forEach { task in
                print("Id: \(task.id), name: \(String(describing: task.name))")
            }
        } catch {
            print("Не удалось выполнить запрос по выкачке всех задач: \(error)")
        }
    }
    
    private func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                context.rollback()
            }
        }
    }
}
