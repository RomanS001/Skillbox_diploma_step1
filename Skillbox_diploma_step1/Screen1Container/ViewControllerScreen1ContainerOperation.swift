//
//  ViewControllerScreen1Container.swift
//  Skillbox_diploma_step1
//
//  Created by Roman on 17.04.2021.
//

import UIKit

protocol protocolScreen1ContainerOperation{
    func startCell(tag: Int)
}

class ViewControllerScreen1ContainerOperation: UIViewController{
    
    
    //MARK: - аутлеты
    
    @IBOutlet var labelCategory: UILabel!
    @IBOutlet var labelDate: UILabel!
    @IBOutlet var labelAmount: UILabel!
    @IBOutlet var currencyStatus: UILabel!
    @IBOutlet var textViewNotes: UITextView!
    @IBOutlet var viewRightParth: UIView!
    @IBOutlet var buttonToEditOperation: UIButton!
    @IBOutlet var buttonToDeleteOperation: UIButton!
    @IBOutlet var viewLogoCategory: UIView!
    
    
    //MARK: - делегаты и переменные
    
    var delegateScreen1: protocolScreen1Delegate?
    
    var newTableDataArray: [DataOfOperations] = []
    var specCellTag: Int = 0
    var specVar: Int = 0

    
    //MARK: - переходы
    
    
    @IBAction func buttonActionToEditOperation(_ sender: Any) {
        delegateScreen1?.editOperation(tag: specVar)
    }
    
    
    @IBAction func buttonActionToDeleteOperation(_ sender: Any) {
        delegateScreen1?.deleteOperationInCoreData(tag: specVar)
        delegateScreen1?.actionsOperationsClosePopUpScreen1()
        delegateScreen1?.screen1AllUpdate()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textViewNotes.layer.cornerRadius = 10
        viewRightParth.layer.cornerRadius = 10
        buttonToEditOperation.layer.cornerRadius = 10
        buttonToDeleteOperation.layer.cornerRadius = 10
        viewLogoCategory.layer.cornerRadius = 10

        // Do any additional setup after loading the view.
    }

    
}

extension ViewControllerScreen1ContainerOperation: protocolScreen1ContainerOperation{
    
    func startCell(tag: Int) {
        
        print(tag)
        print(delegateScreen1!.returnArrayForIncrease()[tag])
        
        specCellTag = tag
        specVar = specCellTag - delegateScreen1!.returnArrayForIncrease()[specCellTag]
        print("Version2!_tagInOperation= \(tag), specVar= \(specVar)")
        
        //Отображения category
        labelCategory.text = delegateScreen1!.returnDataArrayOfOperations()[specVar].category

        // Отображения date
        let formatterPrint = DateFormatter()
        formatterPrint.dateFormat = "d MMMM YYYY"
        labelDate.text = formatterPrint.string(from: delegateScreen1!.returnDataArrayOfOperations()[specVar].date)
        
        // Отображения amount
        if delegateScreen1!.returnDataArrayOfOperations()[specVar].amount.truncatingRemainder(dividingBy: 1) == 0 {
            labelAmount.text = String(format: "%.0f", delegateScreen1!.returnDataArrayOfOperations()[specVar].amount)
        }
        else {
            labelAmount.text = String(format: "%.2f", delegateScreen1!.returnDataArrayOfOperations()[specVar].amount)
        }
        
        // Отображения currencyStatus
        if delegateScreen1!.returnDataArrayOfOperations()[specVar].amount < 0 {
            labelAmount.textColor = UIColor.red
            currencyStatus.textColor = UIColor.red
        }
        else{
            labelAmount.textColor = UIColor(cgColor: CGColor.init(srgbRed: 0.165, green: 0.671, blue: 0.014, alpha: 1))
            currencyStatus.textColor = UIColor(cgColor: CGColor.init(srgbRed: 0.165, green: 0.671, blue: 0.014, alpha: 1))
        }
        
        //Отображение textViewNotes
        textViewNotes.text = delegateScreen1!.returnDataArrayOfOperations()[specVar].note
    }
    
}
