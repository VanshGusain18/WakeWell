//
//  SleepRingAlarmPairCell.swift
//  WakeWell
//
//  Created by geu on 11/04/26.
//

import UIKit

class SleepRingAlarmPairCell: UICollectionViewCell {
    
    static let identifier = "SleepRingAlarmPairCell"
    
    @IBOutlet weak var ringHost : UIView!
    @IBOutlet weak var alarmHost : UIView!
    
    private var ringCell:  SleepRingCollectionViewCell?
    private var alarmCell: AlarmCollectionViewCell?

    var onChevronTapped: (() -> Void)?
    var onAlarmTapped:   (() -> Void)?

    // MARK: - Lifecycle

    override func awakeFromNib() {
        super.awakeFromNib()

        // The pair cell itself must be fully transparent — the two child
        // cells each draw their own white card with shadow.
        backgroundColor              = .clear
        contentView.backgroundColor  = .clear

        // Kill any background the XIB set on the container view that sits
        // inside contentView (the view with id "dhx-d7-5by" in the XIB).
        for sub in contentView.subviews {
            sub.backgroundColor = .clear
        }

        embedChildCells()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        onChevronTapped = nil
        onAlarmTapped   = nil
    }

    // MARK: - Embedding

    private func embedChildCells() {
        embedRingCell()
        embedAlarmCell()
    }

    private func embedRingCell() {
        let views = UINib(nibName: "SleepRingCollectionViewCell", bundle: nil)
            .instantiate(withOwner: nil, options: nil)
        guard let cell = views.first as? SleepRingCollectionViewCell else { return }

        cell.translatesAutoresizingMaskIntoConstraints = false
        ringHost.backgroundColor = .clear
        ringHost.addSubview(cell)
        NSLayoutConstraint.activate([
            cell.topAnchor.constraint(equalTo: ringHost.topAnchor),
            cell.bottomAnchor.constraint(equalTo: ringHost.bottomAnchor),
            cell.leadingAnchor.constraint(equalTo: ringHost.leadingAnchor),
            cell.trailingAnchor.constraint(equalTo: ringHost.trailingAnchor)
        ])

        cell.onChevronTapped = { [weak self] in
            self?.onChevronTapped?()
        }
        ringCell = cell
    }

    private func embedAlarmCell() {
        let views = UINib(nibName: "AlarmCollectionViewCell", bundle: nil)
            .instantiate(withOwner: nil, options: nil)
        guard let cell = views.first as? AlarmCollectionViewCell else { return }

        cell.translatesAutoresizingMaskIntoConstraints = false
        alarmHost.backgroundColor = .clear
        alarmHost.addSubview(cell)
        NSLayoutConstraint.activate([
            cell.topAnchor.constraint(equalTo: alarmHost.topAnchor),
            cell.bottomAnchor.constraint(equalTo: alarmHost.bottomAnchor),
            cell.leadingAnchor.constraint(equalTo: alarmHost.leadingAnchor),
            cell.trailingAnchor.constraint(equalTo: alarmHost.trailingAnchor)
        ])

        let tap = UITapGestureRecognizer(target: self, action: #selector(alarmTapped))
        cell.contentView.addGestureRecognizer(tap)
        cell.contentView.isUserInteractionEnabled = true

        alarmCell = cell
    }

    @objc private func alarmTapped() {
        onAlarmTapped?()
    }

    // MARK: - Configure

    func configure(ring ringModel: SleepRingModel, alarm alarmModel: AlarmModel) {
        ringCell?.configure(with: SleepRingViewModel(model: ringModel))
        alarmCell?.configure(with: AlarmViewModel(model: alarmModel))
    }

    func animateChevron(expanded: Bool) {
        ringCell?.animateChevron(expanded: expanded)
    }
}
