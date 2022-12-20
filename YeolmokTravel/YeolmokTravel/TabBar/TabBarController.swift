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
        let planView = PlanView()
        let planNavigationController = UINavigationController(rootViewController: planView)
        
        scheduleView.tabBarItem = UITabBarItem(title: TitleConstants.schedule,
                                               image: UIImage(systemName: ImageName.calendar),
                                               tag: NumberConstants.first)
        planNavigationController.tabBarItem = UITabBarItem(title: TitleConstants.todo,
                                           image: UIImage(systemName: ImageName.note),
                                           tag: NumberConstants.second)
        viewControllers = [scheduleView, planNavigationController]
        setViewControllers(viewControllers, animated: true)
    }
}

private enum TitleConstants {
    static let schedule = "Schedule"
    static let todo = "ToDo"
}

private enum ImageName {
    static let calendar = "calendar.circle.fill"
    static let note = "note.text"
}

private enum NumberConstants {
    static let first = 0
    static let second = 1
}
