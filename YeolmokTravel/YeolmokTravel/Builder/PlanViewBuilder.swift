//
//  PlanViewBuilder.swift
//  YeolmokTravel
//
//  Created by 김동욱 on 2023/01/24.
//

import Foundation

struct PlanViewBuilder {
    private var planView: PlanView
    private var planRepository: PlanRepository
    
    init(planView: PlanView, planRepository: PlanRepository) {
        self.planView = planView
        self.planRepository = planRepository
    }
    
    private func downloadModel() async -> OwnTravelPlan {
        OwnTravelPlan(travelPlans: await planRepository.download().map { $0.toDomain() })
    }
    
    private func setUpUseCase(_ model: OwnTravelPlan) -> DefaultPlanUseCase {
        DefaultPlanUseCase(model: model)
    }
    
    private func setUpViewModel(_ useCase: DefaultPlanUseCase) {
        planView.viewModel = TravelPlaner(useCase)
    }
    
    func build() async -> PlanView {
        let model = await downloadModel()
        let useCase = setUpUseCase(model)
        setUpViewModel(useCase)
        return planView
    }
}
