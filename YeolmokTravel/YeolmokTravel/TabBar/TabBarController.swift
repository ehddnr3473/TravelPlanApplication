//
//  TabBarController.swift
//  YeolmokTravel
//
//  Created by 김동욱 on 2022/12/20.
//

import UIKit

class TabBarController: UITabBarController {
    private var planRepository: PlanRepository!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        planRepository = PlanRepository()
        Task { await setUp() }
    }
    
    private func setUp() async {
        let scheduleView = await setUpCalendarView()
        let travelPlanView = await setUpPlanView()
        let memoryView = await setUpMemoryView()
        
        viewControllers = [scheduleView, travelPlanView, memoryView]
        setViewControllers(viewControllers, animated: true)
        
        tabBar.tintColor = AppStyles.mainColor
        tabBar.unselectedItemTintColor = .systemGray
    }
    
    private func setUpCalendarView() async -> CalendarView {
        let calendarView = CalendarView()
        calendarView.tabBarItem = UITabBarItem(title: TitleConstants.calendar,
                                               image: UIImage(systemName: ImageNames.calendar),
                                               tag: NumberConstants.first)
        return calendarView
        
    }
    
    private func setUpPlanView() async -> TravelPlanView {
        let model = OwnTravelPlan(travelPlans: await planRepository.readTravelPlans())
        let viewModel = TravelPlaner(model)
        let travelPlanView = TravelPlanView()
        travelPlanView.viewModel = viewModel
        travelPlanView.tabBarItem = UITabBarItem(title: TitleConstants.plan,
                                           image: UIImage(systemName: ImageNames.note),
                                           tag: NumberConstants.second)
        return travelPlanView
    }
    
    private func setUpMemoryView() async -> MemoryView {
        let memoryView = MemoryView()
        
        memoryView.tabBarItem = UITabBarItem(title: TitleConstants.memory,
                                             image: UIImage(systemName: ImageNames.memory),
                                             tag: NumberConstants.third)
        return memoryView
    }
}

private enum TitleConstants {
    static let calendar = "Calendar"
    static let plan = "Plan"
    static let memory = "Memory"
}

private enum ImageNames {
    static let calendar = "calendar"
    static let note = "note.text"
    static let memory = "photo.artframe"
}

private enum NumberConstants {
    static let first = 0
    static let second = 1
    static let third = 2
}
