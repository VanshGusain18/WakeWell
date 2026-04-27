//
//  SoundPickerViewController.swift
//  WakeWell
//
//  Created by geu on 16/03/26.
//

import UIKit
import AVFoundation

protocol SoundPickerDelegate: AnyObject {
    func didSelectSound(_ name: String, haptic: String)
}
class SoundPickerViewController: UITableViewController, HapticPickerDelegate {

    @IBOutlet weak var selectedHapticLabel: UILabel!

    let sounds = [
        "Early Riser(Default)",
        "First Light",
        "Helios",
        "Orbit",
        "Pillar",
        "Spring Time",
        "Under the Stars",
        "Wellspring"
    ]

    var selectedSoundName: String = "Early Riser(Default)"
    var selectedHaptic: String = "None (Default)"
    var selectedIndexPath: IndexPath?
    weak var delegate: SoundPickerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        applyTheme()
        configureBackButton()

        if let index = sounds.firstIndex(of: selectedSoundName) {
            selectedIndexPath = IndexPath(row: index, section: 0)
        }
        selectedHapticLabel?.text = selectedHaptic
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        layoutSelectedHapticLabel()
    }

    private func applyTheme() {
        view.backgroundColor = WakeWellTheme.background
        tableView.backgroundColor = WakeWellTheme.background
        navigationController?.navigationBar.tintColor = WakeWellTheme.accentPurple
        navigationItem.largeTitleDisplayMode = .never
        selectedHapticLabel?.textColor = WakeWellTheme.labelSecondary
        selectedHapticLabel?.textAlignment = .right
        selectedHapticLabel?.adjustsFontSizeToFitWidth = true
        selectedHapticLabel?.minimumScaleFactor = 0.7
    }

    private func configureBackButton() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "chevron.left"),
            style: .plain,
            target: self,
            action: #selector(backTapped)
        )
    }

    @objc private func backTapped() {
        if navigationController?.viewControllers.first == self {
            dismiss(animated: true)
        } else {
            navigationController?.popViewController(animated: true)
        }
    }

    private func layoutSelectedHapticLabel() {
        guard let selectedHapticLabel, let container = selectedHapticLabel.superview else { return }
        let availableWidth = min(170, max(120, container.bounds.width * 0.45))
        var frame = selectedHapticLabel.frame
        frame.size.width = availableWidth
        frame.origin.x = container.bounds.width - 16 - availableWidth
        selectedHapticLabel.frame = frame.integral
    }

    func didSelectHaptic(_ name: String) {
        selectedHaptic = name
        selectedHapticLabel?.text = name
        delegate?.didSelectSound(selectedSoundName, haptic: name)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? HapticPickerViewController {
            vc.delegate = self
            vc.selectedHapticLabel = selectedHaptic
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        cell.backgroundColor = WakeWellTheme.cardBackground
        cell.contentView.backgroundColor = WakeWellTheme.cardBackground
        cell.textLabel?.textColor = WakeWellTheme.labelPrimary
        cell.tintColor = WakeWellTheme.accentPurple
        if indexPath.section == 1 {
            cell.accessoryType = indexPath == selectedIndexPath ? .checkmark : .none
        } else {
            cell.accessoryType = .disclosureIndicator
        }
        return cell
    }

    override func tableView(_ tableView: UITableView,
                            willDisplayHeaderView view: UIView,
                            forSection section: Int) {
        guard let header = view as? UITableViewHeaderFooterView else { return }
        header.tintColor = WakeWellTheme.background
        header.textLabel?.textColor = WakeWellTheme.labelSecondary
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.section == 1 else { return }
        UISelectionFeedbackGenerator().selectionChanged()
        selectedIndexPath = indexPath
        let cell = tableView.cellForRow(at: indexPath)

        if let soundName = cell?.textLabel?.text {
            selectedSoundName = soundName
            delegate?.didSelectSound(soundName, haptic: selectedHaptic) // sending the name back
        }
        
        tableView.reloadData()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            self.backTapped()
        }
    }
}
