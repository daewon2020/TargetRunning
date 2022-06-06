//
//  CircleProgressBar.swift
//  TargetRunning
//
//  Created by Константин Андреев on 06.06.2022.
//

import UIKit

class CircleProgressBar: UIView {
    
    
    private var circleLayer = CAShapeLayer()
    private var progressLayer = CAShapeLayer()
    private var startPoint = CGFloat(-Double.pi / 2)
    private var endPoint = CGFloat(3 * Double.pi / 2)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        crateCirclePath()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func crateCirclePath() {
        let circlePath = UIBezierPath(
            arcCenter: CGPoint(x: frame.height / 2, y: frame.height / 2),
            radius: frame.width / 2 - 30,
            startAngle: startPoint,
            endAngle: endPoint,
            clockwise: true
        )
        
        circleLayer.path = circlePath.cgPath
        circleLayer.fillColor = .none
        circleLayer.lineCap = .round
        circleLayer.lineWidth = 15.0
        circleLayer.strokeEnd = 1
        circleLayer.strokeColor = UIColor.gray.cgColor
        layer.addSublayer(circleLayer)
        
        progressLayer.path = circlePath.cgPath
        progressLayer.fillColor = .none
        progressLayer.lineCap = .round
        progressLayer.lineWidth = 13.0
        progressLayer.strokeEnd = 0.59
        progressLayer.strokeColor = UIColor.green.cgColor
        layer.addSublayer(progressLayer)
    }
    
    func increaseProgressValue(for value: CGFloat) {
        UIView.animate(withDuration: 0.4, delay: 0, options: [.allowAnimatedContent]) {
            self.progressLayer.strokeEnd += value
        }
    }
}
