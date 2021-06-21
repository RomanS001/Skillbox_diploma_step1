//
//  Persistence.swift
//  Skillbox_diploma_step1
//
//  Created by Roman on 26.01.2021.
//

import Foundation
//import RealmSwift


class Person{
    var name: String = ""
    var surname: String = ""
    var daysForSorting: Int = 0
    var lastIdOfOperations: Int = -1
    var lastIdOfCategories: Int = -1
    var listOfCategory = [Category]()
}


class ListOfOperations{
    var amount: Double = 0
    var category: String = ""
    var note: String = ""
    var date: Date = Date.init(timeIntervalSince1970: TimeInterval(0))
    var id: Int = 0
}


class Category{
    var name: String = ""
    var icon: String = ""
    var id: Int = 0
}


class Persistence{
    
    
    static let shared = Persistence()
    private let kPersonKey = "Persistence.kPersonKey"
    private let kLististOfOperationKey = "Persistence.kLististOfOperationKey"
    
    var mainPerson: Person?{
        set { UserDefaults.standard.set(newValue, forKey: kPersonKey) }
        get { return UserDefaults.standard. string(forKey: kLististOfOperationKey)}
    }
    var mainLististOfOperation: [ListOfOperations]?
    
    
    //MARK: - категории
    
    func returnRealmDataCategories() -> Results<Category>{
        let allCategories = realm.objects(Category.self)
        return allCategories
    }
    
    func addCategory(name: String, icon: String){
        let category = Category()
        category.name = name
        category.icon = icon
        category.id = realm.objects(Person.self).first!.lastIdOfCategories + 1
        try! realm.write{
            realm.add(category)
            realm.objects(Person.self).first!.lastIdOfCategories = category.id
        }
    }
    
    
    func deleteCategory(idOfObject: Int){
        let particularCategory = realm.objects(Category.self).filter("id == \(idOfObject)")
//        var index: Int? = allOperations.index(of: particularObject) ?? nil
        print("idOfObject for deleteCategory= \(idOfObject)")
        try! realm.write{
            realm.delete(particularCategory)
        }
    }
    
    
    func updateCategory(name: String, icon: String, idOfObject: Int){
        print("updateCategoy")
        let particularCategory = realm.objects(Category.self).filter("id == \(idOfObject)")
        try! realm.write{
            print("particularOperations.text= \(particularCategory)")
            particularCategory.setValue(name, forKey: "name")
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
