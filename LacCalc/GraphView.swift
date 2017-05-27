//
//  GraphView.swift
//  LacCalc
//
//  Created by Toby Satterthwaite on 1/12/16.
//  Copyright © 2016 Thomas Satterthwaite. All rights reserved.
//

import UIKit

@IBDesignable class GraphView: UIView {
    
    @IBInspectable var startColor: UIColor = UIColor.red
    @IBInspectable var endColor: UIColor = UIColor.green
    
    var yPoints: [Int] = [0]
    var xPoints:[Int] = [0]
    //var graphPoints:[Int] = [4, 2, 6, 4, 5, 8, 3]
    
    override func draw(_ rect: CGRect) {
        let minimumValue:Int = yPoints.min()!
        for n in 0..<yPoints.count {
            yPoints[n] -= minimumValue
        }
        let minimumXValue:Int = xPoints.min()!
        for n in 0..<xPoints.count {
            xPoints[n] -= minimumXValue
        }
        
        let width = rect.width
        let height = rect.height
        
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: UIRectCorner.allCorners, cornerRadii: CGSize(width: 8.0, height: 8.0))
        path.addClip()
        
        let context = UIGraphicsGetCurrentContext()
        let colors = [startColor.cgColor, endColor.cgColor]
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let colorLocations:[CGFloat] = [0.0, 1.0]
        let gradient = CGGradient(colorsSpace: colorSpace, colors: colors as CFArray, locations: colorLocations)
        var startPoint = CGPoint.zero
        var endPoint = CGPoint(x:0, y:self.bounds.height)
        context?.drawLinearGradient(gradient!, start: startPoint, end: endPoint, options: CGGradientDrawingOptions(rawValue: 0))
        
        let margin:CGFloat = 31.0
        let graphWidth = width - 2*margin
        let maxXValue = xPoints.max()
        let columnXPoint =  { (xPoint:Int) -> CGFloat in
            var x:CGFloat = CGFloat(xPoint) /
                CGFloat(maxXValue!) * graphWidth
            x = margin + x
            return x
        }
        /*let columnXPoint = { (column:Int) -> CGFloat in
            let spacer = (width - margin*2 - 4) / CGFloat((self.graphPoints.count - 1))
            var x:CGFloat = CGFloat(column) * spacer
            x += margin + 2
            return x
        }*/
        
        let topBorder:CGFloat = 60
        let bottomBorder:CGFloat = 30
        let graphHeight = height - topBorder - bottomBorder
        let maxValue = yPoints.max()
        let columnYPoint = { (yPoint:Int) -> CGFloat in
            var y:CGFloat = CGFloat(yPoint) /
                CGFloat(maxValue!) * graphHeight
            y = graphHeight + topBorder - y
            return y
        }
        
        UIColor.white.setFill()
        UIColor.white.setStroke()
        
        let graphPath = UIBezierPath()
        graphPath.move(to: CGPoint(x: columnXPoint(xPoints[0]), y: columnYPoint(yPoints[0])))
        
        for i in 1..<yPoints.count {
            let nextPoint = CGPoint(x: columnXPoint(xPoints[i]), y: columnYPoint(yPoints[i]))
            graphPath.addLine(to: nextPoint)
        }
        
        context?.saveGState()
        
        let clippingPath = graphPath.copy() as! UIBezierPath
        clippingPath.addLine(to: CGPoint(x: columnXPoint(yPoints.count - 1), y: height))
        clippingPath.addLine(to: CGPoint(x: columnXPoint(0), y: height))
        clippingPath.close()
        clippingPath.addClip()
        
        let highestYPoint = columnYPoint(maxValue!)
        startPoint = CGPoint(x: margin, y: highestYPoint)
        endPoint = CGPoint(x: margin, y: self.bounds.height)
        context?.drawLinearGradient(gradient!, start: startPoint, end: endPoint, options: CGGradientDrawingOptions(rawValue: 0))
        context?.restoreGState()
        
        graphPath.lineWidth = 2.0
        graphPath.stroke()
        
        for i in 0..<yPoints.count {
            var point = CGPoint(x: columnXPoint(xPoints[i]), y: columnYPoint(yPoints[i]))
            point.x -= 5.0/2
            point.y -= 5.0/2
            
            let circle = UIBezierPath(ovalIn: CGRect(origin: point, size: CGSize(width: 5.0, height: 5.0)))
            circle.fill()
        }
        
        let linePath = UIBezierPath()
        
        linePath.move(to: CGPoint(x: margin, y: topBorder))
        linePath.addLine(to: CGPoint(x: width-margin, y: topBorder))
        
        linePath.move(to: CGPoint(x: margin, y: graphHeight/2 + topBorder))
        linePath.addLine(to: CGPoint(x: width-margin, y: graphHeight/2 + topBorder))
        
        linePath.move(to: CGPoint(x: margin, y: height - bottomBorder))
        linePath.addLine(to: CGPoint(x: width-margin, y: height - bottomBorder))
        
        let color = UIColor(white: 1.0, alpha: 0.3)
        color.setStroke()
        
        linePath.lineWidth = 1.0
        linePath.stroke()
    }

}
