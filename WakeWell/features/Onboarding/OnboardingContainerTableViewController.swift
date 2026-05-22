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

    private let pages: [OnboardingPage] = [
        OnboardingPage(
            sfSymbol:    "sailboat.fill",
            title:       "Welcome to SetSail",
            subtitle:    "Set your wake window, sleep with Apple Watch, and wake at the right moment.",
            accentColor: UIColor(hex: "#5E9BF0")
        ),
        OnboardingPage(
            sfSymbol:    "waveform.path.ecg",
            title:       "Sleep Signals",
            subtitle:    "SetSail reads heart rate and movement only during your alarm window.",
            accentColor: WakeWellTheme.accentGold
        ),
        OnboardingPage(
            sfSymbol:    "alarm.waves.left.and.right.fill",
            title:       "Smart Wake Alarm",
            subtitle:    "When your body is ready, iPhone alarms and Apple Watch haptics wake you gently.",
            accentColor: UIColor(hex: "#5E9BF0")
        ),
        OnboardingPage(
            sfSymbol:    "sunrise.fill",
            title:       "Rise Ritual",
            subtitle:    "Start a short Watch-guided routine to move into the day with intention.",
            accentColor: WakeWellTheme.accentGold
        )
    ]

    private weak var carouselCell: CarouselCell?
    private weak var controlsCell: ControlsCell?

    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        applyGradientBackground()
        setupTableView()
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
            UIColor(hex: "#F2F1FF").cgColor,   // WakeWellTheme.background (light)
            UIColor(hex: "#EAE8FF").cgColor,   // slightly deeper lavender mid
            UIColor(hex: "#E0DEFF").cgColor    // soft purple base
        ]
        grad.locations = [0.0, 0.5, 1.0]
        grad.startPoint = CGPoint(x: 0.5, y: 0)
        grad.endPoint   = CGPoint(x: 0.5, y: 1)
        view.layer.insertSublayer(grad, at: 0)
        tableView.backgroundColor = WakeWellTheme.background 
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
        case .carousel: return total * 0.80
        case .controls: return total * 0.20
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

    private let pageControl = UIPageControl()
    private let nextButton  = UIButton(type: .system)
    private let skipButton  = UIButton(type: .system)

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    required init?(coder: NSCoder) { fatalError() }

    private func setup() {
        backgroundColor             = .clear
        contentView.backgroundColor = .clear
        selectionStyle              = .none

        // Page dots — visible on light background
        pageControl.pageIndicatorTintColor        = WakeWellTheme.accentPurple.withAlphaComponent(0.30)
        pageControl.currentPageIndicatorTintColor = WakeWellTheme.accentPurple
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

        // Skip button
        skipButton.setTitle("Skip", for: .normal)
        skipButton.setTitleColor(WakeWellTheme.labelSecondary, for: .normal)
        skipButton.titleLabel?.font     = .systemFont(ofSize: 14, weight: .regular)
        skipButton.translatesAutoresizingMaskIntoConstraints = false
        skipButton.addTarget(self, action: #selector(skipTapped), for: .touchUpInside)

        contentView.addSubview(pageControl)
        contentView.addSubview(nextButton)
        contentView.addSubview(skipButton)

        NSLayoutConstraint.activate([
            pageControl.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            pageControl.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),

            nextButton.topAnchor.constraint(equalTo: pageControl.bottomAnchor, constant: 14),
            nextButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            nextButton.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.72),
            nextButton.heightAnchor.constraint(equalToConstant: 52),

            skipButton.topAnchor.constraint(equalTo: nextButton.bottomAnchor, constant: 8),
            skipButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor)
        ])
    }

    func configure(pageCount: Int, currentPage: Int) {
        pageControl.numberOfPages = pageCount
        pageControl.currentPage   = currentPage
    }

    func update(currentPage: Int, isLast: Bool) {
        pageControl.currentPage = currentPage
        let title = isLast ? "Set Sail  ⛵" : "Next"
        nextButton.setTitle(title, for: .normal)
        nextButton.backgroundColor = isLast ? WakeWellTheme.accentGold : WakeWellTheme.accentPurple
        UIView.animate(withDuration: 0.2) {
            self.skipButton.alpha = isLast ? 0 : 1
        }
    }

    @objc private func nextTapped() { onNext?() }
    @objc private func skipTapped() { onSkip?() }
}
