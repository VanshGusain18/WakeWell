import UIKit

enum SelectedHandle {
    case none
    case bed
    case sun
}

@IBDesignable
class CircularTimePicker: UIControl {
    var bedtime: Date {
        return angleToDate(startAngle)
    }

    var wakeUp: Date {
        return angleToDate(endAngle)
    }
    
    var startAngle: CGFloat = 3 * .pi / 2 // 10:30 PM approx
    var endAngle: CGFloat = .pi / 2      // 7:30 AM approx
    
    private let trackLayer = CAShapeLayer()
    private let progressLayer = CAShapeLayer()
    private let outerCircleLayer = CAShapeLayer()
    private let bedHandle = CALayer()
    private let sunHandle = CALayer()            
    private var selectedHandle: SelectedHandle = .none // Added state
    
    // Flag to ensure labels and ticks are only added once
    private var isConfigured = false
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        // Outer Circle Layer
        outerCircleLayer.strokeColor = UIColor.systemGray4.cgColor
        outerCircleLayer.fillColor = UIColor.clear.cgColor
        outerCircleLayer.lineWidth = 10
        layer.addSublayer(outerCircleLayer)
        
        // Track Layer (Background Circle)
        trackLayer.strokeColor = UIColor.systemGray6.cgColor
        trackLayer.fillColor = UIColor.clear.cgColor
        trackLayer.lineWidth = 40
        layer.addSublayer(trackLayer)

        // Progress Layer (Orange Bar)
        progressLayer.strokeColor = UIColor.systemOrange.cgColor
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.lineWidth = 40
        progressLayer.lineCap = .round
        layer.addSublayer(progressLayer)
    
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:))) // let the user slide the clock
        addGestureRecognizer(pan)
    }
    
    // Layout
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let radius = (min(bounds.width, bounds.height) / 2) - 30
        
        // Update the static background track path
        let circularPath = UIBezierPath(arcCenter: center, radius: radius, startAngle: 0, endAngle: .pi * 2, clockwise: true)
        trackLayer.path = circularPath.cgPath
        
        // Update the outer circle path
        let outerPath = UIBezierPath(arcCenter: center, radius: radius + 20, startAngle: 0, endAngle: .pi * 2, clockwise: true)
        outerCircleLayer.path = outerPath.cgPath
        
        // One-time setup for labels and ticks
        if !isConfigured {
            drawTicks()
            addClockLabels()
            isConfigured = true
        }
        
        // Adjust icon size
        let iconSize = CGSize(width: 30, height: 30)
        bedHandle.bounds = CGRect(origin: .zero, size: iconSize)
        sunHandle.bounds = CGRect(origin: .zero, size: iconSize)
        
        updateUI()
    }
    
    //  UI Updates
    private func updateUI() {
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let radius = (min(bounds.width, bounds.height) / 2) - 30
        
        // Updating the orange progress bar path
        let progressPath = UIBezierPath(arcCenter: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
        progressLayer.path = progressPath.cgPath
        
        // change colours acc to the duration o fsleep hours
        var diff = endAngle - startAngle
            if diff < 0 { diff += 2 * .pi }
            
            let durationHours = (diff / (2 * .pi)) * 24
            
            // 3. Update Colors based on duration
            if durationHours > 11 || durationHours < 5{
                progressLayer.strokeColor = UIColor.systemRed.cgColor
            } else if durationHours > 7 && durationHours < 9 {
                progressLayer.strokeColor = UIColor.systemGreen.cgColor
            } else if (durationHours > 5 && durationHours < 7 ) || (durationHours > 9 && durationHours < 11) {
                progressLayer.strokeColor = UIColor.systemOrange.cgColor
            }

        bedHandle.position = position(for: startAngle, in: self.bounds, margin: 30)
        sunHandle.position = position(for: endAngle, in: self.bounds, margin: 30)
        
        sendActions(for: .valueChanged)
    }
    
    //  where the user is able to do the seeking of th epan
    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        let location = gesture.location(in: self)
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let angle = atan2(location.y - center.y, location.x - center.x)
        
        if gesture.state == .began {
            let bedPos = bedHandle.position
            let sunPos = sunHandle.position
            
            let bedDist = hypot(location.x - bedPos.x, location.y - bedPos.y)
            let sunDist = hypot(location.x - sunPos.x, location.y - sunPos.y)
            
            if bedDist < sunDist && bedDist < 40 {
                selectedHandle = .bed
            } else if sunDist < bedDist && sunDist < 40 {
                selectedHandle = .sun
            } else {
                selectedHandle = .none
            }
        }
        
        if gesture.state == .changed {
            if selectedHandle == .bed {
                startAngle = angle
            } else if selectedHandle == .sun {
                endAngle = angle
            }
            updateUI()
        }
    }
    
    //  Helper Functions (Math & Formatting)
    private func angleToDate(_ angle: CGFloat) -> Date { // converting the position into radians and specifying according to the 24 hour clock
        var normalizedAngle = angle + .pi / 2
        if normalizedAngle < 0 { normalizedAngle += 2 * .pi }
        if normalizedAngle > 2 * .pi { normalizedAngle -= 2 * .pi }
        
        let totalMinutesInDay: CGFloat = 24 * 60
        let minutes = (normalizedAngle / (2 * .pi)) * totalMinutesInDay
        
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day], from: Date())
        components.hour = 0
        components.minute = Int(minutes)
        
        return calendar.date(from: components) ?? Date()
    }

    func formatTime(_ date: Date) -> String { // representation of the date in time format (only extracting the hours and min)
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: date)
    }
    
    private func position(for angle: CGFloat, in rect: CGRect, margin: CGFloat) -> CGPoint {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = (min(rect.width, rect.height) / 2) - margin
        
        let x = center.x + radius * cos(angle) // logic for showing hte time
        let y = center.y + radius * sin(angle)
        
        return CGPoint(x: x, y: y)
    }
   
    // making the clock
    private func addClockLabels() {
        let labels = ["12PM", "3PM", "6PM", "9PM", "12AM", "3AM", "6AM", "9AM"]
        
        for (index, text) in labels.enumerated() {
            let angle = (-CGFloat.pi / 2) + (CGFloat(index) * (CGFloat.pi / 4))
            
            let label = UILabel()
            label.text = text
            label.font = .systemFont(ofSize: 12, weight: .semibold)
            label.textColor = .secondaryLabel
            label.sizeToFit()
            
            // Positions labels inside the ring
            label.center = position(for: angle, in: self.bounds, margin: 75)
            self.addSubview(label)
        }
    }
    
    private func drawTicks() {
        let tickLayer = CAShapeLayer()
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let radius = (min(bounds.width, bounds.height) / 2) - 45
        
        let path = UIBezierPath(arcCenter: center, radius: radius, startAngle: 0, endAngle: .pi * 2, clockwise: true)
        
        tickLayer.path = path.cgPath
        tickLayer.fillColor = UIColor.clear.cgColor
        tickLayer.strokeColor = UIColor.systemGray4.cgColor
        tickLayer.lineWidth = 8
        
        // This creates the dash effect (2pt line, 6pt gap)
        tickLayer.lineDashPattern = [2, 6]
        
        layer.insertSublayer(tickLayer, below: progressLayer)
    }
}
