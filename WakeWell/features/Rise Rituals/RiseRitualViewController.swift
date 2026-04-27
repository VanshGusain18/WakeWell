//
//  RiseRitualViewController.swift
//  WakeWell
//
//  Created by geu on 27/04/26.
//

import UIKit

class RiseRitualViewController: UIViewController {
    private var todayActivity: Activity = RiseRitualViewController.pickTodayActivity()
    private var skipCount = 0

    // MARK: - UI
    private let scrollView      = UIScrollView()
    private let contentStack    = UIStackView()
    private let headerLabel     = UILabel()
    private let subheaderLabel  = UILabel()
    private let cardView        = UIView()
    private let categoryPill    = UILabel()
    private let activityImage   = UIImageView()
    private let titleLabel      = UILabel()
    private let descLabel       = UILabel()
    private let doButton        = UIButton(type: .system)
    private let shuffleButton   = UIButton(type: .system)
    private let skipButton      = UIButton(type: .system)
    private let myRitualsButton = UIButton(type: .system)

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = WakeWellTheme.background
        navigationItem.title = "Rise Ritual"
        navigationItem.largeTitleDisplayMode = .always
        buildUI()
        configureCard(with: todayActivity, animated: false)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Reload in case user added a custom ritual
        loadActivities()
        view.backgroundColor = WakeWellTheme.background
    }

    // MARK: - Layout

    private func buildUI() {
        // Scroll container
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        view.addSubview(scrollView)

        contentStack.axis           = .vertical
        contentStack.spacing        = 20
        contentStack.alignment      = .fill
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentStack)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentStack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 20),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor, constant: 20),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor, constant: -20),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -32)
        ])

        // Header
        headerLabel.text            = "Today's Activity"
        headerLabel.font            = .boldSystemFont(ofSize: 28)
        headerLabel.textColor       = WakeWellTheme.labelPrimary
        contentStack.addArrangedSubview(headerLabel)

        subheaderLabel.text         = "A science-backed activity to help you wake up refreshed."
        subheaderLabel.font         = .systemFont(ofSize: 15, weight: .regular)
        subheaderLabel.textColor    = WakeWellTheme.labelSecondary
        subheaderLabel.numberOfLines = 0
        contentStack.addArrangedSubview(subheaderLabel)

        // Main card
        buildCard()
        contentStack.addArrangedSubview(cardView)

        // Action buttons row
        let btnRow = buildActionRow()
        contentStack.addArrangedSubview(btnRow)

        // My Rituals button
        buildMyRitualsButton()
        contentStack.addArrangedSubview(myRitualsButton)
    }

    private func buildCard() {
        cardView.backgroundColor        = WakeWellTheme.cardBackground
        cardView.layer.cornerRadius     = 28
        cardView.layer.masksToBounds    = false
        cardView.layer.shadowColor      = WakeWellTheme.shadowColor.cgColor
        cardView.layer.shadowOpacity    = WakeWellTheme.shadowOpacity
        cardView.layer.shadowRadius     = WakeWellTheme.shadowRadius
        cardView.layer.shadowOffset     = WakeWellTheme.shadowOffset
        cardView.translatesAutoresizingMaskIntoConstraints = false

        // Category pill
        categoryPill.font               = .systemFont(ofSize: 11, weight: .semibold)
        categoryPill.textColor          = .white
        categoryPill.backgroundColor    = WakeWellTheme.accentGold
        categoryPill.layer.cornerRadius = 10
        categoryPill.clipsToBounds      = true
        categoryPill.textAlignment      = .center
        categoryPill.translatesAutoresizingMaskIntoConstraints = false

        // Image
        activityImage.contentMode           = .scaleAspectFill
        activityImage.clipsToBounds         = true
        activityImage.layer.cornerRadius    = 20
        activityImage.backgroundColor       = WakeWellTheme.cardElevated
        activityImage.translatesAutoresizingMaskIntoConstraints = false

        // Title
        titleLabel.font             = .boldSystemFont(ofSize: 24)
        titleLabel.textColor        = WakeWellTheme.labelPrimary
        titleLabel.numberOfLines    = 2
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.minimumScaleFactor = 0.8
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        // Description
        descLabel.font              = .systemFont(ofSize: 15, weight: .regular)
        descLabel.textColor         = WakeWellTheme.labelSecondary
        descLabel.numberOfLines     = 0
        descLabel.translatesAutoresizingMaskIntoConstraints = false

        // Steps header
        let stepsHeader = UILabel()
        stepsHeader.text        = "How to do it"
        stepsHeader.font        = .systemFont(ofSize: 16, weight: .semibold)
        stepsHeader.textColor   = WakeWellTheme.labelPrimary
        stepsHeader.translatesAutoresizingMaskIntoConstraints = false

        // Build steps stack inside card (we'll repopulate in configureCard)
        let stepsStack = UIStackView()
        stepsStack.axis         = .vertical
        stepsStack.spacing      = 10
        stepsStack.tag          = 99   // tag so we can find it later
        stepsStack.translatesAutoresizingMaskIntoConstraints = false

        // CTA "Do it" button inside card
        doButton.setTitle("Do It  →", for: .normal)
        doButton.setTitleColor(.white, for: .normal)
        doButton.titleLabel?.font       = .boldSystemFont(ofSize: 17)
        doButton.backgroundColor        = WakeWellTheme.accentGold
        doButton.layer.cornerRadius     = 18
        doButton.clipsToBounds          = true
        doButton.addTarget(self, action: #selector(doItTapped), for: .touchUpInside)
        doButton.translatesAutoresizingMaskIntoConstraints = false

        cardView.addSubview(categoryPill)
        cardView.addSubview(activityImage)
        cardView.addSubview(titleLabel)
        cardView.addSubview(descLabel)
        cardView.addSubview(stepsHeader)
        cardView.addSubview(stepsStack)
        cardView.addSubview(doButton)

        NSLayoutConstraint.activate([
            categoryPill.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 20),
            categoryPill.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 20),
            categoryPill.heightAnchor.constraint(equalToConstant: 24),
            categoryPill.widthAnchor.constraint(greaterThanOrEqualToConstant: 70),

            activityImage.topAnchor.constraint(equalTo: categoryPill.bottomAnchor, constant: 14),
            activityImage.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 20),
            activityImage.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -20),
            activityImage.heightAnchor.constraint(equalToConstant: 180),

            titleLabel.topAnchor.constraint(equalTo: activityImage.bottomAnchor, constant: 18),
            titleLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -20),

            descLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            descLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 20),
            descLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -20),

            stepsHeader.topAnchor.constraint(equalTo: descLabel.bottomAnchor, constant: 20),
            stepsHeader.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 20),
            stepsHeader.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -20),

            stepsStack.topAnchor.constraint(equalTo: stepsHeader.bottomAnchor, constant: 10),
            stepsStack.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 20),
            stepsStack.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -20),

            doButton.topAnchor.constraint(equalTo: stepsStack.bottomAnchor, constant: 24),
            doButton.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 20),
            doButton.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -20),
            doButton.heightAnchor.constraint(equalToConstant: 54),
            doButton.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -20)
        ])
    }

    private func buildActionRow() -> UIStackView {
        // Shuffle button
        let config = UIImage.SymbolConfiguration(pointSize: 16, weight: .semibold)
        shuffleButton.setImage(UIImage(systemName: "shuffle", withConfiguration: config), for: .normal)
        shuffleButton.setTitle("  Shuffle", for: .normal)
        shuffleButton.tintColor         = WakeWellTheme.accentPurple
        shuffleButton.setTitleColor(WakeWellTheme.accentPurple, for: .normal)
        shuffleButton.titleLabel?.font  = .systemFont(ofSize: 15, weight: .semibold)
        shuffleButton.backgroundColor   = WakeWellTheme.cardBackground
        shuffleButton.layer.cornerRadius = 16
        shuffleButton.layer.borderWidth  = 1
        shuffleButton.layer.borderColor  = WakeWellTheme.border.cgColor
        shuffleButton.clipsToBounds      = true
        shuffleButton.addTarget(self, action: #selector(shuffleTapped), for: .touchUpInside)
        shuffleButton.translatesAutoresizingMaskIntoConstraints = false
        shuffleButton.heightAnchor.constraint(equalToConstant: 50).isActive = true

        // Skip button
        skipButton.setTitle("Skip for today", for: .normal)
        skipButton.setTitleColor(WakeWellTheme.labelSecondary, for: .normal)
        skipButton.titleLabel?.font     = .systemFont(ofSize: 15, weight: .medium)
        skipButton.backgroundColor      = WakeWellTheme.cardBackground
        skipButton.layer.cornerRadius   = 16
        skipButton.layer.borderWidth    = 1
        skipButton.layer.borderColor    = WakeWellTheme.border.cgColor
        skipButton.clipsToBounds        = true
        skipButton.addTarget(self, action: #selector(skipTapped), for: .touchUpInside)
        skipButton.translatesAutoresizingMaskIntoConstraints = false
        skipButton.heightAnchor.constraint(equalToConstant: 50).isActive = true

        let row = UIStackView(arrangedSubviews: [shuffleButton, skipButton])
        row.axis         = .horizontal
        row.spacing      = 12
        row.distribution = .fillEqually
        return row
    }

    private func buildMyRitualsButton() {
        myRitualsButton.setTitle("My Custom Rituals", for: .normal)
        myRitualsButton.setTitleColor(WakeWellTheme.accentPurple, for: .normal)
        myRitualsButton.titleLabel?.font    = .systemFont(ofSize: 15, weight: .semibold)
        myRitualsButton.backgroundColor     = WakeWellTheme.purpleTint
        myRitualsButton.layer.cornerRadius  = 16
        myRitualsButton.clipsToBounds       = true
        myRitualsButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        myRitualsButton.addTarget(self, action: #selector(myRitualsTapped), for: .touchUpInside)
    }

    // MARK: - Configure card content

    private func configureCard(with activity: Activity, animated: Bool) {
        let work = {
            self.categoryPill.text = "  \(activity.category)  "
            self.titleLabel.text   = activity.title
            self.descLabel.text    = activity.description

            // Image
            if let img = UIImage(named: activity.imageName) {
                self.activityImage.image    = img
                self.activityImage.isHidden = false
            } else {
                self.activityImage.isHidden = true
            }

            // Rebuild steps
            if let stepsStack = self.cardView.viewWithTag(99) as? UIStackView {
                stepsStack.arrangedSubviews.forEach {
                    stepsStack.removeArrangedSubview($0); $0.removeFromSuperview()
                }
                for (i, step) in activity.steps.enumerated() {
                    let row = self.makeStepRow(index: i + 1, text: step)
                    stepsStack.addArrangedSubview(row)
                }
            }
        }

        if animated {
            UIView.animate(withDuration: 0.15, animations: {
                self.cardView.alpha = 0
                self.cardView.transform = CGAffineTransform(translationX: 40, y: 0)
            }, completion: { _ in
                work()
                UIView.animate(withDuration: 0.3, delay: 0,
                               usingSpringWithDamping: 0.8, initialSpringVelocity: 0.4) {
                    self.cardView.alpha     = 1
                    self.cardView.transform = .identity
                }
            })
        } else {
            work()
        }
    }

    private func makeStepRow(index: Int, text: String) -> UIView {
        let badge = UILabel()
        badge.text              = "\(index)"
        badge.font              = .boldSystemFont(ofSize: 12)
        badge.textColor         = .white
        badge.textAlignment     = .center
        badge.backgroundColor   = WakeWellTheme.accentPurple
        badge.layer.cornerRadius = 12
        badge.clipsToBounds     = true
        badge.translatesAutoresizingMaskIntoConstraints = false
        badge.widthAnchor.constraint(equalToConstant: 24).isActive = true
        badge.heightAnchor.constraint(equalToConstant: 24).isActive = true

        let text2 = UILabel()
        text2.text          = text
        text2.font          = .systemFont(ofSize: 14, weight: .regular)
        text2.textColor     = WakeWellTheme.labelSecondary
        text2.numberOfLines = 0
        text2.translatesAutoresizingMaskIntoConstraints = false

        let row = UIStackView(arrangedSubviews: [badge, text2])
        row.axis        = .horizontal
        row.spacing     = 10
        row.alignment   = .top
        return row
    }

    // MARK: - Day-based random pick

    static func pickTodayActivity() -> Activity {
        loadActivities()
        let pool = activities.isEmpty ? activities : activities
        // Use the day-of-year as a stable seed so the card stays the same all day
        let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 1
        let index = dayOfYear % max(pool.count, 1)
        return pool[index]
    }

    // MARK: - Actions

    @objc private func doItTapped() {
        startTodayActivity()
    }

    /// Called externally from Home tab "Start Ritual" button.
    func startTodayActivity() {
        let vc = ActivityRunnerFactory.makeViewController(
            for: todayActivity,
            routineQueue: [todayActivity],
            currentIndex: 0
        )
        navigationController?.pushViewController(vc, animated: true)
    }

    @objc private func shuffleTapped() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        skipCount += 1
        // Pick a different activity from the current one
        let pool = activities.filter { $0.id != todayActivity.id }
        guard !pool.isEmpty else { return }
        let newActivity = pool[skipCount % pool.count]
        todayActivity = newActivity
        configureCard(with: todayActivity, animated: true)
    }

    @objc private func skipTapped() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        // Show a brief confirmation
        let alert = UIAlertController(
            title: "Activity skipped",
            message: "A new activity will be waiting for you tomorrow. Come back refreshed! 🌅",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    @objc private func myRitualsTapped() {
        let vc = MyRitualsViewController()
        navigationController?.pushViewController(vc, animated: true)
    }

}
