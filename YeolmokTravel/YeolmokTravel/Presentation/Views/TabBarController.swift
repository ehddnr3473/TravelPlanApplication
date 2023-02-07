//
//  TabBarController.swift
//  YeolmokTravel
//
//  Created by 김동욱 on 2022/12/20.
//

import UIKit
import JGProgressHUD

final class TabBarController: UITabBarController {
    var planViewBuilder: PlanViewBuilder!
    var memoryViewBuilder: MemoryViewBuilder!
    
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
        
        Task {
            await setUp()
            dismissIndicator()
        }
    }
}

// MARK: - Configure
private extension TabBarController {
    func configureTabBar() {
        tabBar.barTintColor = .systemBackground
        tabBar.tintColor = AppStyles.mainColor
        tabBar.unselectedItemTintColor = .systemGray
    }
    
    func setUp() async {
        let travelPlanView = await setUpPlanView()
        let memoryView = await setUpMemoryView()
        
        viewControllers = [travelPlanView, memoryView]
        setViewControllers(viewControllers, animated: true)
    }
    
    // 첫 번째 탭: Plans
    func setUpPlanView() async -> UINavigationController {
        let navigationController = UINavigationController(rootViewController: await planViewBuilder.build())
        navigationController.tabBarItem = UITabBarItem(title: TitleConstants.plan,
                                           image: UIImage(systemName: ImageNames.note),
                                           tag: NumberConstants.first)
        return navigationController
    }
    
    // 두 번째 탭: Memories
    func setUpMemoryView() async -> UINavigationController {
        let navigationController = await UINavigationController(rootViewController: memoryViewBuilder.build())
        navigationController.tabBarItem = UITabBarItem(title: TitleConstants.memory,
                                             image: UIImage(systemName: ImageNames.memory),
                                             tag: NumberConstants.second)
        return navigationController
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
        self.indicatorView = nil
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
