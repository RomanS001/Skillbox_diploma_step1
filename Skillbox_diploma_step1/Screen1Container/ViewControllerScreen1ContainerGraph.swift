//
//  ViewScreen1ContainerGraph.swift
//  Skillbox_diploma_step1
//
//  Created by Roman on 01.05.2021.
//

import UIKit

protocol protocolScreen1ContainerGraph{
    func containerGraphUpdate()
    func setGraphIndicators(min: String, middle: String, max: String)
}

class ViewControllerScreen1ContainerGraph: UIViewController {
    
    
    //MARK: - объявление аутлетов
    
    @IBOutlet var graphView: GraphView!
    @IBOutlet var weeklyStackView: UIStackView!
    @IBOutlet var monthlyStackView: UIStackView!
    @IBOutlet var minIndicatorLabel: UILabel!
    @IBOutlet var middleIndicatorLabel: UILabel!
    @IBOutlet var maxIndicatorLabel: UILabel!
    
    
    //MARK: - делегаты и переменные
    
    var delegateScreen1: ViewController?

    
    //Mark: - Functions
    
    func countFullPointsArray(){
        print("countFullPointsArray")
        guard let graphData = delegateScreen1?.returnGraphData() else { return }
        print("graphData= \(graphData)")
        for n in graphData {
            print("graphData_n.cumulativeAmount= \(n.amount), graphData_n.date= \(n.date)")
        }
        
        var graphDataFinal: [GraphData] = []
        
        //Заполнение дней, в которых не было операций
        //Проверка наличия операция сегодня. Если нет проставляется 0.
        if graphData.count > 0{
            print("graphData1111")
//            if graphDataFinal.isEmpty {
//                graphDataFinal.append(GraphData(newDate: Date(), newAmount: graphData[0].amount))
//            }
        
            //Проверка заполнения оставшихся дней. Если запись пуста - ставим 0.
            var x: Int = 0
            
            for n in 0..<(delegateScreen1?.returnDaysForSorting())!{
                print("graphData2222")
                
                if graphData.count >= x + 1{
                    print("graphData3333")
                    if delegateScreen1?.returnDayOfDate(graphData[x].date) != delegateScreen1?.returnDayOfDate(Calendar.current.date(byAdding: .day, value: -n, to: Date())!) {
                        print("graphData4444")
                        graphDataFinal.append(GraphData(newDate: Calendar.current.date(byAdding: .day, value: -n, to: Date())!, newAmount: 0))
                    }
                    else{
                        print("graphData5555")
                        graphDataFinal.append(GraphData(newDate: Calendar.current.date(byAdding: .day, value: -n, to: Date())!, newAmount: graphData[x].amount))
                        x += 1

                    }
                }
                else{
                    print("graphData6666")
                    graphDataFinal.append(GraphData(newDate: Calendar.current.date(byAdding: .day, value: -n, to: Date())!, newAmount: 0))
                    x += 1
                }
                
            }
            
        }


        for n in graphDataFinal {
            print("n.cumulativeAmount= \(n.amount), n.date= \(n.date)")
        }
        
        graphView.setGraphPoints(data: graphDataFinal)
        graphView.setNeedsDisplay()
    }
    
    
    
    
    //MARK: - viewDidLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        graphView.setDelegateScreen1ContainerGraph(deligate: self)

        graphView.layer.cornerRadius = 20
        graphView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner]
        graphView.clipsToBounds = true
    }
    
    
}


extension ViewControllerScreen1ContainerGraph: protocolScreen1ContainerGraph{
    
    func setGraphIndicators(min: String, middle: String, max: String) {
        minIndicatorLabel.text = min
        middleIndicatorLabel.text = middle
        maxIndicatorLabel.text = max
    }
    
    
    func containerGraphUpdate() {
        countFullPointsArray()

        switch delegateScreen1?.returnDaysForSorting() {
            case 365:
                weeklyStackView.isHidden = true
                monthlyStackView.isHidden = false
            case 30:
                weeklyStackView.isHidden = true
                monthlyStackView.isHidden = true
            default:
                weeklyStackView.isHidden = false
                monthlyStackView.isHidden = true
        }
        
    }
    
    
}
