//
//  RitualHeaderView.swift
//  WakeWell
//
//  Created by geu on 30/03/26.
//

import UIKit

class RitualHeaderView: UICollectionReusableView {
    
    let titleLabel = UILabel()
    
    static let identifier = "RitualHeaderView"
    
    override init(frame: CGRect) {
         super.init(frame: frame)
         
         titleLabel.font = UIFont.boldSystemFont(ofSize: 22)
         titleLabel.textColor = .label
         
         addSubview(titleLabel)
         titleLabel.translatesAutoresizingMaskIntoConstraints = false
         
         NSLayoutConstraint.activate([
             titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
             titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor)
         ])
     }
     
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
