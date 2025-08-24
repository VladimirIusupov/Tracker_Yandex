import UIKit

final class OnboardingViewController: UIPageViewController {

    // MARK: - Private Properties
    private lazy var pages: [UIViewController] = {
        let first = OnboardingStepViewController()
        let firstImage = UIImage(named: "Onboarding1") ?? UIImage()
        first.setup(with: firstImage, title: L10n.Onboarding.blueTitle)

        let second = OnboardingStepViewController()
        let secondImage = UIImage(named: "Onboarding2") ?? UIImage()
        second.setup(with: secondImage, title: L10n.Onboarding.redTitle)

        return [first, second]
    }()

    private lazy var pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.numberOfPages = pages.count
        pageControl.currentPage = 0

        pageControl.currentPageIndicatorTintColor = .ypAlwaysBlack
        pageControl.pageIndicatorTintColor = .ypAlwaysBlack.withAlphaComponent(0.3)

        return pageControl
    }()

    // MARK: - Overrides Methods
    override func viewDidLoad() {
        super.viewDidLoad()

        delegate = self
        dataSource = self

        if let first = pages.first {
            setViewControllers([first], direction: .forward, animated: true, completion: nil)
        }
        setupConstraints()

    }

    // MARK: - Init
    init() {
        super.init(
            transitionStyle: .scroll,
            navigationOrientation: .horizontal,
            options: nil
        )
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Private Methods
    private func setupConstraints() {
        view.addSubview(pageControl)

        pageControl.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pageControl.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -134),
        ])
    }
}

// MARK: - UIPageViewControllerDataSource
extension OnboardingViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = pages.firstIndex(of: viewController) else {
            return nil
        }

        let previousIndex = (viewControllerIndex - 1 + pages.count) % pages.count

        return pages[previousIndex]
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = pages.firstIndex(of: viewController) else {
            return nil
        }

        let nextIndex = (viewControllerIndex + 1) % pages.count

        return pages[nextIndex]
    }
}

// MARK: - UIPageViewControllerDelegate
extension OnboardingViewController: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {

        if let currentViewController = pageViewController.viewControllers?.first,
           let currentIndex = pages.firstIndex(of: currentViewController) {
            pageControl.currentPage = currentIndex
        }
    }
}
