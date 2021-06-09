//
//  Screen2Container_TableViewCellNewCategory.swift
//  Skillbox_diploma_step1
//
//  Created by Roman on 21.04.2021.
//

import UIKit

protocol protocolScreen2Container_TableViewCellNewCategory{
    func textFieldNewCategoryClear()
}

class Screen2Container_TableViewCellNewCategory: UITableViewCell {
    
    
    //MARK: - объявление аутлетов
    
    @IBOutlet var textFieldNewCategory: UITextField!
    @IBOutlet var buttonAddNewCategory: UIButton!
    
    
    //MARK: - переходы
    
    @IBAction func buttonAddNewCategoryAction(_ sender: Any) {
        if textFieldNewCategory.text != "" {
            try! Persistence.shared.addCategory(name: textFieldNewCategory.text!, icon: "")
            
            delegateScreen2Container?.screen2ContainerAddNewCategory()
            
            textFieldNewCategoryClear()
            textFieldNewCategory.endEditing(true)
        }
        else{
            delegateScreen2Container?.presentAlertErrorAddNewCategory()
        }
    }
    
    
    //MARK: - делегаты и переменные
    
    var delegateScreen2Container: protocolScreen2ContainerDelegate?
    

    override func awakeFromNib() {
        super.awakeFromNib()
        
        textFieldNewCategory.layer.cornerRadius = 10
        buttonAddNewCategory.layer.cornerRadius = 10
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}


extension Screen2Container_TableViewCellNewCategory: protocolScreen2Container_TableViewCellNewCategory{
    
    func textFieldNewCategoryClear() {
        textFieldNewCategory.text = ""
    }
    
    
}
