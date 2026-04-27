//
//  AlarmOptionViewController.swift
//  WakeWell
//

import UIKit
import UserNotifications
import HealthKit

class AlarmOptionViewController: UITableViewController, SoundPickerDelegate {

    @IBOutlet weak var wakeUpToggle: UISwitch!
    @IBOutlet weak var bedTimeToggle: UISwitch!
    @IBOutlet weak var buttonWindow: UIButton!
    @IBOutlet weak var selectedSoundLabel: UILabel!
    @IBOutlet weak var selectedSoundLabel2: UILabel!
    @IBOutlet weak var timePicker: CircularTimePicker!
    @IBOutlet weak var bedtimeLabel: UILabel!
    @IBOutlet weak var wakeupLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var doneTapped: UIBarButtonItem!
    @IBOutlet weak var wakeUpVolumeSlider: UISlider!
    @IBOutlet weak var bedTimeVolumeSlider: UISlider!

    private let wakeUpOptionRows = [1, 2, 3]
    private let bedtimeOptionRows = [1, 2]
    var selectedWindow = "30 min"
    var activeSection: Int = 1
    private var wakeUpSoundSelection = (sound: "Early Riser(Default)", haptic: "None (Default)")
    private var bedtimeSoundSelection = (sound: "Early Riser(Default)", haptic: "None (Default)")

    // HealthKit store — used to read sleep stages from Apple Watch
    private let healthStore = HKHealthStore()

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.isScrollEnabled = true
        applyTheme()
        buttonWindow.setTitle(selectedWindow, for: .normal)
        setupSmartAlarmMenu()
        timePicker.addTarget(self, action: #selector(pickerChanged), for: .valueChanged)
        updateSoundLabels()

        // Ask for notification permission on first launch
        requestNotificationPermission()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        applyTheme()
        updateSoundLabels()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        layoutSummaryLabel(selectedSoundLabel)
        layoutSummaryLabel(selectedSoundLabel2)
    }

    private func applyTheme() {
        view.backgroundColor = WakeWellTheme.background
        tableView.backgroundColor = WakeWellTheme.background
        navigationController?.navigationBar.tintColor = WakeWellTheme.accentPurple
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always

        [selectedSoundLabel, selectedSoundLabel2, bedtimeLabel, wakeupLabel, durationLabel].forEach {
            $0?.textColor = WakeWellTheme.labelPrimary
        }
        [selectedSoundLabel, selectedSoundLabel2].forEach {
            $0?.textAlignment = .right
            $0?.adjustsFontSizeToFitWidth = true
            $0?.minimumScaleFactor = 0.7
            $0?.lineBreakMode = .byTruncatingTail
        }

        doneTapped.tintColor = WakeWellTheme.accentPurple
        buttonWindow.setTitleColor(WakeWellTheme.accentPurple, for: .normal)
        wakeUpToggle.onTintColor = WakeWellTheme.accentPurple
        bedTimeToggle.onTintColor = WakeWellTheme.accentPurple
        timePicker.applyTheme()
        [wakeUpVolumeSlider, bedTimeVolumeSlider].forEach { styleVolumeSlider($0) }
        tableView.reloadData()
    }

    private func updateSoundLabels() {
        selectedSoundLabel.text = "\(wakeUpSoundSelection.sound) • \(wakeUpSoundSelection.haptic)"
        selectedSoundLabel2.text = "\(bedtimeSoundSelection.sound) • \(bedtimeSoundSelection.haptic)"
    }

    private func layoutSummaryLabel(_ label: UILabel?) {
        guard let label, let container = label.superview else { return }
        let availableWidth = min(150, max(110, container.bounds.width * 0.38))
        var frame = label.frame
        frame.size.width = availableWidth
        frame.origin.x = container.bounds.width - 44 - availableWidth
        label.frame = frame.integral
    }

    private func styleVolumeSlider(_ slider: UISlider?) {
        guard let slider else { return }
        slider.minimumTrackTintColor = WakeWellTheme.accentPurple
        slider.maximumTrackTintColor = WakeWellTheme.border
        slider.thumbTintColor = WakeWellTheme.accentGold
        slider.minimumValueImage = slider.minimumValueImage?.withTintColor(WakeWellTheme.labelSecondary, renderingMode: .alwaysOriginal)
        slider.maximumValueImage = slider.maximumValueImage?.withTintColor(WakeWellTheme.labelSecondary, renderingMode: .alwaysOriginal)
        slider.setValue(max(slider.value, 0.5), animated: false)
        slider.setThumbImage(makeSliderThumbImage(), for: .normal)
        slider.setThumbImage(makeSliderThumbImage(), for: .highlighted)
        slider.setMinimumTrackImage(makeSliderTrackImage(color: WakeWellTheme.accentPurple), for: .normal)
        slider.setMaximumTrackImage(makeSliderTrackImage(color: WakeWellTheme.border), for: .normal)
    }

    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert, .sound, .criticalAlert]   // criticalAlert overrides silent mode
        ) { granted, error in
            if let error { print("Notification permission error: \(error)") }
        }
    }

    // Requests HealthKit sleep-analysis read permission.
    // Call this once (e.g. on first alarm save) so the entitlement is declared.
    private func requestHealthKitPermission(completion: @escaping (Bool) -> Void) {
        guard HKHealthStore.isHealthDataAvailable(),
              let sleepType = HKObjectType.categoryType(
                  forIdentifier: .sleepAnalysis) else {
            completion(false)
            return
        }
        healthStore.requestAuthorization(toShare: nil, read: [sleepType]) { success, _ in
            completion(success)
        }
    }


   // The picker

    @IBAction func pickerChanged(_ sender: CircularTimePicker) {
        _ = angleToTimeString(timePicker.startAngle)
        _ = angleToTimeString(timePicker.endAngle)

        bedtimeLabel.text  = timePicker.formatTime(timePicker.bedtime)
        wakeupLabel.text   = timePicker.formatTime(timePicker.wakeUp)

        let diff   = Calendar.current.dateComponents([.hour, .minute],
                                                      from: timePicker.bedtime,
                                                      to:   timePicker.wakeUp)
        var hours  = diff.hour ?? 0
        if hours < 0 { hours += 24 }
        durationLabel.text = "\(hours) hr"
    }
    private func angleToTimeString(_ angle: CGFloat) -> String { "10:30 PM" }

    func setupSmartAlarmMenu() {
        let options = ["15 min", "30 min", "45 min"]
        let menuActions = options.map { title in
            UIAction(title: title, state: title == selectedWindow ? .on : .off) { [weak self] _ in
                self?.buttonWindow.setTitle(title, for: .normal)
                self?.selectedWindow = title
                self?.setupSmartAlarmMenu()
            }
        }
        buttonWindow.menu = UIMenu(title: "Select Window",
                                   options: .singleSelection,
                                   children: menuActions)
        buttonWindow.showsMenuAsPrimaryAction = true
    }

    @IBAction func toggleChanged(_ sender: UISwitch) {
        tableView.beginUpdates()
        tableView.endUpdates()
    }

    // Done and save alarm

    @IBAction func doneTapped(_ sender: Any) {
        guard wakeUpToggle.isOn else {
            showAlarmSetAlert(message: "Enable the Wake Up toggle to set an alarm.")
            return
        }

        // 1. Remove any previously scheduled WakeWell alarms
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: ["wakewell.alarm"]
        )

        // 2. Determine the hard wake-up time from the picker
        let hardWakeTime = timePicker.wakeUp          // Date with today's time components
        let windowMinutes = windowToMinutes(selectedWindow)
        UserDefaults.standard.set(hardWakeTime, forKey: "wakewell.savedAlarmTime")
        NotificationCenter.default.post(name: .alarmTimeDidChange, object: nil)
        // 3. Build a window: [hardWakeTime - window, hardWakeTime]
        //    During scheduling we'll try to find a light-sleep moment in this window.
        //    If HealthKit data isn't available yet we fall back to the hard wake time.
        requestHealthKitPermission { [weak self] granted in
            guard let self else { return }
            if granted {
                self.scheduleSmartAlarm(hardWakeTime: hardWakeTime,
                                        windowMinutes: windowMinutes)
            } else {
                // No HealthKit — schedule a regular alarm at the exact wake time
                self.scheduleAlarmNotification(at: hardWakeTime,
                                               isSmart: false)
            }
        }

        showAlarmSetAlert(message: "Your smart alarm has been set for \(timePicker.formatTime(hardWakeTime)).")
    }
    private func scheduleSmartAlarm(hardWakeTime: Date, windowMinutes: Int) {
        guard let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) else {
            scheduleAlarmNotification(at: hardWakeTime, isSmart: false)
            return
        }

        // Query window: from bedtime up to hard wake time
        let windowStart = Calendar.current.date(
            byAdding: .minute,
            value: -windowMinutes,
            to: hardWakeTime
        ) ?? hardWakeTime

        let predicate = HKQuery.predicateForSamples(
            withStart: windowStart,
            end:       hardWakeTime,
            options:   .strictEndDate
        )
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate,
                                              ascending: false)

        let query = HKSampleQuery(
            sampleType:   sleepType,
            predicate:    predicate,
            limit:        HKObjectQueryNoLimit,
            sortDescriptors: [sortDescriptor]
        ) { [weak self] _, samples, error in
            guard let self else { return }

            if let error {
                print("HealthKit sleep query error: \(error)")
                self.scheduleAlarmNotification(at: hardWakeTime, isSmart: false)
                return
            }

            // Cast to HKCategorySample so we can inspect the sleep-stage value
            let sleepSamples = (samples as? [HKCategorySample]) ?? []

            // iOS 16+ provides HKCategoryValueSleepAnalysis with .asleepCore / .asleepREM / .inBed
            // We treat .inBed and (if available) .asleepCore as "light sleep"
            let lightSleepMoment = self.findLightSleepMoment(
                in:          sleepSamples,
                windowStart: windowStart,
                windowEnd:   hardWakeTime
            )

            let fireDate = lightSleepMoment ?? hardWakeTime
            self.scheduleAlarmNotification(at: fireDate, isSmart: lightSleepMoment != nil)
        }

        healthStore.execute(query)
    }

    // Walks through sleep samples and returns the start of the first light-sleep
    // segment inside the window (ascending by start date so we pick the earliest).
    private func findLightSleepMoment(in samples: [HKCategorySample],
                                       windowStart: Date,
                                       windowEnd:   Date) -> Date? {
        // Sort ascending so we walk from early → late inside the window
        let sorted = samples
            .filter { $0.startDate >= windowStart && $0.startDate <= windowEnd }
            .sorted { $0.startDate < $1.startDate }

        for sample in sorted {
            let value = sample.value
            // HKCategoryValueSleepAnalysis raw values:
            //   0 = inBed  (lightest — good wake target)
            //   1 = asleepUnspecified
            //   2 = awake
            //   3 = asleepCore  (light NREM — ideal)
            //   4 = asleepDeep
            //   5 = asleepREM
            let lightStages: Set<Int> = [0, 2, 3]   // inBed, awake, asleepCore
            if lightStages.contains(value) {
                return sample.startDate
            }
        }
        return nil   // No light-sleep moment found → caller will use hard wake time
    }

    // MARK: - Notification Scheduling

    /// Schedules the local notification that will show the alarm UI.
    /// - Parameters:
    ///   - fireDate:  The exact Date the notification should fire.
    ///   - isSmart:   Whether this was chosen via sleep-phase logic (used in subtitle).
    private func scheduleAlarmNotification(at fireDate: Date, isSmart: Bool) {
        let content = UNMutableNotificationContent()
        content.title            = "Rise & Shine ☀️"
        content.subtitle         = isSmart ? "Smart alarm — light sleep detected" : "Your alarm"
        content.body             = "Tap to start your morning ritual."
        content.sound            = alarmSound()
        content.interruptionLevel = .timeSensitive   // shows on locked screen, cuts through Focus

        // categoryIdentifier links to the custom full-screen extension UI
        content.categoryIdentifier = "WAKEWELL_ALARM"

        // Pass wake time so the alarm screen can display it
        content.userInfo = [
            "wakeTime":   ISO8601DateFormatter().string(from: fireDate),
            "isSmart":    isSmart
        ]

        // Fire at exact calendar date
        let components = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute, .second],
            from: fireDate
        )
        let trigger = UNCalendarNotificationTrigger(dateMatching: components,
                                                    repeats: false)

        let request = UNNotificationRequest(identifier: "wakewell.alarm",
                                            content:    content,
                                            trigger:    trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error {
                print("Failed to schedule alarm: \(error)")
            } else {
                print("✅ Alarm scheduled for \(fireDate)")
            }
        }

        // Register action buttons (shown on the alarm ringing screen and notification banner)
        registerNotificationCategory()
    }

    /// Returns a UNNotificationSound.
    /// Add your custom alarm audio file (e.g. "alarm_chime.caf") to the app bundle.
    private func alarmSound() -> UNNotificationSound {
        // Use a custom sound if you have one; otherwise falls back to default
        if Bundle.main.url(forResource: "alarm_chime", withExtension: "caf") != nil {
            return UNNotificationSound(named: UNNotificationSoundName("alarm_chime.caf"))
        }
        // UNNotificationSound.defaultCritical plays even in silent mode
        return UNNotificationSound.defaultCritical
    }

    /// Registers the "WAKEWELL_ALARM" category with slide-to-stop action.
    private func registerNotificationCategory() {
        // The "Stop" action shown on the lock screen / notification banner
        let stopAction = UNNotificationAction(
            identifier: "STOP_ALARM",
            title:      "Stop Alarm",
            options:    [.foreground]     // .foreground brings the app to front
        )

        // The "Start Ritual" action shown after stopping
        let startAction = UNNotificationAction(
            identifier: "START_RITUAL",
            title:      "▶ Start Morning Ritual",
            options:    [.foreground]
        )

        let category = UNNotificationCategory(
            identifier:               "WAKEWELL_ALARM",
            actions:                  [stopAction, startAction],
            intentIdentifiers:        [],
            hiddenPreviewsBodyPlaceholder: "Alarm",
            options:                  [.customDismissAction,
                                       .allowAnnouncement]
        )

        UNUserNotificationCenter.current().setNotificationCategories([category])
    }

    // MARK: - Helpers

    private func windowToMinutes(_ window: String) -> Int {
        switch window {
        case "15 min": return 15
        case "45 min": return 45
        default:       return 30
        }
    }

    private func showAlarmSetAlert(message: String) {
        let alert = UIAlertController(title: "Alarm Set",
                                      message: message,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            self.dismiss(animated: true)
        })
        present(alert, animated: true)
    }

    // MARK: - TableView

    override func tableView(_ tableView: UITableView,
                            heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 { return 454 }
        if indexPath.section == 1 && wakeUpOptionRows.contains(indexPath.row) {
            return wakeUpToggle.isOn ? UITableView.automaticDimension : 0
        }
        if indexPath.section == 2 && bedtimeOptionRows.contains(indexPath.row) {
            return bedTimeToggle.isOn ? UITableView.automaticDimension : 0
        }
        return UITableView.automaticDimension
    }

    // MARK: - SoundPickerDelegate

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationVC = segue.destination as? SoundPickerViewController {
            destinationVC.delegate = self
            if let indexPath = tableView.indexPathForSelectedRow {
                activeSection = indexPath.section
            }
            let selection = activeSection == 1 ? wakeUpSoundSelection : bedtimeSoundSelection
            destinationVC.selectedSoundName = selection.sound
            destinationVC.selectedHaptic = selection.haptic
        }
    }

    func didSelectSound(_ name: String, haptic: String) {
        if activeSection == 1 {
            wakeUpSoundSelection = (name, haptic)
        } else {
            bedtimeSoundSelection = (name, haptic)
        }
        updateSoundLabels()
    }

    override func tableView(_ tableView: UITableView,
                            willDisplayHeaderView view: UIView,
                            forSection section: Int) {
        guard let header = view as? UITableViewHeaderFooterView else { return }
        header.tintColor = WakeWellTheme.background
        header.textLabel?.textColor = WakeWellTheme.labelSecondary
    }

    override func tableView(_ tableView: UITableView,
                            willDisplay cell: UITableViewCell,
                            forRowAt indexPath: IndexPath) {
        if indexPath.section == 1 && wakeUpOptionRows.contains(indexPath.row) {
            cell.isHidden = !wakeUpToggle.isOn
            cell.clipsToBounds = true
        } else if indexPath.section == 2 && bedtimeOptionRows.contains(indexPath.row) {
            cell.isHidden = !bedTimeToggle.isOn
            cell.clipsToBounds = true
        } else {
            cell.isHidden = false
        }

        cell.backgroundColor = WakeWellTheme.cardBackground
        cell.contentView.backgroundColor = WakeWellTheme.cardBackground
        cell.tintColor = WakeWellTheme.accentPurple
        cell.textLabel?.textColor = WakeWellTheme.labelPrimary
        cell.detailTextLabel?.textColor = WakeWellTheme.labelSecondary
        cell.selectionStyle = .none
        let selectedView = UIView()
        selectedView.backgroundColor = WakeWellTheme.cardBackground
        cell.selectedBackgroundView = selectedView
        cell.accessoryView?.tintColor = WakeWellTheme.labelSecondary
        applyTheme(to: cell.contentView)
    }

    private func applyTheme(to view: UIView) {
        for subview in view.subviews {
            switch subview {
            case let label as UILabel:
                label.textColor = WakeWellTheme.labelPrimary
            case let button as UIButton:
                button.setTitleColor(WakeWellTheme.accentPurple, for: .normal)
                button.tintColor = WakeWellTheme.accentPurple
            case let imageView as UIImageView:
                imageView.tintColor = WakeWellTheme.labelSecondary
            case let picker as CircularTimePicker:
                picker.applyTheme()
            case let container as UIView:
                if container.backgroundColor != .clear {
                    container.backgroundColor = WakeWellTheme.cardBackground
                }
            default:
                break
            }

            if subview !== selectedSoundLabel && subview !== selectedSoundLabel2 {
                applyTheme(to: subview)
            }
        }
    }

    private func makeSliderThumbImage() -> UIImage? {
        let size = CGSize(width: 22, height: 22)
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { context in
            let rect = CGRect(origin: .zero, size: size)
            context.cgContext.setFillColor(WakeWellTheme.accentGold.cgColor)
            context.cgContext.fillEllipse(in: rect)
        }
    }

    private func makeSliderTrackImage(color: UIColor) -> UIImage? {
        let size = CGSize(width: 8, height: 8)
        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { context in
            let rect = CGRect(origin: .zero, size: size)
            let path = UIBezierPath(roundedRect: rect, cornerRadius: size.height / 2)
            color.setFill()
            path.fill()
        }
        let inset = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 4)
        return image.resizableImage(withCapInsets: inset, resizingMode: .stretch)
    }
}

// Shared notification name used by AlarmOptionViewController (sender)
// and AlarmCollectionViewCell / HomeViewController (observers).
extension Notification.Name {
    static let alarmTimeDidChange = Notification.Name("wakewell.alarmTimeDidChange")
}
