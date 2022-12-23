//
//  TabBarController.swift
//  YeolmokTravel
//
//  Created by 김동욱 on 2022/12/20.
//

import UIKit
import JGProgressHUD

class TabBarController: UITabBarController {
    private var planRepository: PlanRepository!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        planRepository = PlanRepository()
        Task { await setUp() }
    }
    
    private func showIndicatorView() {
        let hud = JGProgressHUD()
        hud.textLabel.text = "Loading"
        hud.detailTextLabel.text = "Please wait"
        hud.show(in: view)
        hud.dismiss(afterDelay: 1)
    }
    
    private func setUp() async {
        showIndicatorView()
        let travelPlanView = await setUpPlanView()
        let memoryView = await setUpMemoryView()
        
        viewControllers = [travelPlanView, memoryView]
        setViewControllers(viewControllers, animated: true)
        
        tabBar.tintColor = AppStyles.mainColor
        tabBar.unselectedItemTintColor = .systemGray
    }
    
    private func setUpPlanView() async -> TravelPlanView {
        let model = OwnTravelPlan(travelPlans: await planRepository.readTravelPlans())
        let viewModel = TravelPlaner(model)
        let travelPlanView = TravelPlanView()
        travelPlanView.viewModel = viewModel
        travelPlanView.tabBarItem = UITabBarItem(title: TitleConstants.plan,
                                           image: UIImage(systemName: ImageNames.note),
                                           tag: NumberConstants.first)
        return travelPlanView
    }
    
    private func setUpMemoryView() async -> MemoryView {
        let memoryView = MemoryView()
        
        memoryView.tabBarItem = UITabBarItem(title: TitleConstants.memory,
                                             image: UIImage(systemName: ImageNames.memory),
                                             tag: NumberConstants.second)
        return memoryView
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
