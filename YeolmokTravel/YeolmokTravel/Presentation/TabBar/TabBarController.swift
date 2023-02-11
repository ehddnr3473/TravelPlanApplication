//
//  TabBarController.swift
//  YeolmokTravel
//
//  Created by 김동욱 on 2022/12/20.
//

import UIKit
import JGProgressHUD

final class TabBarController: UITabBarController {
    private var travelPlanViewBuilder: TravelPlanViewBuilder?
    private var memoryViewBuilder: MemoryViewBuilder?
    
    init(_ travelPlanViewBuilder: TravelPlanViewBuilder, _ memoryViewBuilder: MemoryViewBuilder) {
        self.travelPlanViewBuilder = travelPlanViewBuilder
        self.memoryViewBuilder = memoryViewBuilder
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var indicatorView: JGProgressHUD? = {
        let headUpDisplay = JGProgressHUD()
        headUpDisplay.textLabel.text = "Loading.."
        headUpDisplay.detailTextLabel.text = "Please wait"
        return headUpDisplay
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        startIndicator()
        configureTabBar()
        
        configureViewControllers()
        dismissIndicator()
        deallocate()
    }
}

// MARK: - Configure
private extension TabBarController {
    func configureTabBar() {
        tabBar.barTintColor = .systemBackground
        tabBar.tintColor = AppStyles.mainColor
        tabBar.unselectedItemTintColor = .systemGray
    }
    
    func configureViewControllers() {
        let travelPlanViewController = buildPlanView()
        let memoryViewController = buildMemoryView()
        
        viewControllers = [travelPlanViewController, memoryViewController]
        setViewControllers(viewControllers, animated: true)
    }
    
    // 첫 번째 탭: Plans
    func buildPlanView() -> UINavigationController {
        guard let travelPlanViewBuilder = travelPlanViewBuilder else { fatalError("travelPlanViewBuilder has not been injected.") }
        let travelPlanViewController = travelPlanViewBuilder.build()
        let navigationController = UINavigationController(rootViewController: travelPlanViewController)
        navigationController.tabBarItem = UITabBarItem(title: TitleConstants.plan,
                                                 image: UIImage(systemName: ImageNames.note),
                                                 tag: NumberConstants.first)
        
        return navigationController
    }
    
    // 두 번째 탭: Memories
    func buildMemoryView() -> MemoryViewController {
        guard let memoryViewBuilder = memoryViewBuilder else { fatalError("memoryViewBuilder has not been injected.") }
        let memoryViewController = memoryViewBuilder.build()
        memoryViewController.tabBarItem = UITabBarItem(title: TitleConstants.memory,
                                             image: UIImage(systemName: ImageNames.memory),
                                             tag: NumberConstants.second)
        return memoryViewController
    }
    
    func deallocate() {
        travelPlanViewBuilder = nil
        memoryViewBuilder = nil
        indicatorView = nil
    }
}

// MARK: - Indicator
private extension TabBarController {
    func startIndicator() {
        guard let indicatorView = indicatorView else { return }
        indicatorView.show(in: view)
    }
    
    func dismissIndicator() {
        guard let indicatorView = indicatorView else { return }
        indicatorView.dismiss(animated: true)
    }
}

private enum TitleConstants {
    static let plan = "Plans"
    static let memory = "Memories"
}

private enum ImageNames {
    static let note = "note.text"
    static let memory = "photo.artframe"
}

private enum NumberConstants {
    static let first = 0
    static let second = 1
}
