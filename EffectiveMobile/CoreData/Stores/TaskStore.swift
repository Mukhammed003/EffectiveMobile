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
    
    func addNewTask(taskForCoreData: SingleTask) {
        let trimmedName = taskForCoreData.name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else {
            assertionFailure("Task name is empty")
            return
        }
        
        let task = TaskCoreData(context: context)
        
        task.id = taskForCoreData.id
        task.name = taskForCoreData.name
        task.descriptionText = taskForCoreData.descriptionText
        task.status = taskForCoreData.status
        task.date = taskForCoreData.date
        
        saveContext()
    }
    
    func getAllTasks() -> [SingleTask] {
        guard let objects = fetchedResultController?.fetchedObjects else { return [] }
        return objects.compactMap { try? self.task(taskCoreData: $0) }
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
    
    func getTheGreatestTaskId() -> Int16 {
        let request: NSFetchRequest<TaskCoreData> = TaskCoreData.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "id", ascending: false)]
        request.fetchLimit = 1
        
        let result = try? context.fetch(request)
        return (result?.first?.id ?? 0) + 1
    }
    
    func isExistsSuchTrackerInCategory(withName: String) -> Bool {
        guard let tasks = fetchedResultController?.fetchedObjects else { return false }

        return tasks.contains { $0.name == withName }
    }
    
    func updateTaskData(task: SingleTask) {
        let request: NSFetchRequest<TaskCoreData> = TaskCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "id == %d", task.id)
        request.fetchLimit = 1
        
        do {
            if let existingTask = try context.fetch(request).first {
                existingTask.name = task.name
                existingTask.descriptionText = task.descriptionText
                existingTask.status = task.status
                existingTask.date = task.date
                
                saveContext()
            } else {
                assertionFailure("Task with id \(task.id) not found")
            }
        } catch {
            print("Failed to fetch task for update:", error)
        }
    }
    
    func deleteTask(taskId: Int16) {
        let request: NSFetchRequest<TaskCoreData> = TaskCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "id == %d", taskId)
        request.fetchLimit = 1
        
        do {
            if let existingTask = try context.fetch(request).first {
                context.delete(existingTask)
                
                saveContext()
            } else {
                assertionFailure("Task with id \(taskId) not found")
            }
        } catch {
            print("Failed to fetch task for delete:", error)
        }
    }
    
    private func task(taskCoreData: TaskCoreData) throws -> SingleTask {
        guard let name = taskCoreData.name else {
            throw TaskStoreError.decodingErrorInvalidName
        }
        
        guard let descriptionText = taskCoreData.descriptionText else {
            throw TaskStoreError.decodingErrorInvalidDescriptionText
        }
        
        guard let date = taskCoreData.date else {
            throw TaskStoreError.decodingErrorInvalidDate
        }
        
        return SingleTask(
            id: taskCoreData.id,
            name: name,
            descriptionText: descriptionText,
            status: taskCoreData.status,
            date: date)
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
