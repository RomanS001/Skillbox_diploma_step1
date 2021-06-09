//
//  Screen2TableViewCellDate.swift
//  Skillbox_diploma_step1
//
//  Created by Roman on 06.03.2021.
//

import UIKit

protocol protocolScreen2TableViewCellDateDelegate{
    func returnDateTextField() -> UILabel
}

//class CustomTextField: UITextField {
//
//    override func caretRect(for position: UITextPosition) -> CGRect {
//        return CGRect.zero
//    }
//    selec
//    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
//        false
//    }
//
//    override func selectionRects(for range: UITextRange) -> [UITextSelectionRect] {
//    }
//
////    override func caretRect(for position: UITextPosition) -> CGRect { .zero }
//}

class Screen2TableViewCellDate: UITableViewCell {

    @IBOutlet var labelDate: UILabel!
    @IBOutlet var labelSelectDate: UILabel!
    @IBOutlet var buttonSelectDate: UIButton!
    
    
    //MARK: - делегаты и переменные
    
    var delegateScreen2: protocolScreen2Delegate?
    var specCellTag: Int = 0
    

    //MARK: - переходы
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
    
    @objc func startEditing() {
//        textFieldSelectDate.becomeFirstResponder()
        delegateScreen2?.openAlertDatePicker()
        print("startEditing")
    }
    
    
    func startCell() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none

        if delegateScreen2?.returnNewOperation().date != Date.init(timeIntervalSince1970: TimeInterval(0)) {
            labelSelectDate.text = dateFormatter.string(from: delegateScreen2!.returnNewOperation().date!)
            labelSelectDate.textColor = .black
        }
        else{
            labelSelectDate.text = delegateScreen2?.returnScreen2MenuArray()[specCellTag].text
        }

//        textFieldSelectDate.tintColor = UIColor.clear //делает курсор бесцветным, но не убирает его
        labelDate.text = delegateScreen2?.returnScreen2MenuArray()[specCellTag].name
        self.isUserInteractionEnabled = true
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(startEditing))
        self.addGestureRecognizer(gesture)
    }
    
    func setTag(tag: Int) {
        specCellTag = tag
    }
}


extension Screen2TableViewCellDate: protocolScreen2TableViewCellDateDelegate{
    
    
    func returnDateTextField() -> UILabel {
//        tapOutsideNoteTextViewEditToHide()
//        textViewNotes.endEditing(true)
        print("textViewDeselect")
        return labelSelectDate
    }

    
    //MARK: - Обработка касаний экрана
    
//    func tapOutsideDateTextViewEditToHide(){
//        textFieldSelectDate.endEditing(true)
//        print("textFieldSelectDateDeselect")
//    }
}
