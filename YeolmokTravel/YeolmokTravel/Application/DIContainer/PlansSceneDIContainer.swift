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
        PlansListViewController(
            viewModel: makePlansListViewModel(),
            coordinator: coordinator
        )
    }
    
    private func makePlansListViewModel() -> PlansListViewModel {
        DefaultPlansListViewModel(makePlansUseCaseProvider())
    }
    
    // MARK: - Writing Plan
    func makeWritingPlanViewController(_ box: WritingPlanBox) -> WritingPlanViewController {
        WritingPlanViewController(
            viewModel: makeWritingPlanViewModel(box.plan),
            coordinator: box.coordinator,
            mapProvider: makeMapViewController(box.coordinates),
            writingStyle: box.writingStyle,
            delegate: box.delegate,
            plansListIndex: box.plansListIndex
        )
    }
    
    private func makeWritingPlanViewModel(_ plan: Plan) -> WritingPlanViewModel {
        DefaultWritingPlanViewModel(plan)
    }
    
    private func makeMapViewController(_ coordinates: [CLLocationCoordinate2D]) -> MapViewController {
        MapViewController(coordinates)
    }
    
    // MARK: - Writing Schedule
    func makeWritingScheduleViewController(_ box: WritingScheduleBox) -> WritingScheduleViewController {
        WritingScheduleViewController(
            viewModel: makeWritingScheduleViewModel(schedule: box.schedule),
            writingStyle: box.writingStyle,
            delegate: box.delegate,
            schedulesListIndex: box.schedulesListIndex
        )
    }
    
    private func makeWritingScheduleViewModel(schedule: Schedule) -> WritingScheduleViewModel {
        DefaultWritingScheduleViewModel(schedule)
    }
}

// MARK: - Parameter box
extension PlansSceneDIContainer {
    struct WritingPlanBox {
        let plan: Plan
        let coordinator: PlansWriteFlowCoordinator
        let writingStyle: WritingStyle
        let delegate: PlanTransferDelegate
        let plansListIndex: Int?
        let coordinates: [CLLocationCoordinate2D]
    }
    
    struct WritingScheduleBox {
        let schedule: Schedule
        let writingStyle: WritingStyle
        let delegate: ScheduleTransferDelegate
        let schedulesListIndex: Int?
    }
}
