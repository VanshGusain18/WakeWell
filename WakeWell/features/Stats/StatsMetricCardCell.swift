//
//  StatsMetricCardCell.swift
//  WakeWell
//
//  Created by geu on 12/02/26.
//

import UIKit

class StatsMetricCardCell: UITableViewCell {
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    
    var onTap: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()

        let tap = UITapGestureRecognizer(target: self, action: #selector(cardTapped))
        cardView.addGestureRecognizer(tap)
        cardView.isUserInteractionEnabled = true
        cardView.layer.cornerRadius = 16
        cardView.layer.borderWidth = 1
        cardView.layer.borderColor = UIColor.black.cgColor

    }

    func configure(title: String, value: String, onTap: (() -> Void)? = nil) {
        titleLabel.text = title
        valueLabel.text = value
        self.onTap = onTap
    }

    @objc private func cardTapped() {
        onTap?()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    

}
