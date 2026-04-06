//
//  SectionHeaderView.swift
//  riseRitual
//
//  Created by geu on 04/02/26.
//

import UIKit

class SectionHeaderView: UICollectionReusableView {
    @IBOutlet weak var headerLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    func configure(withTitle title: String) {
        headerLabel.text = title
    }
    
}
