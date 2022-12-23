//
//  TabBarController.swift
//  YeolmokTravel
//
//  Created by 김동욱 on 2022/12/20.
//

import UIKit

class TabBarController: UITabBarController {
    private var travelPlanRepository: TravelPlanRepository!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        travelPlanRepository = TravelPlanRepository()
        Task { await setUp() }
    }
    
    private func setUp() async {
        let scheduleView = await setUpCalendarView()
        let travelPlanView = await setUpTravelPlanView()
        
        viewControllers = [scheduleView, travelPlanView]
        setViewControllers(viewControllers, animated: true)
        
        tabBar.tintColor = AppStyles.mainColor
    }
    
    private func setUpCalendarView() async -> CalendarView {
        let calendarView = CalendarView()
        calendarView.tabBarItem = UITabBarItem(title: TitleConstants.calendar,
                                               image: UIImage(systemName: ImageName.calendar),
                                               tag: NumberConstants.first)
        return calendarView
        
    }
    
    private func setUpTravelPlanView() async -> TravelPlanView {
        let model = OwnTravelPlan(travelPlans: await travelPlanRepository.readTravelPlans())
        let viewModel = TravelPlaner(model)
        let travelPlanView = TravelPlanView()
        travelPlanView.viewModel = viewModel
        travelPlanView.tabBarItem = UITabBarItem(title: TitleConstants.plan,
                                           image: UIImage(systemName: ImageName.note),
                                           tag: NumberConstants.second)
        return travelPlanView
    }
}

private enum TitleConstants {
    static let calendar = "Calendar"
    static let plan = "Plan"
}

private enum ImageName {
    static let calendar = "calendar.circle.fill"
    static let note = "note.text"
}

private enum NumberConstants {
    static let first = 0
    static let second = 1
}
