import UIKit

class LineChartView: UIView {
    var dataPoints: [CGFloat] = [20, 40, 30, 80, 60, 90, 70] // Example scores
    
    override func draw(_ rect: CGRect) {
        guard dataPoints.count > 1 else { return }
        
        let path = UIBezierPath()
        let columnWidth = rect.width / CGFloat(dataPoints.count - 1)
        
        // Start point
        let startY = rect.height - (dataPoints[0] / 100 * rect.height)
        path.move(to: CGPoint(x: 0, y: startY))
        
        // Draw lines to points
        for i in 1..<dataPoints.count {
            let x = CGFloat(i) * columnWidth
            let y = rect.height - (dataPoints[i] / 100 * rect.height)
            path.addLine(to: CGPoint(x: x, y: y))
        }
        
        // Style the line
        let lineLayer = CAShapeLayer()
        lineLayer.path = path.cgPath
        lineLayer.strokeColor = UIColor.systemBlue.cgColor
        lineLayer.fillColor = UIColor.clear.cgColor
        lineLayer.lineWidth = 3
        lineLayer.lineCap = .round
        
        self.layer.addSublayer(lineLayer)
    }
}
