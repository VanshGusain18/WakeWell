//
//  SleepRingCollectionViewCell.swift
//  WakeWell
//
//  Created by geu on 13/02/26.
//

import UIKit

class SleepRingCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var ringContainerView: UIView!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    
    private let backgroundLayer = CAShapeLayer()
    private let progressLayer = CAShapeLayer()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
        applyStyling()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        drawRing()
        applyShadowPath()
    }
    
    private func setupUI() {
        contentView.layer.cornerRadius = 24
        contentView.clipsToBounds = true
        
        layer.masksToBounds = false
    }
    
    private func applyStyling() {
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.15
        layer.shadowRadius = 12
        layer.shadowOffset = CGSize(width: 0, height: 6)
    }
    
    private func applyShadowPath() {
        layer.shadowPath = UIBezierPath(
            roundedRect: bounds,
            cornerRadius: 24
        ).cgPath
    }
    
    private func drawRing() {
        backgroundLayer.removeFromSuperlayer()
        progressLayer.removeFromSuperlayer()
        
        let center = CGPoint(
            x: ringContainerView.bounds.width / 2,
            y: ringContainerView.bounds.height / 2
        )
        
        let radius = min(
            ringContainerView.bounds.width,
            ringContainerView.bounds.height
        ) / 2 - 10
        
        let path = UIBezierPath(
            arcCenter: center,
            radius: radius,
            startAngle: -.pi / 2,
            endAngle: 1.5 * .pi,
            clockwise: true
        )
        
        backgroundLayer.path = path.cgPath
        backgroundLayer.strokeColor = UIColor.systemGray4.cgColor
        backgroundLayer.lineWidth = 10
        backgroundLayer.fillColor = UIColor.clear.cgColor
        ringContainerView.layer.addSublayer(backgroundLayer)
        
        progressLayer.path = path.cgPath
        progressLayer.strokeColor = UIColor.label.cgColor
        progressLayer.lineWidth = 10
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.lineCap = .round
        ringContainerView.layer.addSublayer(progressLayer)
    }
    
    func configure(with viewModel: SleepRingViewModel) {
        scoreLabel.text = viewModel.scoreText
        subtitleLabel.text = viewModel.subtitleText
        progressLayer.strokeEnd = viewModel.progress
    }
}
