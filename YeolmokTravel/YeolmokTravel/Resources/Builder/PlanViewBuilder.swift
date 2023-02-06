//
//  PlanViewBuilder.swift
//  YeolmokTravel
//
//  Created by 김동욱 on 2023/01/24.
//

import Foundation

final class PlanViewBuilder {
    private let planRepository: FirestorePlanRepository
    private let useCaseProvider: UseCaseProvider
    
    init(planRepository: FirestorePlanRepository, useCaseProvider: UseCaseProvider) {
        self.planRepository = planRepository
        self.useCaseProvider = useCaseProvider
    }
    
    private func downloadModel() async -> OwnTravelPlan {
        OwnTravelPlan(travelPlans: await planRepository.download().map { $0.toDomain() as! TravelPlan })
    }
    
    private func configureViewModel(_ model: OwnTravelPlan) -> TravelPlaner {
        TravelPlaner(model, useCaseProvider.createPlanControllableUseCase(model), useCaseProvider.createPlanPostsUseCase(model))
    }
    
    func build() async -> PlanViewController {
        let model = await downloadModel()
        let viewModel = configureViewModel(model)
        return await PlanViewController(viewModel)
    }
}
