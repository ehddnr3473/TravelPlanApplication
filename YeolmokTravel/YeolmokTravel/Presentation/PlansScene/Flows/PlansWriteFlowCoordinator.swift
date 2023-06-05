//
//  PlansWriteFlowCoordinator.swift
//  YeolmokTravel
//
//  Created by 김동욱 on 2023/02/25.
//

import UIKit

protocol PlansWriteFlowCoordinator: AnyObject {
    func start()
    func toWritePlan(_ box: PlansSceneDIContainer.WritingPlanBox)
    func toWriteSchedule(_ box: PlansSceneDIContainer.WritingScheduleBox)
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
    
    func toWritePlan(_ box: PlansSceneDIContainer.WritingPlanBox) {
        let writingPlanViewController = container.makeWritingPlanViewController(box)
        writingPlanViewController.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(writingPlanViewController, animated: true)
    }
    
    func toWriteSchedule(_ box: PlansSceneDIContainer.WritingScheduleBox) {
        let writingScheduleViewController = container.makeWritingScheduleViewController(box)
        navigationController?.pushViewController(writingScheduleViewController, animated: true)
    }
}
