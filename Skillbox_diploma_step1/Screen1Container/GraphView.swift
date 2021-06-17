//
//  GraphView.swift
//  Skillbox_diploma_step1
//
//  Created by Roman on 16.05.2021.
//

import UIKit

protocol protocolGraphView{
    func setDelegateScreen1ContainerGraph(deligate: protocolScreen1ContainerGraph)
    func setGraphPoints(data: [GraphData])
}

@IBDesignable class GraphView: UIView {
    
    var deligateScreen1ContainerGraph: protocolScreen1ContainerGraph?
    
    // Weekly sample data
    var graphPoints: [Double] = []
    var cumulativeNumber: [Double] = []
    var maxDeviation: Int = 0
    
    
    private enum Constants{
        static let cornerRadiusSize = CGSize(width: 8.0, height: 8.0)
        static let margin: CGFloat = 45.0
        static let topBorder: CGFloat = 20
        static let bottomBorder: CGFloat = 50
        static let colorAlpha: CGFloat = 0.5
        static let circleDiameter: CGFloat = 5.0
    }
    
    
    override func draw(_ rect: CGRect) {
        
        //Считается кумулятивные значения в графике
        cumulativeNumber = []
        graphPoints.reverse()
        
        for i in graphPoints {
            if cumulativeNumber.isEmpty {
                cumulativeNumber.append(0)
            }
            else{
//                cumulativeNumber.insert(cumulativeNumber.first! - i, at: 0)
                cumulativeNumber.append(cumulativeNumber.last! + i)
            }
        }
        
        //убираем нули с начала графика, чтобы было правильно масштабирование.
        for n in 0..<cumulativeNumber.count {
            if cumulativeNumber[n] == 0 {
                cumulativeNumber[n] = cumulativeNumber.filter( {$0 != 0} ).first ?? 0
            }
        }
        
        print("cumulativeNumber= \(cumulativeNumber)")
        print("graphPoints= \(graphPoints)")
        
        
        let width = rect.width
        let height = rect.height
  
        
        //MARK: - Gradient
        
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: .allCorners,
            cornerRadii: Constants.cornerRadiusSize
        )
        path.addClip()
        //Получаем контекст
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        let colors = [CGColor.init(red: 250/255, green: 233/255, blue: 222/255, alpha: 1), CGColor.init(red: 252/255, green: 79/255, blue: 8/255, alpha: 1)]
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let colorLocations:  [CGFloat] = [0.0, 1.0]
        
        guard let gradient = CGGradient(colorsSpace: colorSpace, colors: colors as CFArray, locations: colorLocations) else { return }
        
        let startPoint = CGPoint.zero
        let endPoint = CGPoint(x: 0, y: bounds.height)
        context.drawLinearGradient(gradient, start: startPoint, end: endPoint, options: [])
    
    
        //MARK: - Points

        //Calculating the x point
        let margin = Constants.margin
        let graphWidth = width - margin * 2 - 4
        let columnXPoint = { (column: Int) -> CGFloat in
            //Calculate the gap between points
            let spacing = graphWidth / CGFloat(self.graphPoints.count - 1)
            return CGFloat(column) * spacing + margin + 2
        }

        //Calculating the y point
        let topBoarder = Constants.topBorder
        let bottomBorder = Constants.bottomBorder
        let graphHeight = height - topBoarder - bottomBorder
        guard let maxValue = cumulativeNumber.max() else { return }
        guard let minValue = cumulativeNumber.min() else { return }
        

        print("maxValue= \(maxValue)")
        print("minValue= \(minValue)")
        
        let cleverString = { (original: Double) -> String in
            if original > 1000 { return "\(String(format: "%.1f", original / 1000))k" }
            else { return String(format: "%.0f", original) }
        }
        
        let maxValue2: String = cleverString(maxValue)
        let minValue2: String = cleverString(minValue)
        let middleValue2: String = cleverString( (maxValue + minValue) / 2 )
        
//        print("maxValue2= \(maxValue2)")
        
        deligateScreen1ContainerGraph?.setGraphIndicators(min: minValue2, middle: middleValue2, max: maxValue2)
        
        var distanceSumOfMinMax = { (min: Double, max: Double) -> Double in
            if max >= 0 && min >= 0 {
                return max - min
            }
            else if max >= 0 && min < 0 {
                return max + abs(min)
            }
            else if max < 0 && min < 0 {
                return abs(min) - abs(max)
            }
            return 0
        }
        print("distanceSumOfMinMax= \(distanceSumOfMinMax(minValue, maxValue))")
//        print("graphHeight + topBoarder= \(graphHeight + topBoarder)")

        let columnYPoint = { (graphPoint: Double) -> CGFloat in
            let yPoint = CGFloat(abs(graphPoint-minValue)) / CGFloat(distanceSumOfMinMax(minValue, maxValue)) * graphHeight
//            print("yPoint= \(yPoint)")
//            print("graphHeight + topBoarder - yPoint= \(graphHeight + topBoarder - yPoint)")
            return graphHeight + topBoarder - yPoint //Flip the graph
        }

        // Draw the line graph
        UIColor.white.setFill()
        UIColor.white.setStroke()

        // Set up the points line
        let graphPath = UIBezierPath()

        // Go to start of line
        graphPath.move(to: CGPoint(x: columnXPoint(0), y: columnYPoint(cumulativeNumber[0])))

        // Add points for each item in the graphPoints array
        // at the correct (x, y) for the point
        for i in 1..<cumulativeNumber.count {
            let nextPoint = CGPoint(x: columnXPoint(i), y: columnYPoint(cumulativeNumber[i]))
            graphPath.addLine(to: nextPoint)
        }
        graphPath.stroke()


        //MARK: - GraphLine
        context.saveGState()
        guard let clippingPath = graphPath.copy() as? UIBezierPath else { return }

        clippingPath.addLine(to: CGPoint(x: columnXPoint(cumulativeNumber.count-1), y: height))
        clippingPath.addLine(to: CGPoint(x: columnXPoint(0), y: height))
        clippingPath.close()
        clippingPath.addClip()

        let highestYPoint = columnYPoint(maxValue)
        let graphStartPoint = CGPoint(x: margin, y: highestYPoint)
        print("highestYPoint= \(highestYPoint)")
        print("bounds.height= \(bounds.height)")
        let graphEndPoint = CGPoint(x: margin, y: bounds.height)

        context.drawLinearGradient(gradient, start: graphStartPoint, end: graphEndPoint, options: [])
        context.restoreGState()

        graphPath.lineWidth = 2.0
        graphPath.stroke()


        //MARK: - Circles on top graph
        for i in 0..<cumulativeNumber.count {
            var point = CGPoint(x: columnXPoint(i), y: columnYPoint(cumulativeNumber[i]))
            point.x -= Constants.circleDiameter / 2
            point.y -= Constants.circleDiameter / 2

            let circle = UIBezierPath(ovalIn: CGRect(origin: point, size: CGSize(width: Constants.circleDiameter, height: Constants.circleDiameter)))
            circle.fill()
        }
        
        
        //MARK: - Rulers
        let lineParth = UIBezierPath()
        
        lineParth.move(to: CGPoint(x: margin, y: topBoarder))
        lineParth.addLine(to: CGPoint(x: width-margin, y: topBoarder))
        
        lineParth.move(to: CGPoint(x: margin, y: graphHeight / 2 + topBoarder))
        lineParth.addLine(to: CGPoint(x: width-margin, y: graphHeight / 2 + topBoarder))
        
        lineParth.move(to: CGPoint(x: margin, y: height - bottomBorder))
        lineParth.addLine(to: CGPoint(x: width-margin, y: height - bottomBorder))
        
        let color = UIColor(white: 1.0, alpha: Constants.colorAlpha)
        color.setStroke()
        
        lineParth.lineWidth = 1.0
        lineParth.stroke()
    }
    
}


//MARK: - additional protocols

extension GraphView: protocolGraphView{
    
    func setDelegateScreen1ContainerGraph(deligate: protocolScreen1ContainerGraph) {
        deligateScreen1ContainerGraph = deligate
    }
    
    
    func setGraphPoints(data: [GraphData]) {
        var internalPoints: [Double] = []
        for n in data {
            internalPoints.append(n.amount)
        }
        graphPoints = internalPoints
        
    }
    
    
}
