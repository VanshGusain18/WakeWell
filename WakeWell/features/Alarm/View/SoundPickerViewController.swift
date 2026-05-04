//
//  SoundPickerViewController.swift
//  WakeWell
//
//  Fully programmatic — no XIB, no Storyboard.
//  Push via navigationController?.pushViewController(SoundPickerViewController(), animated: true)
//

import UIKit

protocol SoundPickerDelegate: AnyObject {
    func didSelectSound(_ name: String, haptic: String)
}

final class SoundPickerViewController: UITableViewController {

    // MARK: - Public config
    var selectedSoundName: String = SoundSelection.default.sound
    var selectedHaptic:    String = SoundSelection.default.haptic
    weak var delegate: SoundPickerDelegate?

    // MARK: - Data
    private let sounds: [String] = [
        "Early Riser (Default)",
        "First Light",
        "Helios",
        "Orbit",
        "Pillar",
        "Spring Time",
        "Under the Stars",
        "Wellspring"
    ]

    // Section indices
    private enum Section: Int, CaseIterable { case haptic = 0, sound = 1 }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Sound & Haptic"
        navigationItem.largeTitleDisplayMode = .never
        tableView.backgroundColor = WakeWellTheme.background
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        navigationController?.navigationBar.tintColor = WakeWellTheme.accentPurple
    }

    // MARK: - DataSource

    override func numberOfSections(in tableView: UITableView) -> Int { Section.allCases.count }

    override func tableView(_ tableView: UITableView,
                            numberOfRowsInSection section: Int) -> Int {
        section == Section.haptic.rawValue ? 1 : sounds.count
    }

    override func tableView(_ tableView: UITableView,
                            titleForHeaderInSection section: Int) -> String? {
        section == Section.haptic.rawValue ? "HAPTIC" : "SOUND"
    }

    override func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: "cell")
        cell.backgroundColor             = WakeWellTheme.cardBackground
        cell.textLabel?.textColor        = WakeWellTheme.labelPrimary
        cell.detailTextLabel?.textColor  = WakeWellTheme.labelSecondary
        cell.tintColor                   = WakeWellTheme.accentPurple
        cell.selectionStyle              = .none

        if indexPath.section == Section.haptic.rawValue {
            cell.textLabel?.text        = "Haptic"
            cell.detailTextLabel?.text  = selectedHaptic
            cell.accessoryType          = .disclosureIndicator
        } else {
            let name = sounds[indexPath.row]
            cell.textLabel?.text = name
            cell.accessoryType   = name == selectedSoundName ? .checkmark : .none
        }
        return cell
    }

    // MARK: - Delegate

    override func tableView(_ tableView: UITableView,
                            willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let h = view as? UITableViewHeaderFooterView else { return }
        h.textLabel?.textColor = WakeWellTheme.labelSecondary
        h.textLabel?.font      = .systemFont(ofSize: 12, weight: .semibold)
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        UISelectionFeedbackGenerator().selectionChanged()

        if indexPath.section == Section.haptic.rawValue {
            let vc = HapticPickerViewController()
            vc.selectedHapticLabel = selectedHaptic
            vc.delegate            = self
            navigationController?.pushViewController(vc, animated: true)
        } else {
            selectedSoundName = sounds[indexPath.row]
            delegate?.didSelectSound(selectedSoundName, haptic: selectedHaptic)
            tableView.reloadSections(IndexSet(integer: Section.sound.rawValue), with: .none)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) { [weak self] in
                self?.navigationController?.popViewController(animated: true)
            }
        }
    }
}

// MARK: - HapticPickerDelegate
extension SoundPickerViewController: HapticPickerDelegate {
    func didSelectHaptic(_ name: String) {
        selectedHaptic = name
        // Refresh haptic row detail
        let ip = IndexPath(row: 0, section: Section.haptic.rawValue)
        tableView.reloadRows(at: [ip], with: .none)
        delegate?.didSelectSound(selectedSoundName, haptic: name)
    }
}
