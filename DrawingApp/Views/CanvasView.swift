//
//  CanvasView.swift
//  DrawingApp
//
//  Created by Nuthan Raju Pesala on 22/06/20.
//  Copyright © 2020 Nuthan Raju Pesala. All rights reserved.
//

import UIKit

struct PointAndColor {
    var color: UIColor?
    var width: CGFloat?
    var opacity: CGFloat?
    var points: [CGPoint]?
    
    init(color: UIColor, points: [CGPoint]) {
        self.color = color
        self.points = points
    }
}


class CanvasView: UIView {
    
    var lines = [PointAndColor]()
    var strokeWidth: CGFloat = 1.0
    var strokeColor: UIColor = .black
    var strokeOpacity: CGFloat = 1.0
    
    let label: UILabel = {
      let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Draw Something Here"
        label.textAlignment = .center
        label.font = UIFont(name: label.font.familyName, size: 14)
        label.textColor = UIColor.blue
        return label
    }()
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        if lines.count == 0 {
             self.label.isHidden = false
        }
        
        lines.forEach { (line) in
            for (i,p) in (line.points?.enumerated())! {
                if i == 0 {
                    context.move(to: p)
                }else {
                     context.addLine(to: p)
                }
                context.setStrokeColor(line.color?.withAlphaComponent(line.opacity ?? 1.0).cgColor ?? UIColor.black.cgColor)
                context.setLineWidth(line.width ?? 1.0)
            }
            context.setLineCap(CGLineCap.round)
            context.strokePath()
            
        }
    
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        label.isHidden = true
        lines.append(PointAndColor(color: UIColor(), points: [CGPoint]()))
    }
    
    // Track the finger as we move across Screen
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first?.location(in: nil) else {  return }
        
        guard var lastPoint = lines.popLast() else { return }
        
        lastPoint.points?.append(touch)
        lastPoint.color = strokeColor
        lastPoint.width = strokeWidth
        lastPoint.opacity = strokeOpacity
        lines.append(lastPoint)
        setNeedsDisplay()
    }
    
    func clearCanvasView() {
        lines.removeAll()
        setNeedsDisplay()
        self.label.isHidden = false
    }
    
    func undoLines() {
        if lines.count > 0 {
            lines.removeLast()
            setNeedsDisplay()
        }else {
             self.label.isHidden = false
        }
    }
    
    func takeScreenshot() -> UIImage {
        if lines.count > 0  {
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, UIScreen.main.scale)
        
        drawHierarchy(in: self.bounds, afterScreenUpdates: true)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        if image != nil {
            return image!
        }
        }else {
            self.label.isHidden = false
        }
        return UIImage()
    }
   
    
}
