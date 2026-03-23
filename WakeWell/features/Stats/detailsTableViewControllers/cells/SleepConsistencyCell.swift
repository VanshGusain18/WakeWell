//
//  SleepConsistencyCell.swift
//  WakeWell
//
//  Created by geu on 23/03/26.
//

import UIKit

class SleepConsistencyCell: UITableViewCell {

    @IBOutlet weak var glassContainer: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var graphView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setupStyle()
    }
    private func setupStyle() {
        glassContainer.backgroundColor = UIColor.white.withAlphaComponent(0.6)
        glassContainer.layer.cornerRadius = 20
        glassContainer.layer.borderWidth = 1
        glassContainer.layer.borderColor = UIColor.white.withAlphaComponent(0.4).cgColor

        glassContainer.layer.shadowColor = UIColor.black.cgColor
        glassContainer.layer.shadowOpacity = 0.05
        glassContainer.layer.shadowOffset = CGSize(width: 0, height: 4)
        glassContainer.layer.shadowRadius = 10

        selectionStyle = .none
        backgroundColor = .clear

        titleLabel.font = .systemFont(ofSize: 16, weight: .semibold)
    }

    func configure(title: String, data: [SleepTiming]) {
        titleLabel.text = title
        
        graphView.subviews.forEach { $0.removeFromSuperview() }

        let width = graphView.bounds.width
        let height = graphView.bounds.height

        let maxHour: Double = 24.0

        for (index, item) in data.enumerated() {
            let x = CGFloat(index) / CGFloat(data.count) * width

            let bedY = height - CGFloat(item.bedtime / maxHour) * height
            let wakeY = height - CGFloat(item.wakeTime / maxHour) * height

            // Bedtime dot
            let bedDot = createDot(color: .systemBlue)
            bedDot.center = CGPoint(x: x, y: bedY)
            graphView.addSubview(bedDot)

            // Wake time dot
            let wakeDot = createDot(color: .systemGreen)
            wakeDot.center = CGPoint(x: x, y: wakeY)
            graphView.addSubview(wakeDot)
        }
    }

    private func createDot(color: UIColor) -> UIView {
        let dot = UIView(frame: CGRect(x: 0, y: 0, width: 8, height: 8))
        dot.backgroundColor = color
        dot.layer.cornerRadius = 4
        return dot
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        graphView.subviews.forEach { $0.removeFromSuperview() }
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

