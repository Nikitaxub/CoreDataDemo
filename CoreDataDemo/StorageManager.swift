//
//  StorageManager.swift
//  CoreDataDemo
//
//  Created by xubuntus on 07.12.2021.
//

import CoreData

class StorageManager {
    static let shared = StorageManager()
    
    private init() {}
    
    // MARK: - Core Data stack
    var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "CoreDataDemo")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support
    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func fetchTaskList() -> [Task] {
        let fetchRequest = Task.fetchRequest()
        var taskList: [Task] = []
        
        do {
            taskList = try persistentContainer.viewContext.fetch(fetchRequest)
        } catch {
            print(error.localizedDescription)
        }
        
        return taskList
    }
    
    func saveTask(withName: String) -> Task {
        let task = Task(context: persistentContainer.viewContext)
        task.title = withName
        
        if persistentContainer.viewContext.hasChanges {
            do {
                try persistentContainer.viewContext.save()
            } catch {
                print(error.localizedDescription)
            }
        }
        
        return task
    }
    
    func deleteTask(_ task: Task) -> Void {
        persistentContainer.viewContext.delete(task)
        
        do {
            try persistentContainer.viewContext.save()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func updateTask(_ task: Task, with name: String) -> Task {
        task.setValue(name, forKey: "title")
        
        do {
            try persistentContainer.viewContext.save()
        } catch {
            print(error.localizedDescription)
        }
        
        return task
    }
}
