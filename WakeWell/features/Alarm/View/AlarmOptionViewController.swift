//
//  AlarmOptionViewController.swift
//  WakeWell
//
//  UITableViewController that registers and dequeues 5 custom XIB-backed cells.
//  All outlets live inside the cell classes — the VC only holds references
//  to the cell instances themselves (captured after dequeue).
//
//  Present via:
//      let vc  = AlarmOptionViewController()
//      let nav = UINavigationController(rootViewController: vc)
//      nav.modalPresentationStyle = .pageSheet
//      present(nav, animated: true)
//

import UIKit
import UserNotifications

final class AlarmOptionViewController: UITableViewController {

    // MARK: - Cell references (captured after first dequeue)
    // These are strong — cells are owned by the table, we just keep a
    // convenience pointer so we can read/write their outlets directly.
    private var pickerCell:       AlarmPickerCell?
    private var wakeToggleCell:   AlarmToggleCell?
    private var wakeSoundCell:    AlarmSoundCell?
    private var wakeSliderCell:   AlarmSliderCell?
    private var smartWindowCell:  AlarmSmartWindowCell?
    private var bedToggleCell:    AlarmToggleCell?
    private var bedSoundCell:     AlarmSoundCell?
    private var bedSliderCell:    AlarmSliderCell?

    // MARK: - State
    private let viewModel  = AlarmSchedulerViewModel()
    private var activeSection: Int = 1

    // Stable Bool flags — numberOfRowsInSection must NOT read a UISwitch
    // outlet because the cell may not exist yet (or may have been recycled).
    private var wakeUpOn:  Bool = false
    private var bedtimeOn: Bool = false

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.delegate = self
        viewModel.requestNotificationPermission()
        setupNavBar()
        setupTableView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        applyTheme()
        refreshSoundLabels()
    }

    // MARK: - Setup

    private func setupNavBar() {
        title = "Alarm"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .done, target: self, action: #selector(doneTapped)
        )
        navigationItem.rightBarButtonItem?.tintColor = WakeWellTheme.accentPurple
    }

    private func setupTableView() {
        tableView.backgroundColor = WakeWellTheme.background
        tableView.separatorColor  = WakeWellTheme.border
        tableView.separatorInset  = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0)

        // Register every custom XIB cell
        register(AlarmPickerCell.self,      nib: AlarmPickerCell.reuseID)
        register(AlarmToggleCell.self,      nib: AlarmToggleCell.reuseID)
        register(AlarmSoundCell.self,       nib: AlarmSoundCell.reuseID)
        register(AlarmSliderCell.self,      nib: AlarmSliderCell.reuseID)
        register(AlarmSmartWindowCell.self, nib: AlarmSmartWindowCell.reuseID)
    }

    private func register<T: UITableViewCell>(_ type: T.Type, nib: String) {
        tableView.register(UINib(nibName: nib, bundle: nil), forCellReuseIdentifier: nib)
    }

    private func applyTheme() {
        view.backgroundColor      = WakeWellTheme.background
        tableView.backgroundColor = WakeWellTheme.background
        navigationController?.navigationBar.tintColor = WakeWellTheme.accentPurple
    }

    // MARK: - UITableViewDataSource

    override func numberOfSections(in tableView: UITableView) -> Int { 3 }

    override func tableView(_ tableView: UITableView,
                            numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 1
        case 1: return wakeUpOn  ? 4 : 1
        case 2: return bedtimeOn ? 3 : 1
        default: return 0
        }
    }

    override func tableView(_ tableView: UITableView,
                            titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 1: return "WAKE UP"
        case 2: return "BEDTIME"
        default: return nil
        }
    }

    override func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch (indexPath.section, indexPath.row) {

        case (0, _):
            let cell = dequeue(AlarmPickerCell.self, id: AlarmPickerCell.reuseID, for: indexPath)
            pickerCell = cell
            cell.timePicker.addTarget(self, action: #selector(timePickerChanged), for: .valueChanged)
            return cell

        // ── Section 1 ── Wake Up rows
        case (1, 0):
            let cell = dequeue(AlarmToggleCell.self, id: AlarmToggleCell.reuseID, for: indexPath)
            wakeToggleCell = cell
            cell.titleLabel.text = "Wake Up Alarm"
            cell.toggle.isOn     = wakeUpOn
            cell.toggle.removeTarget(nil, action: nil, for: .valueChanged)
            cell.toggle.addTarget(self, action: #selector(wakeUpToggleChanged), for: .valueChanged)
            return cell

        case (1, 1):
            let cell = dequeue(AlarmSoundCell.self, id: AlarmSoundCell.reuseID, for: indexPath)
            wakeSoundCell = cell
            cell.summaryLabel.text = viewModel.config.wakeUpSound.displayText
            return cell

        case (1, 2):
            let cell = dequeue(AlarmSliderCell.self, id: AlarmSliderCell.reuseID, for: indexPath)
            wakeSliderCell = cell
            cell.slider.value = viewModel.config.wakeUpVolume
            cell.slider.removeTarget(nil, action: nil, for: .valueChanged)
            cell.slider.addTarget(self, action: #selector(wakeUpVolumeChanged), for: .valueChanged)
            return cell

        case (1, 3):
            let cell = dequeue(AlarmSmartWindowCell.self, id: AlarmSmartWindowCell.reuseID, for: indexPath)
            smartWindowCell = cell
            configureSmartWindowMenu(cell.menuButton)
            return cell

        // ── Section 2 ── Bedtime rows
        case (2, 0):
            let cell = dequeue(AlarmToggleCell.self, id: AlarmToggleCell.reuseID, for: indexPath)
            bedToggleCell = cell
            cell.titleLabel.text = "Bedtime Reminder"
            cell.toggle.isOn     = bedtimeOn
            cell.toggle.removeTarget(nil, action: nil, for: .valueChanged)
            cell.toggle.addTarget(self, action: #selector(bedTimeToggleChanged), for: .valueChanged)
            return cell

        case (2, 1):
            let cell = dequeue(AlarmSoundCell.self, id: AlarmSoundCell.reuseID, for: indexPath)
            bedSoundCell = cell
            cell.summaryLabel.text = viewModel.config.bedtimeSound.displayText
            return cell

        case (2, 2):
            let cell = dequeue(AlarmSliderCell.self, id: AlarmSliderCell.reuseID, for: indexPath)
            bedSliderCell = cell
            cell.slider.value = viewModel.config.bedtimeVolume
            cell.slider.removeTarget(nil, action: nil, for: .valueChanged)
            cell.slider.addTarget(self, action: #selector(bedTimeVolumeChanged), for: .valueChanged)
            return cell

        default:
            return UITableViewCell()
        }
    }

    private func dequeue<T: UITableViewCell>(_ type: T.Type, id: String,
                                             for indexPath: IndexPath) -> T {
        // swiftlint:disable:next force_cast
        return tableView.dequeueReusableCell(withIdentifier: id, for: indexPath) as! T
    }

    // MARK: - UITableViewDelegate

    override func tableView(_ tableView: UITableView,
                            heightForRowAt indexPath: IndexPath) -> CGFloat {
        indexPath.section == 0 ? 400 : 52
    }

    override func tableView(_ tableView: UITableView,
                            willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let header = view as? UITableViewHeaderFooterView else { return }
        header.textLabel?.textColor = WakeWellTheme.labelSecondary
        header.textLabel?.font      = .systemFont(ofSize: 12, weight: .semibold)
    }

    override func tableView(_ tableView: UITableView,
                            didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        guard (indexPath.section == 1 && indexPath.row == 1) ||
              (indexPath.section == 2 && indexPath.row == 1) else { return }

        activeSection = indexPath.section
        let vc = SoundPickerViewController()
        let sel = indexPath.section == 1
            ? viewModel.config.wakeUpSound
            : viewModel.config.bedtimeSound
        vc.delegate          = self
        vc.selectedSoundName = sel.sound
        vc.selectedHaptic    = sel.haptic
        navigationController?.pushViewController(vc, animated: true)
    }

    // MARK: - IBActions (target–action, wired in cellForRowAt)

    @objc private func timePickerChanged(_ sender: CircularTimePicker) {
        viewModel.config.wakeUpTime = sender.wakeUp
        viewModel.config.bedtime    = sender.bedtime
    }

    @objc private func wakeUpToggleChanged(_ sender: UISwitch) {
        viewModel.config.wakeUpEnabled = sender.isOn
        let was = wakeUpOn
        wakeUpOn = sender.isOn
        toggleRows(section: 1, count: 3, wasOn: was, isOn: sender.isOn)
    }

    @objc private func bedTimeToggleChanged(_ sender: UISwitch) {
        viewModel.config.bedtimeEnabled = sender.isOn
        let was = bedtimeOn
        bedtimeOn = sender.isOn
        toggleRows(section: 2, count: 2, wasOn: was, isOn: sender.isOn)
    }

    @objc private func wakeUpVolumeChanged(_ sender: UISlider) {
        viewModel.config.wakeUpVolume = sender.value
    }

    @objc private func bedTimeVolumeChanged(_ sender: UISlider) {
        viewModel.config.bedtimeVolume = sender.value
    }

    @objc private func doneTapped() {
        viewModel.saveAlarm()
    }

    // MARK: - Helpers
    private func toggleRows(section: Int, count: Int, wasOn: Bool, isOn: Bool) {
        guard wasOn != isOn else { return }
        let paths = (1...count).map { IndexPath(row: $0, section: section) }
        tableView.beginUpdates()
        isOn
            ? tableView.insertRows(at: paths, with: .fade)
            : tableView.deleteRows(at: paths, with: .fade)
        tableView.endUpdates()
    }

    private func refreshSoundLabels() {
        wakeSoundCell?.summaryLabel.text = viewModel.config.wakeUpSound.displayText
        bedSoundCell?.summaryLabel.text  = viewModel.config.bedtimeSound.displayText
    }

    private func configureSmartWindowMenu(_ btn: UIButton) {
        let current = SmartWindow(rawValue: btn.title(for: .normal) ?? "") ?? .thirty
        let actions = SmartWindow.allCases.map { w in
            UIAction(title: w.rawValue, state: w == current ? .on : .off) { [weak self, weak btn] _ in
                self?.viewModel.config.smartWindowMinutes = w.minutes
                btn?.setTitle(w.rawValue, for: .normal)
                if let b = btn { self?.configureSmartWindowMenu(b) }
            }
        }
        btn.menu = UIMenu(title: "Smart Wake Window", options: .singleSelection, children: actions)
        btn.showsMenuAsPrimaryAction = true
    }
}

// MARK: - AlarmSchedulerViewModelDelegate

extension AlarmOptionViewController: AlarmSchedulerViewModelDelegate {

    func alarmDidSave(wakeUpTime: Date, isSmart: Bool) {
        let f = DateFormatter(); f.dateFormat = "h:mm a"
        let msg = isSmart
            ? "Smart alarm set for \(f.string(from: wakeUpTime)) — lightest sleep phase."
            : "Alarm set for \(f.string(from: wakeUpTime))."
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Alarm Set", message: msg, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
                self?.dismiss(animated: true)
            })
            self.present(alert, animated: true)
        }
    }

    func alarmSaveFailed(message: String) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Alarm", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true)
        }
    }
}

// MARK: - SoundPickerDelegate

extension AlarmOptionViewController: SoundPickerDelegate {
    func didSelectSound(_ name: String, haptic: String) {
        let sel = SoundSelection(sound: name, haptic: haptic)
        if activeSection == 1 { viewModel.config.wakeUpSound  = sel }
        else                   { viewModel.config.bedtimeSound = sel }
        refreshSoundLabels()
    }
}
