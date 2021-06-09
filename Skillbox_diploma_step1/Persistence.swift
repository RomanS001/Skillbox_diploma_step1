//
//  Persistence.swift
//  Skillbox_diploma_step1
//
//  Created by Roman on 26.01.2021.
//

import Foundation
import RealmSwift
import CoreData


//class Person: Object{
//    @objc dynamic var name: String = ""
//    @objc dynamic var surname: String = ""
//    @objc dynamic var daysForSorting: Int = 0
//    @objc dynamic var lastIdOfOperations: Int = -1
//    @objc dynamic var lastIdOfCategories: Int = -1
//    var listOfCategory = List<Category>()
//}
//
//
//class ListOfOperations: Object{
//    @objc dynamic var amount: Double = 0
//    @objc dynamic var category: String = ""
//    @objc dynamic var note: String = ""
//    @objc dynamic var date: Date = Date.init(timeIntervalSince1970: TimeInterval(0))
//    @objc dynamic var id: Int = 0
//}
//
//
//class Category: Object{
//    @objc dynamic var name: String = ""
//    @objc dynamic var icon: String = ""
//    @objc dynamic var id: Int = 0
//}

class Persistence{

    
    static let shared = Persistence()
    private let realm = try! Realm()
    
    enum PersistenceErrors: Error{
        case appDelegateLevel
        case returnRealmDataCategoriesLevel
        case updateLastIdOfCategory
        case addCategoryLevel
        case addCategoryLevel2
        case updateLastIdOfOperations
        case addOperationLevel
        case addOperationLevel2
        case updateDaysForSortingLevel
    }
    
    
    //MARK: - категории
    
    func returnCoreDataCategories() throws -> [NSManagedObject] {
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            throw PersistenceErrors.appDelegateLevel
        }
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSManagedObject>(entityName: "Category")
        let returnEntity = try context.fetch(request)
        return returnEntity
        
    }
    
    
    func addCategory(name: String, icon: String) throws {
        
        let lastIdOfCategory: Int?
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            throw PersistenceErrors.appDelegateLevel
        }
        let context = appDelegate.persistentContainer.viewContext
        
        //Update lastIdOfCategory
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Person")
        request.returnsObjectsAsFaults = false
        do{
            let allDataLastIdOfCategory = try context.fetch(request) as! [NSManagedObject]
            lastIdOfCategory = allDataLastIdOfCategory.first?.value(forKey: "lastIdOfCategory") as! Int + 1
        } catch {
            print("Error in lastIdOfCategory")
            throw PersistenceErrors.updateLastIdOfCategory
        }
        
        //Add Category
        guard let categoryEntitySample = NSEntityDescription.entity(forEntityName: "Category", in: context) else {
            throw PersistenceErrors.addCategoryLevel
        }
        let newEntityCategory = NSManagedObject(entity: categoryEntitySample, insertInto: context)
        newEntityCategory.setValue(icon, forKey: "icon")
        newEntityCategory.setValue(lastIdOfCategory, forKey: "id")
        newEntityCategory.setValue(name, forKey: "name")
        do {
            try context.save()
        } catch {
            print("addCategory failed")
            throw PersistenceErrors.addCategoryLevel2
        }
        
    }
    
    
    func deleteCategory(idOfObject: Int) throws {
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            throw PersistenceErrors.appDelegateLevel
        }
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSManagedObject>(entityName: "Category")
        request.returnsObjectsAsFaults = false
        do{
            let allDataCategory = try context.fetch(request)
            for data in allDataCategory{
                if data.value(forKey: "id") as! Int == idOfObject{
                    context.delete(data)
                    return
                }
            }
        }
        
    }
    
    
    func updateCategory(name: String, icon: String, idOfObject: Int) throws{
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            throw PersistenceErrors.appDelegateLevel
        }
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSManagedObject>(entityName: "Category")
        request.returnsObjectsAsFaults = false
        do{
            let allDataCategory = try context.fetch(request)
            for data in allDataCategory{
                if data.value(forKey: "id") as! Int == idOfObject{
                    data.setValue(icon, forKey: "icon")
                    data.setValue(name, forKey: "name")
                    try context.save()
                }
            }
        }
        
    }

    
    
    //MARK: - операции

    
    func addOperations(amount: Double, category: String, note: String, date: Date) throws {
        
        
        let lastIdOfOperations: Int?
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            throw PersistenceErrors.appDelegateLevel
        }
        let context = appDelegate.persistentContainer.viewContext
        
        //Update lastIdOfCategory
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Person")
        request.returnsObjectsAsFaults = false
        do{
            let allDataPerson = try context.fetch(request) as! [NSManagedObject]
            lastIdOfOperations = allDataPerson.first?.value(forKey: "lastIdOfOperations") as! Int + 1
        } catch {
            print("Error in lastIdOfOperations")
            throw PersistenceErrors.updateLastIdOfOperations
        }
        
        //Add Operation
        guard let operationEntitySample = NSEntityDescription.entity(forEntityName: "ListOfOperation", in: context) else {
            throw PersistenceErrors.addOperationLevel
        }
        let newEntityOperation = NSManagedObject(entity: operationEntitySample, insertInto: context)
        newEntityOperation.setValue(amount, forKey: "amount")
        newEntityOperation.setValue(category, forKey: "category")
        newEntityOperation.setValue(note, forKey: "note")
        newEntityOperation.setValue(date, forKey: "date")
        newEntityOperation.setValue(lastIdOfOperations, forKey: "id")
        do {
            try context.save()
        } catch {
            print("addCategory failed")
            throw PersistenceErrors.addOperationLevel2
        }

    }
    
    
    func updateOperations(amount: Double, category: String, note: String, date: Date, idOfObject: Int) throws {
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            throw PersistenceErrors.appDelegateLevel
        }
        let context = appDelegate.persistentContainer.viewContext
        
        //Update lastIdOfCategory
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "ListOfOperations")
        request.returnsObjectsAsFaults = false
        do{
            let allDataListOfOperations = try context.fetch(request) as! [NSManagedObject]
            
            for data in allDataListOfOperations{
                if data.value(forKey: "id") as! Int == idOfObject{
                    data.setValue(amount, forKey: "amount")
                    data.setValue(category, forKey: "category")
                    data.setValue(note, forKey: "note")
                    data.setValue(date, forKey: "date")
                    try context.save()
                }
            }
        } catch {
            print("addCategory failed")
            throw PersistenceErrors.addOperationLevel2
        }
        
    }
    
        
    func getCoreDataOperations() throws -> [NSManagedObject] {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            throw PersistenceErrors.appDelegateLevel
        }
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "ListOfOperations")
        request.returnsObjectsAsFaults = false
        let allDataListOfOperations = try context.fetch(request) as! [NSManagedObject]
        return allDataListOfOperations
    }
    

    func deleteOperation(idOfObject: Int) throws {
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            throw PersistenceErrors.appDelegateLevel
        }
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSManagedObject>(entityName: "ListOfOperations")
        request.returnsObjectsAsFaults = false
        do{
            let allDataOperations = try context.fetch(request)
            for data in allDataOperations{
                if data.value(forKey: "id") as! Int == idOfObject{
                    context.delete(data)
                    return
                }
            }
        }
        
    }
    
    
    //MARK: - личные данные
    
    func updateDaysForSorting(daysForSorting: Int) throws {
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            throw PersistenceErrors.appDelegateLevel
        }
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Person")
        request.returnsObjectsAsFaults = false
        do{
            let allDataPerson = try context.fetch(request) as! [NSManagedObject]
            allDataPerson.first?.setValue(daysForSorting, forKey: "daysForSorting")
            try context.save()
        } catch {
            print("updateDaysForSorting failed")
            throw PersistenceErrors.updateDaysForSortingLevel
        }
        
    }
    
        
    func returnDaysForSorting() throws -> Int{
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            throw PersistenceErrors.appDelegateLevel
        }
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Person")
        request.returnsObjectsAsFaults = false
        let allDataPerson = try context.fetch(request) as! [NSManagedObject]
        return allDataPerson.first?.value(forKey: "daysForSorting") as! Int
    }
    
}
