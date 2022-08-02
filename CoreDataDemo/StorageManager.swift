//
//  StorageManager.swift
//  CoreDataDemo
//
//  Created by Илья Гусаров on 02.08.2022.
//

import CoreData

class StorageManager {
    static let shared = StorageManager()
      
    private init() {}
    
    var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "CoreDataDemo")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    func fetchData(completion: @escaping([Task]) -> Void) {
        let context = persistentContainer.viewContext
        let fetchRequest = Task.fetchRequest()
        fetchRequest.returnsObjectsAsFaults = false
        
        do {
            let taskList = try context.fetch(fetchRequest)
            print(taskList)
            completion(taskList)
        } catch let error {
            print(error)
        }
    }
    
    func save(with title: String) {
        let context = persistentContainer.viewContext
        guard let entityDesc = NSEntityDescription.entity(forEntityName: "Task", in: context) else { return }
        guard let task = NSManagedObject(entity: entityDesc, insertInto: context) as? Task else { return }
        task.title = title
        
        if context.hasChanges {
            do {
                try context.save()
            } catch let error {
                print(error)
            }
        }
    }

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
}
