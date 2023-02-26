//
//  PlansWriteFlowCoordinator.swift
//  YeolmokTravel
//
//  Created by 김동욱 on 2023/02/25.
//

import Foundation
import UIKit
import Domain
import CoreLocation

protocol PlansWriteFlowCoordinator: AnyObject {
    func start()
    func toWritePlan(plan: Plan,
                     writingStyle: WritingStyle,
                     delegate: PlanTransferDelegate,
                     plansListIndex: Int?,
                     coordinates: [CLLocationCoordinate2D])
    func toWriteSchedule(schedule: Schedule,
                         writingStyle: WritingStyle,
                         delegate: ScheduleTransferDelegate,
                         scheduleListIndex: Int?)
}

final class DefaultPlansWriteFlowCoordinator: PlansWriteFlowCoordinator {
    private let navigationController: UINavigationController?
    private let container: PlansSceneDIContainer
    
    init(navigationController: UINavigationController, container: PlansSceneDIContainer) {
        self.navigationController = navigationController
        self.container = container
    }
    
    func start() {
        navigationController?.pushViewController(container.makePlansListViewController(coordinator: self), animated: true)
    }
    
    func toWritePlan(plan: Plan,
                     writingStyle: WritingStyle,
                     delegate: PlanTransferDelegate,
                     plansListIndex: Int?,
                     coordinates: [CLLocationCoordinate2D]) {
        let writingPlanViewController = container.makeWritingPlanViewController(plan: plan,
                                                                                writingStyle: writingStyle,
                                                                                delegate: delegate,
                                                                                plansListIndex: plansListIndex,
                                                                                coordinates: coordinates,
                                                                                coordinator: self)
        writingPlanViewController.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(writingPlanViewController, animated: true)
    }
    
    func toWriteSchedule(schedule: Schedule, writingStyle: WritingStyle, delegate: ScheduleTransferDelegate, scheduleListIndex: Int?) {
        let writingScheduleViewController = container.makeWritingScheduleViewController(schedule: schedule,
                                                                                        writingStyle: writingStyle,
                                                                                        delegate: delegate,
                                                                                        scheduleListIndex: scheduleListIndex)
        navigationController?.pushViewController(writingScheduleViewController, animated: true)
    }
}
