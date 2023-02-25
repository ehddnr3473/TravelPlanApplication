//
//  TabBarController.swift
//  YeolmokTravel
//
//  Created by 김동욱 on 2022/12/20.
//

import UIKit
import JGProgressHUD

final class TabBarController: UITabBarController {
    private var plansListViewBuilder: PlansListViewBuilder?
    private var memoriesListViewBuilder: MemoriesListViewBuilder?
    
    init(_ plansListViewBuilder: PlansListViewBuilder, _ memoriesListViewBuilder: MemoriesListViewBuilder) {
        self.plansListViewBuilder = plansListViewBuilder
        self.memoriesListViewBuilder = memoriesListViewBuilder
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTabBar()
        configureViewControllers()
        deallocateViewBuilder()
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
        let plansListViewController = buildPlanView()
        let memoriesListViewController = buildMemoryView()
        
        viewControllers = [plansListViewController, memoriesListViewController]
        setViewControllers(viewControllers, animated: true)
    }
    
    // 첫 번째 탭: Plans
    func buildPlanView() -> UINavigationController {
        guard let plansListViewBuilder = plansListViewBuilder else { fatalError("plansListViewBulider has not been injected.") }
        let plansListViewController = plansListViewBuilder.build()
        let navigationController = UINavigationController(rootViewController: plansListViewController)
        navigationController.tabBarItem = UITabBarItem(title: TitleConstants.plan,
                                                 image: UIImage(systemName: ImageNames.note),
                                                 tag: NumberConstants.first)
        
        return navigationController
    }
    
    // 두 번째 탭: Memories
    func buildMemoryView() -> UINavigationController {
        guard let memoriesListViewBuilder = memoriesListViewBuilder else { fatalError("memoriesListViewBuilder has not been injected.") }
        let memoriesListViewController = memoriesListViewBuilder.build()
        let navigationController = UINavigationController(rootViewController: memoriesListViewController)
        navigationController.tabBarItem = UITabBarItem(title: TitleConstants.memory,
                                             image: UIImage(systemName: ImageNames.memory),
                                             tag: NumberConstants.second)
        return navigationController
    }
    
    func deallocateViewBuilder() {
        plansListViewBuilder = nil
        memoriesListViewBuilder = nil
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
