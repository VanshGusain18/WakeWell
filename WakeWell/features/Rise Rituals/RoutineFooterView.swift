//
//  RoutineFooterView.swift
//  WakeWell
//
//  Created by geu on 31/03/26.
//

import UIKit

class RoutineFooterView: UICollectionReusableView {
    static let identifier = "RoutineFooterView"
    let startButton = UIButton(type: .system)
    var startAction: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        startButton.setTitle("Start Routine", for: .normal)
        startButton.backgroundColor = .systemBlue
        startButton.setTitleColor(.white, for: .normal)
        startButton.titleLabel?.font = .boldSystemFont(ofSize: 18)
        startButton.layer.cornerRadius = 12
        startButton.addTarget(self, action: #selector(btnTapped), for: .touchUpInside)
        
        addSubview(startButton)
        startButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            startButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            startButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            startButton.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.8),
            startButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    @objc func btnTapped() { startAction?() }
    required init?(coder: NSCoder) { fatalError() }
}
