//
//  OnboardingPageViewController.swift
//  WakeWell
//
//  Created by geu on 11/04/26.
//

// OnboardingPageViewController.swift
import UIKit

class OnboardingPageViewController: UIViewController {

    private let slides = OnboardingSlide.slides
    private var currentIndex = 0

    // UI Elements
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.isPagingEnabled = true
        cv.showsHorizontalScrollIndicator = false
        cv.backgroundColor = UIColor(hex: "#F8F5EE")
        cv.translatesAutoresizingMaskIntoConstraints = false
        return cv
    }()

    private let pageControl: UIPageControl = {
        let pc = UIPageControl()
        pc.currentPageIndicatorTintColor = UIColor(hex: "#F5C842")
        pc.pageIndicatorTintColor = UIColor(hex: "#8A9BB0").withAlphaComponent(0.3)
        pc.translatesAutoresizingMaskIntoConstraints = false
        return pc
    }()

    private let nextButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Next", for: .normal)
        btn.backgroundColor = UIColor(hex: "#1B2D4F")
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        btn.layer.cornerRadius = 28
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    private let skipButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Skip", for: .normal)
        btn.setTitleColor(UIColor(hex: "#8A9BB0"), for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(hex: "#F8F5EE")
        setupCollectionView()
        setupUI()
        pageControl.numberOfPages = slides.count
    }

    private func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        // ✅ XIB-based registration
        let nib = UINib(nibName: "OnboardingSlideCell", bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: OnboardingSlideCell.identifier)
    }

    private func setupUI() {
        view.addSubview(collectionView)
        view.addSubview(pageControl)
        view.addSubview(nextButton)
        view.addSubview(skipButton)

        nextButton.addTarget(self, action: #selector(nextTapped), for: .touchUpInside)
        skipButton.addTarget(self, action: #selector(skipTapped), for: .touchUpInside)

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: pageControl.topAnchor, constant: -20),

            pageControl.bottomAnchor.constraint(equalTo: nextButton.topAnchor, constant: -24),
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            nextButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            nextButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            nextButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            nextButton.heightAnchor.constraint(equalToConstant: 56),

            skipButton.bottomAnchor.constraint(equalTo: nextButton.topAnchor, constant: -12),
            skipButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        ])
    }

    @objc private func nextTapped() {
        if currentIndex < slides.count - 1 {
            currentIndex += 1
            collectionView.scrollToItem(at: IndexPath(item: currentIndex, section: 0), at: .centeredHorizontally, animated: true)
            pageControl.currentPage = currentIndex
            // Change button to "Get Started" on last slide
            if currentIndex == slides.count - 1 {
                nextButton.setTitle("Get Started", for: .normal)
                nextButton.backgroundColor = UIColor(hex: "#F5C842")
                nextButton.setTitleColor(UIColor(hex: "#1B2D4F"), for: .normal)
                skipButton.isHidden = true
            }
        } else {
            goToUserDetails()
        }
    }

    @objc private func skipTapped() {
        goToUserDetails()
    }

    private func goToUserDetails() {
        let userDetailVC = UserDetailViewController(nibName: "UserDetailViewController", bundle: nil)
        userDetailVC.modalPresentationStyle = .fullScreen
        userDetailVC.modalTransitionStyle = .crossDissolve
        present(userDetailVC, animated: true)
    }
}

// MARK: - CollectionView
extension OnboardingPageViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ cv: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        slides.count
    }
    func collectionView(_ cv: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = cv.dequeueReusableCell(withReuseIdentifier: OnboardingSlideCell.identifier, for: indexPath) as! OnboardingSlideCell
        cell.configure(with: slides[indexPath.item])
        return cell
    }
    func collectionView(_ cv: UICollectionView, layout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return cv.frame.size
    }
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        currentIndex = Int(scrollView.contentOffset.x / scrollView.frame.width)
        pageControl.currentPage = currentIndex
    }
}
