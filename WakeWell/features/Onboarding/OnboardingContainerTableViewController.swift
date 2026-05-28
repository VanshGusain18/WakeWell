// OnboardingContainerTableViewController.swift
// SetSail
//
// Hosts the onboarding page carousel in a UITableViewController.
// Fully code-driven — no XIBs needed.

import UIKit

// MARK: - Section model

private enum OnboardingSection: Int, CaseIterable {
    case carousel   // full-height cell embedding the PageViewController
    case controls   // page control dots + Next / Skip
}

// MARK: - View Controller

final class OnboardingContainerTableViewController: UITableViewController {

    // MARK: Private state

    private var pageVC: UIPageViewController!
    private var currentIndex = 0
    private let brandHeaderView = UIView()
    private let brandPill = UIView()
    private let brandDot = UIView()
    private let brandLabel = UILabel()

    private let pages: [OnboardingPage] = [
        OnboardingPage(
            eyebrow:     "Better sleep awareness",
            title:       "Wake up at the right moment.",
            subtitle:    "SetSail helps you see your sleep rhythm clearly so mornings feel calmer, not rushed.",
            accentColor: WakeWellTheme.accentPurple,
            hero:        .init(kind: .logo, accentColor: WakeWellTheme.accentPurple),
            highlights:  ["Sleep rhythm", "Gentle wake timing"]
        ),
        OnboardingPage(
            eyebrow:     "Smart wake window",
            title:       "Understand when your body is ready.",
            subtitle:    "We learn your ideal wake window so the alarm feels less abrupt and more human.",
            accentColor: WakeWellTheme.accentGold,
            hero:        .init(kind: .symbol("alarm.waves.left.and.right.fill"), accentColor: WakeWellTheme.accentGold),
            highlights:  ["Wake window", "Calm alarm"]
        ),
        OnboardingPage(
            eyebrow:     "Apple Watch + live tracking",
            title:       "Your watch becomes the sleep sensor.",
            subtitle:    "During the alarm window, SetSail reads the signals that matter for a gentler wake-up.",
            accentColor: WakeWellTheme.accentPurple,
            hero:        .init(kind: .symbol("applewatch"), accentColor: WakeWellTheme.accentPurple),
            highlights:  ["Live tracking", "Only when needed"]
        ),
        OnboardingPage(
            eyebrow:     "Recovery insights",
            title:       "Turn sleep into useful guidance.",
            subtitle:    "See grogginess, sleep debt, and morning notes turn into calm, trend-aware coaching.",
            accentColor: WakeWellTheme.accentGold,
            hero:        .init(kind: .symbol("chart.line.uptrend.xyaxis"), accentColor: WakeWellTheme.accentGold),
            highlights:  ["Recovery insights", "Morning notes"]
        ),
        OnboardingPage(
            eyebrow:     "Final step",
            title:       "Let’s improve your mornings.",
            subtitle:    "We’ll ask for HealthKit and notifications only when they unlock the experience you just saw.",
            accentColor: WakeWellTheme.accentPurple,
            hero:        .init(kind: .symbol("sparkles"), accentColor: WakeWellTheme.accentPurple),
            highlights:  ["HealthKit permissions", "Trustworthy setup"]
        )
    ]

    private weak var carouselCell: CarouselCell?
    private weak var controlsCell: ControlsCell?

    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        applyGradientBackground()
        setupTableView()
        setupBrandHeader()
        buildPageViewController()
        showPage(at: 0, animated: false)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if let grad = view.layer.sublayers?.first as? CAGradientLayer {
            grad.frame = view.bounds
        }
    }

    // MARK: Setup

    private func applyGradientBackground() {
        // Light gradient using WakeWellTheme light palette
        let grad = CAGradientLayer()
        grad.frame  = view.bounds
        grad.colors = [
            UIColor(hex: "#F7F6FF").cgColor,
            UIColor(hex: "#F1EEFF").cgColor,
            UIColor(hex: "#E8E4FF").cgColor
        ]
        grad.locations = [0.0, 0.5, 1.0]
        grad.startPoint = CGPoint(x: 0.5, y: 0)
        grad.endPoint   = CGPoint(x: 0.5, y: 1)
        view.layer.insertSublayer(grad, at: 0)
        tableView.backgroundColor = .clear
        view.backgroundColor = WakeWellTheme.background
    }

    private func setupTableView() {
        tableView.register(CarouselCell.self,  forCellReuseIdentifier: CarouselCell.reuseID)
        tableView.register(ControlsCell.self,  forCellReuseIdentifier: ControlsCell.reuseID)
        tableView.separatorStyle  = .none
        tableView.isScrollEnabled = false
        tableView.allowsSelection = false
        tableView.contentInset    = .zero
        tableView.showsVerticalScrollIndicator = false
    }

    private func setupBrandHeader() {
        brandHeaderView.translatesAutoresizingMaskIntoConstraints = false
        brandHeaderView.backgroundColor = .clear

        brandPill.translatesAutoresizingMaskIntoConstraints = false
        brandPill.backgroundColor = WakeWellTheme.cardBackground.withAlphaComponent(0.52)
        brandPill.layer.cornerRadius = 17
        brandPill.layer.borderWidth = 1
        brandPill.layer.borderColor = WakeWellTheme.border.cgColor

        brandDot.translatesAutoresizingMaskIntoConstraints = false
        brandDot.backgroundColor = WakeWellTheme.accentPurple
        brandDot.layer.cornerRadius = 4.5

        brandLabel.translatesAutoresizingMaskIntoConstraints = false
        brandLabel.text = "SetSail"
        brandLabel.font = .systemFont(ofSize: 12, weight: .semibold)
        brandLabel.textColor = WakeWellTheme.accentPurple

        view.addSubview(brandHeaderView)
        brandHeaderView.addSubview(brandPill)
        brandPill.addSubview(brandDot)
        brandPill.addSubview(brandLabel)

        NSLayoutConstraint.activate([
            brandHeaderView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            brandHeaderView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 26),
            brandHeaderView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -26),
            brandHeaderView.heightAnchor.constraint(equalToConstant: 34),

            brandPill.leadingAnchor.constraint(equalTo: brandHeaderView.leadingAnchor),
            brandPill.topAnchor.constraint(equalTo: brandHeaderView.topAnchor),
            brandPill.heightAnchor.constraint(equalToConstant: 34),

            brandDot.leadingAnchor.constraint(equalTo: brandPill.leadingAnchor, constant: 14),
            brandDot.centerYAnchor.constraint(equalTo: brandPill.centerYAnchor),
            brandDot.widthAnchor.constraint(equalToConstant: 9),
            brandDot.heightAnchor.constraint(equalToConstant: 9),

            brandLabel.leadingAnchor.constraint(equalTo: brandDot.trailingAnchor, constant: 8),
            brandLabel.trailingAnchor.constraint(equalTo: brandPill.trailingAnchor, constant: -14),
            brandLabel.centerYAnchor.constraint(equalTo: brandPill.centerYAnchor)
        ])
    }

    private func buildPageViewController() {
        pageVC = UIPageViewController(transitionStyle: .scroll,
                                      navigationOrientation: .horizontal)
        pageVC.dataSource = self
        pageVC.delegate   = self
        addChild(pageVC)
        pageVC.didMove(toParent: self)
        pageVC.view.backgroundColor = .clear
    }

    // MARK: UITableViewDataSource

    override func numberOfSections(in tableView: UITableView) -> Int {
        OnboardingSection.allCases.count
    }

    override func tableView(_ tableView: UITableView,
                            numberOfRowsInSection section: Int) -> Int { 1 }

    override func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch OnboardingSection(rawValue: indexPath.section)! {
        case .carousel:
            let cell = tableView.dequeueReusableCell(
                withIdentifier: CarouselCell.reuseID, for: indexPath) as! CarouselCell
            cell.embed(pageVC: pageVC, in: self)
            carouselCell = cell
            return cell
        case .controls:
            let cell = tableView.dequeueReusableCell(
                withIdentifier: ControlsCell.reuseID, for: indexPath) as! ControlsCell
            cell.configure(pageCount: pages.count, currentPage: currentIndex)
            cell.onNext = { [weak self] in self?.nextTapped() }
            cell.onSkip = { [weak self] in self?.navigateToLogin() }
            controlsCell = cell
            return cell
        }
    }

    // MARK: UITableViewDelegate

    override func tableView(_ tableView: UITableView,
                            heightForRowAt indexPath: IndexPath) -> CGFloat {
        let total = tableView.bounds.height
        switch OnboardingSection(rawValue: indexPath.section)! {
        case .carousel: return total * 0.78
        case .controls: return total * 0.22
        }
    }

    override func tableView(_ tableView: UITableView,
                            heightForHeaderInSection section: Int) -> CGFloat { .leastNormalMagnitude }
    override func tableView(_ tableView: UITableView,
                            heightForFooterInSection section: Int) -> CGFloat { .leastNormalMagnitude }

    // MARK: Actions

    private func nextTapped() {
        let next = currentIndex + 1
        if next < pages.count {
            showPage(at: next, animated: true)
        } else {
            navigateToLogin()
        }
    }

    // MARK: Page management

    private func showPage(at index: Int, animated: Bool) {
        guard index < pages.count else { return }
        let direction: UIPageViewController.NavigationDirection = index > currentIndex ? .forward : .reverse
        currentIndex = index
        pageVC.setViewControllers([makePageVC(index: index)],
                                   direction: direction, animated: animated)
        let isLast = index == pages.count - 1
        controlsCell?.update(currentPage: index, isLast: isLast)
    }

    private func makePageVC(index: Int) -> OnboardingPageTableViewController {
        let vc = OnboardingPageTableViewController()
        vc.page      = pages[index]
        vc.pageIndex = index
        return vc
    }

    // MARK: Navigation

    private func navigateToLogin() {
        let loginVC = LoginTableViewController()
        loginVC.modalPresentationStyle = .fullScreen
        loginVC.modalTransitionStyle   = .crossDissolve
        present(loginVC, animated: true)
    }
}

// MARK: - UIPageViewControllerDataSource

extension OnboardingContainerTableViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let pvc = viewController as? OnboardingPageTableViewController,
              pvc.pageIndex > 0 else { return nil }
        return makePageVC(index: pvc.pageIndex - 1)
    }

    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let pvc = viewController as? OnboardingPageTableViewController,
              pvc.pageIndex < pages.count - 1 else { return nil }
        return makePageVC(index: pvc.pageIndex + 1)
    }
}

// MARK: - UIPageViewControllerDelegate

extension OnboardingContainerTableViewController: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController,
                            didFinishAnimating finished: Bool,
                            previousViewControllers: [UIViewController],
                            transitionCompleted completed: Bool) {
        guard completed,
              let pvc = pageViewController.viewControllers?.first as? OnboardingPageTableViewController
        else { return }
        currentIndex = pvc.pageIndex
        let isLast = currentIndex == pages.count - 1
        controlsCell?.update(currentPage: currentIndex, isLast: isLast)
    }
}

// MARK: - CarouselCell

private final class CarouselCell: UITableViewCell {
    static let reuseID = "CarouselCell"
    private var isEmbedded = false

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor             = .clear
        contentView.backgroundColor = .clear
        selectionStyle              = .none
    }
    required init?(coder: NSCoder) { fatalError() }

    func embed(pageVC: UIPageViewController, in parent: UIViewController) {
        guard !isEmbedded else { return }
        isEmbedded = true
        pageVC.view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(pageVC.view)
        NSLayoutConstraint.activate([
            pageVC.view.topAnchor.constraint(equalTo: contentView.topAnchor),
            pageVC.view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            pageVC.view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            pageVC.view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
    }
}

// MARK: - ControlsCell

private final class ControlsCell: UITableViewCell {
    static let reuseID = "ControlsCell"

    var onNext: (() -> Void)?
    var onSkip: (() -> Void)?

    private let progressLabel = UILabel()
    private let pageControl = UIPageControl()
    private let nextButton = UIButton(type: .system)
    private let skipButton = UIButton(type: .system)

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    required init?(coder: NSCoder) { fatalError() }

    private func setup() {
        backgroundColor             = .clear
        contentView.backgroundColor = .clear
        selectionStyle              = .none

        progressLabel.translatesAutoresizingMaskIntoConstraints = false
        progressLabel.textAlignment = .center
        progressLabel.textColor = WakeWellTheme.labelTertiary
        progressLabel.font = .systemFont(ofSize: 12, weight: .semibold)
        progressLabel.text = "Ready to begin"

        // Page dots — visible on light background
        pageControl.pageIndicatorTintColor        = WakeWellTheme.accentPurple.withAlphaComponent(0.28)
        pageControl.currentPageIndicatorTintColor = WakeWellTheme.accentPurple
        if #available(iOS 14.0, *) {
            pageControl.backgroundStyle = .minimal
        }
        pageControl.translatesAutoresizingMaskIntoConstraints = false

        // Next button — purple fill
        nextButton.backgroundColor      = WakeWellTheme.accentPurple
        nextButton.setTitleColor(.white, for: .normal)
        nextButton.titleLabel?.font     = .systemFont(ofSize: 16, weight: .semibold)
        nextButton.layer.cornerRadius   = 26
        nextButton.clipsToBounds        = true
        nextButton.setTitle("Next", for: .normal)
        nextButton.translatesAutoresizingMaskIntoConstraints = false
        nextButton.addTarget(self, action: #selector(nextTapped), for: .touchUpInside)
        nextButton.layer.shadowColor = WakeWellTheme.shadowColor.cgColor
        nextButton.layer.shadowOpacity = 0.16
        nextButton.layer.shadowRadius = 12
        nextButton.layer.shadowOffset = CGSize(width: 0, height: 8)

        // Skip button
        skipButton.setTitle("Skip", for: .normal)
        skipButton.setTitleColor(WakeWellTheme.labelSecondary, for: .normal)
        skipButton.titleLabel?.font     = .systemFont(ofSize: 14, weight: .medium)
        skipButton.translatesAutoresizingMaskIntoConstraints = false
        skipButton.addTarget(self, action: #selector(skipTapped), for: .touchUpInside)

        contentView.addSubview(progressLabel)
        contentView.addSubview(pageControl)
        contentView.addSubview(nextButton)
        contentView.addSubview(skipButton)

        NSLayoutConstraint.activate([
            progressLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            progressLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),

            pageControl.topAnchor.constraint(equalTo: progressLabel.bottomAnchor, constant: 6),
            pageControl.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),

            nextButton.topAnchor.constraint(equalTo: pageControl.bottomAnchor, constant: 14),
            nextButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 28),
            nextButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -28),
            nextButton.heightAnchor.constraint(equalToConstant: 54),

            skipButton.topAnchor.constraint(equalTo: nextButton.bottomAnchor, constant: 10),
            skipButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            skipButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
    }

    func configure(pageCount: Int, currentPage: Int) {
        pageControl.numberOfPages = pageCount
        pageControl.currentPage   = currentPage
        progressLabel.text = "Step \(currentPage + 1) of \(pageCount)"
    }

    func update(currentPage: Int, isLast: Bool) {
        pageControl.currentPage = currentPage
        progressLabel.text = isLast ? "Final step" : "Step \(currentPage + 1) of \(pageControl.numberOfPages)"
        let title = isLast ? "Start Sleeping Better" : "Next"
        nextButton.setTitle(title, for: .normal)
        nextButton.backgroundColor = isLast ? WakeWellTheme.accentGold : WakeWellTheme.accentPurple
        UIView.animate(withDuration: 0.2) {
            self.skipButton.alpha = isLast ? 0 : 1
        }
    }

    @objc private func nextTapped() { onNext?() }
    @objc private func skipTapped() { onSkip?() }
}
