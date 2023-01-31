//
//  PlanViewBuilder.swift
//  YeolmokTravel
//
//  Created by 김동욱 on 2023/01/24.
//

import Foundation

final class PlanViewBuilder {
    private let planView: PlanView
    private let planRepository: FirestorePlanRepository
    private let useCaseProvider: UseCaseProvider
    
    init(planView: PlanView, planRepository: FirestorePlanRepository, useCaseProvider: UseCaseProvider) {
        self.planView = planView
        self.planRepository = planRepository
        self.useCaseProvider = useCaseProvider
    }
    
    private func downloadModel() async -> OwnTravelPlan {
        OwnTravelPlan(travelPlans: await planRepository.download().map { $0.toDomain() as! TravelPlan })
    }
    
    private func setUpViewModel(_ model: OwnTravelPlan) {
        planView.viewModel = TravelPlaner(
            model,
            useCaseProvider.createPlanControllableUseCase(model),
            useCaseProvider.createPlanPostsUseCase(model)
        )
        
    }
    
    func build() async -> PlanView {
        let model = await downloadModel()
        setUpViewModel(model)
        return planView
    }
}
