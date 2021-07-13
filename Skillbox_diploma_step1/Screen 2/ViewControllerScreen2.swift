//
//  ViewControllerScreen2.swift
//  Skillbox_diploma_step1
//
//  Created by Roman on 16.01.2021.
//

import UIKit

protocol protocolScreen2Delegate{
    func changeCategoryClosePopUpScreen2()
    func changeCategoryOpenPopUpScreen2(_ tag: Int)
    func tableViewScreen2Update(row: Int)
    func screen2DataReceiveUpdate()
    
    //функции возврата
    func returnScreen2MenuArray() -> [Screen2MenuData]
    func returnDelegateScreen2TableViewCellNote() -> protocolScreen2TableViewCellNoteDelegate
    func returnNewOperation() -> UserDefaultOperation
    func returnDataArrayOfCategory() -> [DataOfCategories]
    func returnDelegateScreen1() -> protocolScreen1Delegate
    
    //функции обновления newOperation
    func setAmountInNewOperation(amount: Double)
    func setCategoryInNewOperation(category: String)
    func setNoteInNewOperation(note: String)
    func setIDInNewOperation(id: Int)
    func setDateInNewOperation(date: Date)
    func openAlertDatePicker()
    func screen2StatusIsEditingStart()
}

struct Screen2MenuData {
    let name: String
    let text: String
}


class DataOfCategories{
    var name: String
    var icon: String
    var id: Int

    init(name1: String, icon1: String, id1: Int) {
        self.name = name1
        self.icon = icon1
        self.id = id1
    }
}


class ViewControllerScreen2: UIViewController {

    //MARK: - объявление аутлетов
    
    @IBOutlet var screen2SegmentControl: UISegmentedControl!
    @IBOutlet var tableViewScreen2: UITableView!
    @IBOutlet var screen2CurrencyStatus: UIButton!
    @IBOutlet var containerBottomScreen2: UIView!
    @IBOutlet var constraintContainerBottomPoint: NSLayoutConstraint!
    @IBOutlet var constraintContainerBottomHeight: NSLayoutConstraint!
    @IBOutlet var textFieldAmount: UITextField!
    @IBOutlet var labelScreen2Header: UILabel!
    
    
    //MARK: - делегаты, переменные
    
    var delegateScreen1: protocolScreen1Delegate?
    private var delegateScreen2Container: protocolScreen2ContainerDelegate?
    private var delegateScreen2TableViewCellCategory: protocolScreen2TableViewCellCategory?
    private var delegateScreen2TableViewCellNote: protocolScreen2TableViewCellNoteDelegate?
    private var delegateScreen2TableViewCellDate: protocolScreen2TableViewCellDateDelegate?
    var screen2StatusEditing: Bool = false //показывает, создаётся ли новая операция, или редактируется предыдущая
    
    var tapOfChangeCategoryOpenPopUp: UITapGestureRecognizer?
    var tapOutsideTextViewToGoFromTextView: UITapGestureRecognizer?
    var dataArrayOfCategory: [DataOfCategories] = [] //хранение оригинала данных из Realm
    var keyboardHeight: CGFloat = 0 //хранит высоту клавиатуры
    
    
    //MARK: - объекты
    
    let alertDatePicker = UIAlertController(title: "Select date", message: nil, preferredStyle: .actionSheet)
    let alertErrorAddNewOperation = UIAlertController(title: "Добавьте обязательные данные", message: nil, preferredStyle: .alert)
    let blurViewScreen2 =  UIVisualEffectView(effect: UIBlurEffect(style: .dark))
    
    var newOperation = UserDefaultOperation(newAmount: 0, newCategory: "", newNote: "", newDate: Date.init(timeIntervalSince1970: TimeInterval(0)), newID: 0)
//    var newOperation = UserDefaultOperation()
    
    let datePicker = UIDatePicker()
    
    
    //MARK: - переходы
    
    @IBAction func buttonToAddNewOperation(_ sender: Any) {
        
        if newOperation.category != "" && textFieldAmount.text != "0" {
            
            //set Amount
            print("2. screen2SegmentControl.selectedSegmentIndex= \(screen2SegmentControl.selectedSegmentIndex)")
            if screen2SegmentControl.selectedSegmentIndex == 0 {
                print("textFieldAmount.text= \(textFieldAmount.text)")
                setAmountInNewOperation(amount: Double(textFieldAmount.text ?? "0")!)
            }
            else if screen2SegmentControl.selectedSegmentIndex == 1 {
                setAmountInNewOperation(amount: -Double(textFieldAmount.text ?? "0")!)
            }
            
            
            //set Date
            if delegateScreen2TableViewCellDate?.returnDateTextField().text == "Today" {
                let dateNow = Date.init()
                setDateInNewOperation(date: dateNow)
            }
            else {
                setDateInNewOperation(date: datePicker.date)
            }
            
            
            //set Note
            if delegateScreen2TableViewCellNote?.returnNoteView().text! == "Placeholder" {
                setNoteInNewOperation(note: "")
            }
            else {
                setNoteInNewOperation(note: (delegateScreen2TableViewCellNote?.returnNoteView().text!)!)
            }
            
            print("newOperation.amount= \(newOperation.amount), newOperation.category= \(newOperation.category), newOperation.date= \(newOperation.date), newOperation.note= \(newOperation.note),")
            
            if screen2StatusEditing == true{
                print("newOperation.amount222= \(newOperation.amount)")
                print("newOperation.date222= \(newOperation.date)")
                delegateScreen1?.editOperationInRealm(newAmount: newOperation.amount, newCategory: newOperation.category, newNote: newOperation.note, newDate: newOperation.date, id: newOperation.id)
            }
            else{
                delegateScreen1?.addOperationInRealm(newAmount: newOperation.amount, newCategory: newOperation.category, newNote: newOperation.note, newDate: newOperation.date)
            }
            
            delegateScreen1?.screen1AllUpdate()
            dismiss(animated: true, completion: nil)
        }
        else {
            self.present(alertErrorAddNewOperation, animated: true, completion: nil)
        }
        
    }
    
    
    @IBAction func buttonCloseScreen2(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? ViewControllerScreen2Container, segue.identifier == "segueToScreen2Container"{
            delegateScreen2Container = vc
            vc.delegateScreen2 = self
        }
    }
    
    
    //MARK: - Alerts
    
    
    func createAlertAddNewOperations(){
        alertErrorAddNewOperation.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil ))
        
        let labelAlertAddNewOperations = UILabel.init(frame: CGRect(x: 0, y: 0, width: 180, height: 50))
        labelAlertAddNewOperations.numberOfLines = 2
        labelAlertAddNewOperations.text = "Выберите категорию операции и сумму."
        alertErrorAddNewOperation.view.addSubview(labelAlertAddNewOperations)
        labelAlertAddNewOperations.translatesAutoresizingMaskIntoConstraints = false
        
        alertErrorAddNewOperation.view.translatesAutoresizingMaskIntoConstraints = false
        
        alertErrorAddNewOperation.view.addConstraint(NSLayoutConstraint(item: labelAlertAddNewOperations, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 180))
        alertErrorAddNewOperation.view.addConstraint(NSLayoutConstraint(item: labelAlertAddNewOperations, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 50))
        
        alertErrorAddNewOperation.view.addConstraint(NSLayoutConstraint(item: labelAlertAddNewOperations, attribute: .centerX, relatedBy: .equal, toItem: alertErrorAddNewOperation.view, attribute: .centerX, multiplier: 1, constant: 0))
        alertErrorAddNewOperation.view.addConstraint(NSLayoutConstraint(item: labelAlertAddNewOperations, attribute: .top, relatedBy: .equal, toItem: alertErrorAddNewOperation.view, attribute: .top, multiplier: 1, constant: 80))
        alertErrorAddNewOperation.view.addConstraint(NSLayoutConstraint(item: labelAlertAddNewOperations, attribute: .bottom, relatedBy: .equal, toItem: alertErrorAddNewOperation.view, attribute: .bottom, multiplier: 1, constant: 40))
        
        alertErrorAddNewOperation.view.addConstraint(NSLayoutConstraint(item: alertErrorAddNewOperation.view, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: labelAlertAddNewOperations.frame.height + 140))
        
        print(alertErrorAddNewOperation.view.frame.width)
        print(labelAlertAddNewOperations.frame.width)
        
    }
    
    
    func createAlertDatePicker() {
        alertDatePicker.addAction(UIAlertAction(title: "Установить дату", style: .default, handler: { _ in self.donePressed() }))
        alertDatePicker.addAction(UIAlertAction(title: "Cancell", style: .cancel, handler: nil ))
        alertDatePicker.view.addSubview(datePicker)
        
        let alertHeightConstraint = NSLayoutConstraint(item: alertDatePicker.view!, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: datePicker.frame.height + 150)
        alertDatePicker.view.addConstraint(alertHeightConstraint)
        datePicker.frame.origin.x = (alertDatePicker.view.frame.width - datePicker.frame.width) / 2
        datePicker.frame.origin.y = 25
    }
    
    
    //MARK: - DatePicker
    
    func createDatePicker(){
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.datePickerMode = .date
        datePicker.timeZone = TimeZone(secondsFromGMT: 10800) //+3 час(Moscow)
        datePicker.maximumDate = Date.init()
    }
    
    func donePressed(){
//        formatter.dateFormat = "yyyy/MM/dd HH:mm"
        newOperation.date = datePicker.date
        tableViewScreen2Update(row: 2)
//        closeDateAlert()
    }
    
    
    //MARK: - клики
    
    @IBAction func textFieldAmountEditingDidBegin(_ sender: Any) {
        if textFieldAmount.textColor == UIColor.opaqueSeparator {
            textFieldAmount.text = nil
            
            switch screen2SegmentControl.selectedSegmentIndex {
            case 0:
                textFieldAmount.textColor = UIColor(cgColor: CGColor.init(srgbRed: 0.165, green: 0.671, blue: 0.014, alpha: 1))
            case 1:
                textFieldAmount.textColor = UIColor.red
            default:
                break
            }
        }
        print("func textViewDidBeginEditing")
    }
    
    @IBAction func textFieldAmountEditingDidEnd(_ sender: Any) {
        if textFieldAmount.text == "" {
            textFieldAmount.text = "0"
            textFieldAmount.textColor = UIColor.opaqueSeparator
        }
        textFieldAmount.resignFirstResponder()
        print("func textFieldAmountEditingDidEnd")
    }
    
    
    @IBAction func screen2SegmentControlAction(_ sender: Any) {
        textFieldAmount.endEditing(true)
        delegateScreen2TableViewCellNote?.tapOutsideNoteTextViewEditToHide()
        switch screen2SegmentControl.selectedSegmentIndex {
        case 0:
            screen2CurrencyStatus.setTitle("+$", for: .normal)
            screen2CurrencyStatus.setTitleColor(UIColor(cgColor: CGColor.init(srgbRed: 0.165, green: 0.671, blue: 0.014, alpha: 1)), for: .normal)
            textFieldAmount.textColor = UIColor(cgColor: CGColor.init(srgbRed: 0.165, green: 0.671, blue: 0.014, alpha: 1))
        case 1:
            screen2CurrencyStatus.setTitle("-$", for: .normal)
            screen2CurrencyStatus.setTitleColor(UIColor.red, for: .normal)
            textFieldAmount.textColor = UIColor.red
        default:
            break
        }
    }
    
    @objc func screen2TapHandler(tap: UITapGestureRecognizer){
        if tap.state == UIGestureRecognizer.State.ended {
                print("Tap TextView ended")
            let pointOfTap = tap.location(in: self.view)
            
            //Tap inside noteTextView
            if delegateScreen2TableViewCellNote!.returnNoteView().frame.contains(pointOfTap) {
                textFieldAmount.endEditing(true)
                print("Tap inside noteTextView")
            }
            
            //Tap inside in dateTextView
            else if delegateScreen2TableViewCellDate!.returnDateTextField().frame.contains(pointOfTap) {
                textFieldAmount.endEditing(true)
                delegateScreen2TableViewCellNote?.tapOutsideNoteTextViewEditToHide()
                print("Tap inside in dateTextView")
            }
            
            //Tap inside in textFieldAmount
            else if textFieldAmount.frame.contains(pointOfTap){
                print("Tap inside in textFieldAmount")
                delegateScreen2TableViewCellNote?.tapOutsideNoteTextViewEditToHide()
            }
            
            else {
                
                //Tap outside noteTextView and dateTextView and textFieldAmount
                textFieldAmount.endEditing(true)
                delegateScreen2TableViewCellNote?.tapOutsideNoteTextViewEditToHide()
                print("Tap outside noteTextView and dateTextView and textFieldAmount")
            }
        }
    }
    
    @objc func handlerToHideContainerScreen2(tap: UITapGestureRecognizer){
        if tap.state == UIGestureRecognizer.State.ended {
            print("Tap ended")
            let pointOfTap = tap.location(in: self.view)
            if containerBottomScreen2.frame.contains(pointOfTap) {
                print("Tap inside Container")
            }
            else {
                print("Tap outside Container")
                changeCategoryClosePopUpScreen2()
            }
        }
    }
    
    
    //MARK: - данные
    
    func screen2DataReceive(){
        print("screen2DataReceive")
        dataArrayOfCategory = []
        for n in Persistence.shared.returnUserDefaultsDataCategories(){
            dataArrayOfCategory.append(DataOfCategories(name1: n.name, icon1: n.icon, id1: n.id))
        }
//        for n in dataArrayOfCategory {
//            print("dataArrayOfCategory= \(n.name)")
//        }
    }
    
    var screen2MenuArray: [Screen2MenuData] = []
    let screen2MenuList0 = Screen2MenuData(name: "Header", text: "")
    let screen2MenuList1 = Screen2MenuData(name: "Category", text: "Select category")
    let screen2MenuList2 = Screen2MenuData(name: "Date", text: "Today")
    let screen2MenuList3 = Screen2MenuData(name: "Notes", text: "")
    
    
    //MARK: - viewWillAppear
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        if screen2StatusEditing == true{
            screen2StatusIsEditingStart()
        }
        
        super.viewWillAppear(animated)
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillDisappear), name: UIResponder.keyboardWillHideNotification, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillAppear), name: UIResponder.keyboardWillShowNotification, object: nil)
        
    }


    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        screen2DataReceive()
        screen2MenuArray = [screen2MenuList0, screen2MenuList1, screen2MenuList2, screen2MenuList3]
        
        self.view.insertSubview(self.blurViewScreen2, belowSubview: self.containerBottomScreen2)
        self.blurViewScreen2.backgroundColor = .clear
        self.blurViewScreen2.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.blurViewScreen2.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.blurViewScreen2.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.blurViewScreen2.heightAnchor.constraint(equalTo: self.view.heightAnchor),
            self.blurViewScreen2.widthAnchor.constraint(equalTo: self.view.widthAnchor)
        ])
        self.blurViewScreen2.isHidden = true
        
        self.view.layoutIfNeeded()
        print("screen2MenuArray.count: \(screen2MenuArray.count)")
        
        self.tapOutsideTextViewToGoFromTextView = UITapGestureRecognizer(target: self, action: #selector(self.screen2TapHandler(tap:)))
        self.view.addGestureRecognizer(self.tapOutsideTextViewToGoFromTextView!)
        
        createDatePicker()
        createAlertDatePicker()
        createAlertAddNewOperations()
        
    }
    
    
    //MARK: - other functions
    
    @objc func keyboardWillAppear(_ notification: Notification) {
        print("keyboardWillAppear")
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue{
            let keyboardRectangle = keyboardFrame.cgRectValue
            keyboardHeight = keyboardRectangle.height
        }
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: UIView.AnimationOptions(), animations: {
            if self.constraintContainerBottomPoint.constant == 50{
                self.constraintContainerBottomPoint.constant = self.keyboardHeight + CGFloat.init(20)
            }
            self.view.layoutIfNeeded()
        }, completion: {isCompleted in })
    }

    
    @objc func keyboardWillDisappear(_ notification: Notification) {
        if keyboardHeight != 0{
            print("keyboardWillDisappear")
            keyboardHeight = 0
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: UIView.AnimationOptions(), animations: {
                if self.constraintContainerBottomPoint.constant > 50 {
                    self.constraintContainerBottomPoint.constant = CGFloat.init(50)
                }
                self.view.layoutIfNeeded()
            }, completion: {isCompleted in })
        }
    }
    
    
}


//MARK: - additional protocols

extension ViewControllerScreen2: protocolScreen2Delegate{
    
    
    func screen2DataReceiveUpdate() {
        screen2DataReceive()
    }
    
    
    func returnDelegateScreen1() -> protocolScreen1Delegate {
        return delegateScreen1!
    }
    
    
    func screen2StatusIsEditingStart() {
        print("1. screen2SegmentControl.selectedSegmentIndex= \(screen2SegmentControl.selectedSegmentIndex)")
        
        //set Amount
        if newOperation.amount > 0 {
            screen2SegmentControl.selectedSegmentIndex = 0
        }
        else if newOperation.amount < 0 {
            screen2SegmentControl.selectedSegmentIndex = 1
            newOperation.amount = -newOperation.amount
        }
        
        if newOperation.amount.truncatingRemainder(dividingBy: 1) == 0 {
            textFieldAmount.text = "\(String(format: "%.0f", newOperation.amount))"
        }
        else {
            textFieldAmount.text = "\(String(format: "%.2f", newOperation.amount))"
        }
        
        switch screen2SegmentControl.selectedSegmentIndex {
        case 0:
            screen2CurrencyStatus.setTitle("+$", for: .normal)
            screen2CurrencyStatus.setTitleColor(UIColor(cgColor: CGColor.init(srgbRed: 0.165, green: 0.671, blue: 0.014, alpha: 1)), for: .normal)
            textFieldAmount.textColor = UIColor(cgColor: CGColor.init(srgbRed: 0.165, green: 0.671, blue: 0.014, alpha: 1))
        case 1:
            screen2CurrencyStatus.setTitle("-$", for: .normal)
            screen2CurrencyStatus.setTitleColor(UIColor.red, for: .normal)
            textFieldAmount.textColor = UIColor.red
        default:
            break
        }

        //set Date
        datePicker.date = newOperation.date
        
        //set Note
        delegateScreen2TableViewCellNote?.setNoteViewText(newText: self.newOperation.note)
        print("newOperation.note= \(newOperation.note)")

        labelScreen2Header.text = "Edit"
        
    }
    
    
    func openAlertDatePicker() {
        self.present(alertDatePicker, animated: true, completion: nil)
    }
    
    func returnScreen2MenuArray() -> [Screen2MenuData] {
        return screen2MenuArray
    }
    
    
    func returnDataArrayOfCategory() -> [DataOfCategories] {
        return dataArrayOfCategory
    }
    
    
    func tableViewScreen2Update(row: Int) {
        print("tableViewScreen2Update activated")
        let indexPath = IndexPath.init(row: row, section: 0)
        tableViewScreen2.reloadRows(at: [indexPath], with: .fade)
    }
    
    
    func setAmountInNewOperation(amount: Double) {
        newOperation.amount = amount
    }
    
    
    func setCategoryInNewOperation(category: String) {
        newOperation.category = category
    }
    
    
    func setDateInNewOperation(date: Date) {
        newOperation.date = date
    }
    
    
    func setNoteInNewOperation(note: String) {
        newOperation.note = note
    }
    
    
    func setIDInNewOperation(id: Int) {
        newOperation.id = id
    }
    
    
    func returnNewOperation() -> UserDefaultOperation{
        return newOperation
    }
    
    
    func returnDelegateScreen2TableViewCellNote() -> protocolScreen2TableViewCellNoteDelegate {
        return delegateScreen2TableViewCellNote!
    }
    
    
//    func changeCategoyPopUpScreen2Height(status: Bool){
//        if status == true{
//            self.constraintContainerBottomHeight.constant = CGFloat(50*(self.screen2MenuArray.count+3+1))
//            self.constraintContainerBottomPoint.constant = 0
//        }
//        else {
//            self.constraintContainerBottomHeight.constant = CGFloat(50*(self.screen2MenuArray.count+3))
//            self.constraintContainerBottomPoint.constant = 50
//        }
//    }
    
    
    //MARK: - окрытие PopUp-окна
    
    func changeCategoryOpenPopUpScreen2(_ tag: Int) {
        self.containerBottomScreen2.layer.cornerRadius = 20
        self.constraintContainerBottomHeight.constant = CGFloat(50*(self.screen2MenuArray.count+3))
        textFieldAmount.endEditing(true)
        delegateScreen2TableViewCellNote?.tapOutsideNoteTextViewEditToHide()
        
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: UIView.AnimationOptions(), animations: {
            self.constraintContainerBottomPoint.constant = 50
            self.tapOfChangeCategoryOpenPopUp = UITapGestureRecognizer(target: self, action: #selector(self.handlerToHideContainerScreen2(tap:)))
            self.view.addGestureRecognizer(self.tapOfChangeCategoryOpenPopUp!)
            self.blurViewScreen2.isHidden = false
            self.view.layoutIfNeeded()
        }, completion: {isCompleted in })
    }
    
    
    //MARK: - закрытие PopUp-окна
    
    func changeCategoryClosePopUpScreen2() {
        tableViewScreen2Update(row: 1)
        UIView.animate(withDuration: 0, delay: 0, usingSpringWithDamping: 0, initialSpringVelocity: 0, options: UIView.AnimationOptions(), animations: {
            self.constraintContainerBottomPoint.constant = -515
            self.blurViewScreen2.isHidden = true
            self.view.endEditing(true)
            self.view.removeGestureRecognizer(self.tapOfChangeCategoryOpenPopUp!)
            self.view.layoutIfNeeded()
            if self.delegateScreen2Container?.returnScreen2StatusEditContainer() == true{
                self.delegateScreen2Container?.returnDelegateScreen2Container_TableViewCellNewCategory().textFieldNewCategoryClear()
            }
        }, completion: {isCompleted in })
    }
    
}


//MARK: - caching press button protocols

extension ViewControllerScreen2: UITextViewDelegate{
    
    //    override func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
    //        print("pressesBegan")
    //        print("screen2StatusEditing= \(screen2StatusEditing)")
    //        print("self.constraintContainerBottomPoint.constant= \(self.constraintContainerBottomPoint.constant)")
    //
    //        if screen2StatusEditing == true && self.constraintContainerBottomPoint.constant != -515{
    //            self.constraintContainerBottomPoint.constant = 300
    //        }
    //        else if self.constraintContainerBottomPoint.constant != -515{
    ////            self.constraintContainerBottomPoint.constant = 250
    //        }
    //    }
}


//MARK: - table Functionality protocols

extension ViewControllerScreen2: UITableViewDelegate, UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return screen2MenuArray.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "header") as! Screen2TableViewCellHeader
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellCategory") as! Screen2TableViewCellCategory
            cell.delegateScreen2 = self
            cell.setTag(tag: indexPath.row)
            cell.startCell()
            
            self.delegateScreen2TableViewCellCategory = cell
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellDate") as! Screen2TableViewCellDate
            cell.delegateScreen2 = self
            cell.setTag(tag: indexPath.row)
            cell.startCell()
            
            self.delegateScreen2TableViewCellDate = cell
            return cell
        default:
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellNote") as! Screen2TableViewCellNote
            cell.delegateScreen2 = self
            cell.setTag(tag: indexPath.row)
            cell.startCell()
            cell.textViewNotes.delegate = cell
            
            self.delegateScreen2TableViewCellNote = cell
            return cell
        }
    }
    
    
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
//        if indexPath.row == 3 {
//            return 88
//        }
//        else{
//            return 44
//        }
//    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}
