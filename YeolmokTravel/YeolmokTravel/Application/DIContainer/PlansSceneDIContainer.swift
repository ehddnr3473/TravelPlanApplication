//
//  PlansSceneDIContainer.swift
//  YeolmokTravel
//
//  Created by 김동욱 on 2023/02/24.
//

import Foundation
import Domain
import FirebasePlatform
import CoreLocation

final class PlansSceneDIContainer {
    // MARK: - Use Case Provider
    private func makePlansUseCaseProvider() -> PlansUseCaseProvider {
        DefaultPlansUseCaseProvider(repository: makePlansRepository())
    }
    
    // MARK: - Repository
    private func makePlansRepository() -> PlansRepository {
        DefaultPlansRepository()
    }
    
    // MARK: - Plans List
    func makePlansListViewController(coordinator: PlansWriteFlowCoordinator) -> PlansListViewController {
        PlansListViewController(viewModel: makePlansListViewModel(),
                                coordinator: coordinator)
    }
    
    private func makePlansListViewModel() -> PlansListViewModel {
        DefaultPlansListViewModel(makePlansUseCaseProvider())
    }
    
    // MARK: - Writing Plan
    func makeWritingPlanViewController(plan: Plan,
                                       writingStyle: WritingStyle,
                                       delegate: PlanTransferDelegate,
                                       plansListIndex: Int?,
                                       coordinates: [CLLocationCoordinate2D],
                                       coordinator: PlansWriteFlowCoordinator) -> WritingPlanViewController {
        WritingPlanViewController(
            viewModel: makeWritingPlanViewModel(plan: plan),
            coordinator: coordinator,
            mapProvider: MapViewController(coordinates),
            writingStyle: writingStyle,
            delegate: delegate,
            plansListIndex: plansListIndex
        )
    }
    
    private func makeWritingPlanViewModel(plan: Plan) -> WritingPlanViewModel {
        DefaultWritingPlanViewModel(plan)
    }
    
    // MARK: - Writing Schedule
    func makeWritingScheduleViewController(schedule: Schedule,
                                           writingStyle: WritingStyle,
                                           delegate: ScheduleTransferDelegate,
                                           scheduleListIndex: Int?) -> WritingScheduleViewController {
        WritingScheduleViewController(
            viewModel: makeWritingScheduleViewModel(schedule: schedule),
            writingStyle: writingStyle,
            delegate: delegate,
            scheduleListIndex: scheduleListIndex
        )
    }
    
    private func makeWritingScheduleViewModel(schedule: Schedule) -> WritingScheduleViewModel {
        DefaultWritingScheduleViewModel(schedule)
    }
}
