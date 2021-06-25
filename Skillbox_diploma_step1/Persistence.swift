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
    case deleteCategory
    case returnRealmDataListOfOperations
    case updateCategory
    case addOperations
    case updateOperations
    case deleteOperation
    case updateDaysForSorting
    case returnDaysForSorting
    
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


class UserDefaultOperation: Codable{
    var amount: Double = 0
    var category: String = ""
    var note: String = ""
    var date: Date = Date.init(timeIntervalSince1970: TimeInterval(0))
    var id: Int = 0
    
    init(newAmount: Double, newCategory: String, newNote: String, newDate: Date, newID: Int) {
        amount = newAmount
        category = newCategory
        note = newNote
        date = newDate
        id = newID
    }
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
    
    static let shared = Persistence()
    
    private let kPersonKey: String = "Persistence.kPersonKey"
    private let kListOfOperationsKey: String = "Persistence.kListOfOperationsKey"
    
    var person: Person? //Аккаунт всегда один
    var listOfOperations: [UserDefaultOperation]?
    
    
    //MARK: - категории
    
    func returnUserDefaultsDataCategories() -> [Category] {
        do {
            person = returnUserDefaultsDataPerson()
            return person!.listOfCategory
        } catch {
            ObjectSavableError.returnRealmDataCategories
        }
    }
    
    
    func returnUserDefaultsDataPerson() -> Person? {
        do {
            person = try UserDefaults.standard.getObject(forKey: kPersonKey, castTo: Person.self)
            return person!
        } catch {
            ObjectSavableError.returnRealmDataPerson
            return nil
        }
    }
    
    
    func returnUserDefaultsDataListOfOperations() -> [UserDefaultOperation]? {
        do {
            listOfOperations = try UserDefaults.standard.getObject(forKey: kListOfOperationsKey, castTo: [UserDefaultOperation].self)
            return listOfOperations!
        } catch {
            ObjectSavableError.returnRealmDataListOfOperations
            return nil
        }
    }

    
    func addCategory(name: String, icon: String) {
        do {
            person = returnUserDefaultsDataPerson()
            
            person?.listOfCategory.append(Category(newName: name, newIcon: icon, newID: person!.lastIdOfCategories + 1))
            person?.lastIdOfCategories = person!.lastIdOfCategories + 1
            try UserDefaults.standard.setObject(person, forKey: kPersonKey)
        } catch {
            ObjectSavableError.addCategory
        }
    }
    
    
    func deleteCategory(idOfObject: Int) {
        do {
            person = returnUserDefaultsDataPerson()
            for n in 0...person!.listOfCategory.count {
                if person!.listOfCategory[n].id == idOfObject {
                    person!.listOfCategory.remove(at: n)
                    return
                }
            }
            try UserDefaults.standard.setObject(person, forKey: kPersonKey)
        } catch {
            ObjectSavableError.deleteCategory
        }
    }
    
    
    func updateCategory(newName: String, newIcon: String, idOfObject: Int){
        
        do {
            person = returnUserDefaultsDataPerson()
            for n in 0...person!.listOfCategory.count {
                if person!.listOfCategory[n].id == idOfObject {
                    person!.listOfCategory[n].name = newName
                    person!.listOfCategory[n].icon = newIcon
                    try UserDefaults.standard.setObject(person, forKey: kPersonKey)
                    return
                }
            }
        } catch {
            ObjectSavableError.updateCategory
        }
    }

    
    
    //MARK: - операции

    
    func addOperations(amount: Double, category: String, note: String, date: Date){
        
        do {
            person = returnUserDefaultsDataPerson()
            listOfOperations = returnUserDefaultsDataListOfOperations()
            
            listOfOperations!.append(UserDefaultOperation(newAmount: amount, newCategory: category, newNote: note, newDate: date, newID: person!.lastIdOfOperations + 1))
            person?.lastIdOfOperations = person!.lastIdOfOperations + 1
            try UserDefaults.standard.setObject(listOfOperations, forKey: kListOfOperationsKey)
            try UserDefaults.standard.setObject(person, forKey: kPersonKey)
        } catch {
            ObjectSavableError.addOperations
        }
    }
    
    
    func updateOperations(newAmount: Double, newCategory: String, newNote: String, newDate: Date, idOfObject: Int){
        
        do {
            listOfOperations = returnUserDefaultsDataListOfOperations()
            for n in 0...listOfOperations!.count {
                if listOfOperations![n].id == idOfObject {
                    listOfOperations![n].amount = newAmount
                    listOfOperations![n].category = newCategory
                    listOfOperations![n].note = newNote
                    listOfOperations![n].date = newDate
                    try UserDefaults.standard.setObject(listOfOperations, forKey: kListOfOperationsKey)
                    return
                }
            }
        } catch {
            ObjectSavableError.updateOperations
        }
    }
    

    func deleteOperation(idOfObject: Int){
        
        do {
            listOfOperations = returnUserDefaultsDataListOfOperations()
            for n in 0...listOfOperations!.count {
                if listOfOperations![n].id == idOfObject {
                    listOfOperations!.remove(at: n)
                    try UserDefaults.standard.setObject(listOfOperations, forKey: kListOfOperationsKey)
                    return
                }
            }
        } catch {
            ObjectSavableError.deleteOperation
        }
        
    }
    
    
    //MARK: - личные данные
    
    func updateDaysForSorting(daysForSorting: Int){
        
        do {
            person = returnUserDefaultsDataPerson()
            person?.daysForSorting = daysForSorting
            try UserDefaults.standard.setObject(person, forKey: kPersonKey)
        } catch {
            ObjectSavableError.updateDaysForSorting
        }
        
    }
    
        
    func returnDaysForSorting() -> Int{
        do {
            person = returnUserDefaultsDataPerson()
            if person?.daysForSorting != nil {
                return person!.daysForSorting
            } else {
                person?.daysForSorting = 30
                try UserDefaults.standard.setObject(person, forKey: kPersonKey)
                return person!.daysForSorting
            }
            
        } catch {
            ObjectSavableError.returnDaysForSorting
            return 30
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
