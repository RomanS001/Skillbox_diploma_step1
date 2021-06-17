//
//  Screen1TableViewCellHeader.swift
//  Skillbox_diploma_step1
//
//  Created by Roman on 26.01.2021.
//

import UIKit

class Screen1TableViewCellHeader: UITableViewCell {
    
    @IBOutlet var labelHeaderDate: UILabel!
    
    var delegateScreen1: protocolScreen1Delegate?
    var specCellTag: Int = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func startCellEmpty() {
        print("HeaderEmpty: ---")
        labelHeaderDate.text = "No entries yet."
    }

    
    func startCell() {
        print("Header1: ---")
        let formatterPrint = DateFormatter()
        formatterPrint.timeZone = TimeZone(secondsFromGMT: 10800) //+3 час(Moscow)
        formatterPrint.dateFormat = "d MMMM YYYY"
//        print("111: \(formatterPrint.string(from: delegateScreen1!.returnDataArrayOfOperations()[specCellTag].date))")
        labelHeaderDate.text = formatterPrint.string(from: delegateScreen1!.returnDataArrayOfOperations()[specCellTag].date)
    }
    
    func startCell2() {
        print("Header2: ---")
        let formatterPrint = DateFormatter()
        formatterPrint.dateFormat = "d MMMM YYYY"
        let specVar: Int = specCellTag - delegateScreen1!.returnArrayForIncrease()[specCellTag - 1]
        print("222: \(formatterPrint.string(from: delegateScreen1!.returnDataArrayOfOperations()[specVar].date))")
        labelHeaderDate.text = formatterPrint.string(from: delegateScreen1!.returnDataArrayOfOperations()[specVar].date)
    }
    
    func setTag(tag: Int) {
        specCellTag = tag
    }

}
