//
//  TabBarController.swift
//  YeolmokTravel
//
//  Created by 김동욱 on 2022/12/20.
//

import UIKit

class TabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUp()
    }
    
    private func setUp() {
        let scheduleView = ScheduleView()
        let model = OwnTravelPlan(travelPlans: [TravelPlan(title: "일본", description: "라멘 꼭 먹기",
                                                           schedules: [Schedule(title: "공항 도착", description: "good", fromDate: Date(), toDate: Date() + 1)]),
                                                TravelPlan(title: "한국",
                                                           description: "삼겹살 먹기",
                                                           schedules: [Schedule(title: "울산 가기")])])
        let viewModel = TravelPlaner(model)
        let travelPlanView = TravelPlanView()
        travelPlanView.viewModel = viewModel
        let planNavigationController = UINavigationController(rootViewController: travelPlanView)
        
        scheduleView.tabBarItem = UITabBarItem(title: TitleConstants.schedule,
                                               image: UIImage(systemName: ImageName.calendar),
                                               tag: NumberConstants.first)
        planNavigationController.tabBarItem = UITabBarItem(title: TitleConstants.plan,
                                           image: UIImage(systemName: ImageName.note),
                                           tag: NumberConstants.second)
        viewControllers = [scheduleView, planNavigationController]
        setViewControllers(viewControllers, animated: true)
        
        tabBar.tintColor = AppStyles.mainColor
    }
}

private enum TitleConstants {
    static let schedule = "Schedule"
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
