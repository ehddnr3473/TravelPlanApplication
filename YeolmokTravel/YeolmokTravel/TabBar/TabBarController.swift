//
//  TabBarController.swift
//  YeolmokTravel
//
//  Created by 김동욱 on 2022/12/20.
//

import UIKit
import JGProgressHUD

class TabBarController: UITabBarController {
    var planRepository: PlanRepository!
    var memoryRepository: MemoryRepository!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Task { await setUp() }
    }
    
    // 파이어베이스 데이터 연동 성공/실패 유무와 상관없이 progress indicator 프레젠테이션
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
    
    // 첫 번째 탭: Plans
    private func setUpPlanView() async -> TravelPlanView {
        // Assembing of MVVM
        let model = OwnTravelPlan(travelPlans: await planRepository.readTravelPlans())
        let viewModel = TravelPlaner(model)
        let travelPlanView = TravelPlanView()
        travelPlanView.viewModel = viewModel
        travelPlanView.tabBarItem = UITabBarItem(title: TitleConstants.plan,
                                           image: UIImage(systemName: ImageNames.note),
                                           tag: NumberConstants.first)
        return travelPlanView
    }
    
    // 두 번째 탭: Memories
    private func setUpMemoryView() async -> MemoryViewController {
        // Assembing of MVC
        let model = Memories(memories: await memoryRepository.readMemories())
        let memoryView = MemoryViewController()
        memoryView.model = model
        
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
