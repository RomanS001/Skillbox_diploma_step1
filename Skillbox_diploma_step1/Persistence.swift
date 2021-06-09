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
    
    enum AllErrors: Error{
        case appDelegateLevel
        case returnRealmDataCategoriesLevel
        case updateLastIdOfCategory
        case addCategoryLevel
        case addCategoryLevel2
    }
    
    
    //MARK: - категории
    
    func returnCoreDataCategories() throws -> [NSManagedObject] {
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            throw AllErrors.appDelegateLevel
        }
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSManagedObject>(entityName: "Category")
        do {
            let returnEntity = try context.fetch(request)
            return returnEntity
        } catch let error as NSError {
            print("Could not fetch. Error: \(error), \(error.userInfo)")
        }
        
    }
    
    
    func addCategory(name: String, icon: String) throws {
        
        let lastIdOfCategory: Int?
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            throw AllErrors.appDelegateLevel
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
            throw AllErrors.updateLastIdOfCategory
        }
        
        //Add Category
        guard let categoryEntitySample = NSEntityDescription.entity(forEntityName: "Category", in: context) else {
            throw AllErrors.addCategoryLevel
        }
        let newEntityCategory = NSManagedObject(entity: categoryEntitySample, insertInto: context)
        newEntityCategory.setValue(icon, forKey: "icon")
        newEntityCategory.setValue(lastIdOfCategory, forKey: "id")
        newEntityCategory.setValue(name, forKey: "name")
        do {
            try context.save()
        } catch {
            throw AllErrors.addCategoryLevel2
            print("addCategory failed")
        }
        
    }
    
    
    func deleteCategory(idOfObject: Int) throws {
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            throw AllErrors.appDelegateLevel
        }
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSManagedObject>(entityName: "Category")
        request.returnsObjectsAsFaults = false
        do{
            let allDataCategory = try context.fetch(request)
            for data in allDataCategory{
                if data.value(forKey: "id") as! Int == idOfObject{
                    context.delete(data)
                }
            }
        }
        
    }
    
    
    func updateCategory(name: String, icon: String, idOfObject: Int) throws{
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            throw AllErrors.appDelegateLevel
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

    
    func addOperations(amount: Double, category: String, note: String, date: Date){
        let operation = ListOfOperations()
        operation.category = category
        operation.note = note
        operation.amount = amount
        operation.date = date
        operation.id = realm.objects(Person.self).first!.lastIdOfOperations + 1
        try! realm.write{
            realm.add(operation)
            realm.objects(Person.self).first!.lastIdOfOperations = operation.id
        }
    }
    
    
    func updateOperations(amount: Double, category: String, note: String, date: Date, idOfObject: Int){
        print("updateOperations")
        let particularOperations = realm.objects(ListOfOperations.self).filter("id == \(idOfObject)").first
        try! realm.write{
            print("particularOperations.text= \(particularOperations)")
            particularOperations?.setValue(category, forKey: "category")
            particularOperations?.setValue(note, forKey: "note")
            particularOperations?.setValue(amount, forKey: "amount")
            particularOperations?.setValue(date, forKey: "date")
        }
    }
    
        
    func getRealmDataOperations() -> Results<ListOfOperations>{
        let allOperations = realm.objects(ListOfOperations.self)
        return allOperations
    }
    

    func deleteOperation(idOfObject: Int){
        let particularOperations = realm.objects(ListOfOperations.self).filter("id == \(idOfObject)")
//        var index: Int? = allOperations.index(of: particularObject) ?? nil
        print("idOfObject for delete= \(idOfObject)")
        try! realm.write{
            realm.delete(particularOperations)
        }
    }
    
    
    //MARK: - личные данные
    
    func updateDaysForSorting(daysForSorting: Int){
        let person = realm.objects(Person.self).first
        
        try! realm.write{
            person!.daysForSorting = daysForSorting
        }
    }
    
        
    func returnDaysForSorting() -> Int{
        print("old person returned")
        let person = realm.objects(Person.self).first
        if person?.daysForSorting != nil {
            return person!.daysForSorting
        }
        else{
            print("newPerson added")
            let newPerson = Person()
            newPerson.daysForSorting = 30
            try! realm.write{
                realm.add(newPerson)
            }
            return newPerson.daysForSorting
        }
    }
    
    
}
