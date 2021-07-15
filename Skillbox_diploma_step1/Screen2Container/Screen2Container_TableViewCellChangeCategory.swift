//
//  TableViewCellChangeCategoryScreen2Container.swift
//  Skillbox_diploma_step1
//
//  Created by Roman on 23.01.2021.
//

import UIKit
import SimpleCheckbox

protocol protocolScreen2Container_TableViewCellChangeCategory{
    func returnCategryIdOfCell() -> Int
    func closeEditing()
    func setPermitionToSetCategory(status: Bool)
}

class Screen2Container_TableViewCellChangeCategory: UITableViewCell, UITextFieldDelegate {
    
    //MARK: - объявление аутлетов
    @IBOutlet var textFieldNameCategory: UITextField!
    @IBOutlet var buttonDeleteCategory: UIButton!
    @IBOutlet var buttonEditNameCategory: UIButton!
    @IBOutlet var buttonConfirmNewName: UIButton!
    @IBOutlet var checkBoxObject: Checkbox!
    @IBOutlet var constaraintCellChangeCategoryHeight: NSLayoutConstraint!
    
    
    //MARK: - делегаты и переменные
    
    var delegateScreen2Container: protocolScreen2ContainerDelegate?
    var specCellTag: Int = 0
    var gestureCell: UIGestureRecognizer?
    var gestureCheckBox: UIGestureRecognizer?
    var editStatus: Bool = false
    var permitionToSetCategory: Bool = true
    
    
    //MARK: - переходы
    
    @IBAction func buttonDeleteCategoryAction(_ sender: Any) {
        print("buttonDeleteCategoryAction, specCellTag= \(specCellTag)")
        delegateScreen2Container?.returnDelegateScreen2().returnDelegateScreen1().deleteCategoryInUserDefaults(id: specCellTag)
        delegateScreen2Container?.screen2ContainerDeleteCategory(index: specCellTag)
    }
    
    
    @IBAction func buttonsEditNameCategoryAction(_ sender: Any) {
        if editStatus == false{
            editStatus = true
            textFieldNameCategory.backgroundColor = UIColor.white
            textFieldNameCategory.textColor = UIColor.systemGray
            textFieldNameCategory.isEnabled = true
            textFieldNameCategory.becomeFirstResponder()
//            removeGestureRecognizer(gestureCell!) // не работает
//            removeGestureRecognizer(gestureCheckBox!) // не работает
            checkBoxObject.isUserInteractionEnabled = false
            print("buttonEditNameCategoryAction1")
            buttonEditNameCategory.tintColor = UIColor.red
            buttonEditNameCategory.isHidden = true
            buttonConfirmNewName.isHidden = false
            delegateScreen2Container?.setCurrentActiveEditingCell(CategoryID: (delegateScreen2Container?.returnDelegateScreen2().returnDataArrayOfCategory()[specCellTag].id)!)
        }
        else{
            closeEditing()
        }
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        buttonsEditNameCategoryAction(buttonConfirmNewName)
        return true
    }
    
    
    @objc func closeWindows() {
        if permitionToSetCategory == false { return }
        
        delegateScreen2Container?.returnDelegateScreen2().setCategoryInNewOperation(category: textFieldNameCategory.text!) //запись выбранной категории во временную переменную
        delegateScreen2Container?.closeWindows(specCellTag) //закрытие PopUp-окна
        delegateScreen2Container?.setCurrentActiveEditingCell(CategoryID: 100)
        print("ClosePopup from ContainerCell")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        

        // Configure the view for the selected state
    }
    
    
    func startCell() {
        textFieldNameCategory.text = delegateScreen2Container?.returnDelegateScreen2().returnDataArrayOfCategory()[specCellTag].name
        gestureCell = UITapGestureRecognizer(target: self, action: #selector(closeWindows))
        gestureCheckBox = UITapGestureRecognizer(target: self, action: #selector(closeWindows))
        isUserInteractionEnabled = true
        addGestureRecognizer(gestureCell!)
        checkBoxObject.addGestureRecognizer(gestureCheckBox!)
        checkBoxObject.tag = specCellTag
        checkBoxObject.checkmarkStyle = .tick
        checkBoxObject.borderLineWidth = 0
        checkBoxObject.borderStyle = .circle
        checkBoxObject.checkmarkSize = 1
        checkBoxObject.checkmarkColor = .white
        
        textFieldNameCategory.layer.cornerRadius = 10
        
        if delegateScreen2Container?.returnDelegateScreen2().returnNewOperation().category ==  delegateScreen2Container?.returnDelegateScreen2().returnDataArrayOfCategory()[specCellTag].name {
            checkBoxObject.isChecked = true
        }
        else{
            checkBoxObject.isChecked = false
        }
        
        if delegateScreen2Container?.returnScreen2StatusEditContainer() == true {
            buttonDeleteCategory.isHidden = false
            buttonEditNameCategory.isHidden = false
        }
        else{
            buttonDeleteCategory.isHidden = true
            buttonEditNameCategory.isHidden = true
        }
        
        textFieldNameCategory.returnKeyType = .done
        textFieldNameCategory.delegate = self
        
    }
    
    
    func setTag(tag: Int) {
        specCellTag = tag
        print("specCellTag ChangeCategory= \(specCellTag)")
    }
    
}


extension Screen2Container_TableViewCellChangeCategory: protocolScreen2Container_TableViewCellChangeCategory{
    
    func setPermitionToSetCategory(status: Bool) {
        permitionToSetCategory = status
    }
    
    func returnCategryIdOfCell() -> Int{
        return (delegateScreen2Container?.returnDelegateScreen2().returnDataArrayOfCategory()[specCellTag].id)!
    }
    
    
    func closeEditing(){
        editStatus = false
        textFieldNameCategory.backgroundColor = UIColor.clear
        textFieldNameCategory.textColor = UIColor.white
        textFieldNameCategory.isEnabled = false
        textFieldNameCategory.resignFirstResponder()
//        addGestureRecognizer(gestureCell!)
//        addGestureRecognizer(gestureCheckBox!)
        checkBoxObject.isUserInteractionEnabled = true
        print("buttonEditNameCategoryAction2")
        buttonEditNameCategory.tintColor = UIColor.systemBlue
        buttonEditNameCategory.isHidden = false
        buttonConfirmNewName.isHidden = true
        
        delegateScreen2Container?.returnDelegateScreen2().returnDelegateScreen1().editCategoryInUserDefaults(newName: textFieldNameCategory.text!, newIcon: "", id: specCellTag)
        delegateScreen2Container?.setCurrentActiveEditingCell(CategoryID: 0)
        delegateScreen2Container?.returnDelegateScreen2().screen2CateforyDataReceive()
    }

}
