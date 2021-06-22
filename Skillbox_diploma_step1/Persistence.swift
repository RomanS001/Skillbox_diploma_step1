//
//  Persistence.swift
//  Skillbox_diploma_step1
//
//  Created by Roman on 26.01.2021.
//

import Foundation


protocol ObjectSavable {
    func setObject<Object>(_ object: Object, forKey: String) throws where Object: Encodable
    func getObject<Object>(forKey: String, castTo type: Object.Type) throws -> Object where Object: Decodable
}


enum ObjectSavableError: String, LocalizedError {
    case unableToEncode = "Unable to encode object into data"
    case noValue = "No data object found for the given key"
    case unableToDecode = "Unable to decode object into given type"
    case returnRealmDataCategories
    case returnRealmDataPerson
    case addCategory
    
    var errorDescription: String? {
        rawValue
    }
}


class Person: Codable{
    var name: String = ""
    var surname: String = ""
    var daysForSorting: Int = 0
    var lastIdOfOperations: Int = -1
    var lastIdOfCategories: Int = -1
    var listOfCategory: [Category] = []
}


class ListOfOperations{
    var amount: Double = 0
    var category: String = ""
    var note: String = ""
    var date: Date = Date.init(timeIntervalSince1970: TimeInterval(0))
    var id: Int = 0
}


class Category: Codable{
    var name: String = ""
    var icon: String = ""
    var id: Int = 0
    
    init(newName: String, newIcon: String, newID: Int) {
        name = newName
        icon = newIcon
        id = newID
    }
}


class Persistence{
    
    private let kPersonKey: String = "Persistence.kPersonKey"
    private let kCategoryKey: String = "Persistence.kCategoryKey"
    
    var person: Person? //Аккаунт всегда один
    var categories: [Category]? //Категорий может быть много, поэтому массив
    
    
    //MARK: - категории
    
    func returnUserDefaultsDataCategories() -> [Category] {
        let userDefaults = UserDefaults.standard
        do {
            categories = try userDefaults.getObject(forKey: kCategoryKey, castTo: [Category].self)
            return categories!
        } catch {
            ObjectSavableError.returnRealmDataCategories
        }
    }
    
    
    func returnUserDefaultsDataPerson() -> Person {
        let userDefaults = UserDefaults.standard
        do {
            person = try userDefaults.getObject(forKey: kPersonKey, castTo: Person.self)
            return person!
        } catch {
            ObjectSavableError.returnRealmDataPerson
        }
    }

    
    func addCategory(name: String, icon: String){
        let userDefaults = UserDefaults.standard
        do {
            categories = returnUserDefaultsDataCategories()
            person = returnUserDefaultsDataPerson()
            
            categories?.append(Category(newName: name, newIcon: icon, newID: person!.lastIdOfCategories + 1))
            try userDefaults.setObject(categories, forKey: "kCategoryKey")
        } catch {
            ObjectSavableError.addCategory
        }
  
        
        
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


extension UserDefaults: ObjectSavable{
    
    func setObject<Object>(_ object: Object, forKey: String) throws where Object : Encodable {
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(object)
            set(data, forKey: forKey)
        } catch {
            throw ObjectSavableError.unableToEncode
        }
    }
    
    func getObject<Object>(forKey: String, castTo type: Object.Type) throws -> Object where Object: Decodable {
        guard let data = data(forKey: forKey) else { throw ObjectSavableError.noValue }
        let decoder = JSONDecoder()
        do {
            let object = try decoder.decode(type, from: data)
            return object
        } catch {
            throw ObjectSavableError.unableToDecode
        }
    }
    
}
