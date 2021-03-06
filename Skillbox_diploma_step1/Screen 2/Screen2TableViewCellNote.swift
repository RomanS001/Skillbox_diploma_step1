//
//  TableViewCellNote.swift
//  Skillbox_diploma_step1
//
//  Created by Roman on 19.01.2021.
//

import UIKit

protocol protocolScreen2TableViewCellNoteDelegate{
    func tapOutsideNoteTextViewEditToHide()
    func returnNoteView() -> UITextView
    func setNoteViewText(newText: String)
}
    

class Screen2TableViewCellNote: UITableViewCell, UITextViewDelegate {

//    @IBOutlet var textFieldNotes: UITextField!
    @IBOutlet var textViewNotes: UITextView!
    
    var delegateScreen2: protocolScreen2Delegate?
    var specCellTag: Int = 0
    
// MARK: - Работа с Placeholder
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textViewNotes.textColor == UIColor.opaqueSeparator {
            textViewNotes.text = nil
            textViewNotes.textColor = UIColor.black
        }
    print("func textViewDidBeginEditing")

    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textViewNotes.text.isEmpty {
            textViewNotes.text = "Placeholder"
            textViewNotes.textColor = UIColor.opaqueSeparator
        }
        textView.resignFirstResponder()
        print("func textViewDidEndEditing")
    }
    
    //MARK: - Стандартные функции
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func startCell() {
        textViewNotes.text = delegateScreen2?.returnScreen2MenuArray()[specCellTag].text
        
        textViewNotes.textContainer.lineBreakMode = .byTruncatingTail
        textViewNotes.layer.borderColor = UIColor.gray.cgColor
        textViewNotes.layer.borderWidth = 2
        
        textViewNotes.layer.cornerRadius = 10
        
        textViewNotes.text = "Placeholder"
//        textViewNotes.textColor = UIColor.opaqueSeparator //цвет текста уже opaqueSeparator в Storyboard.
        
    }
    
    func setTag(tag: Int) {
        specCellTag = tag
    }
}


extension Screen2TableViewCellNote: protocolScreen2TableViewCellNoteDelegate{
    
    
    func setNoteViewText(newText: String) {
        textViewNotes.text = newText
        print("newText= \(newText)")
        textViewNotes.textColor = UIColor.black
    }
    
    
    func returnNoteView() -> UITextView {
//        tapOutsideNoteTextViewEditToHide()
//        textViewNotes.endEditing(true)
        print("textViewDeselect")
        return textViewNotes
    }

    
    //MARK: - Обработка касаний экрана
    
    func tapOutsideNoteTextViewEditToHide(){
        textViewNotes.endEditing(true)
        print("textViewDeselect")
    }
    
}
