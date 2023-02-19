//
//  PlanViewBuilder.swift
//  YeolmokTravel
//
//  Created by 김동욱 on 2023/01/24.
//

import Foundation
import Domain

protocol TravelPlanViewBuilder {
    func build() -> TravelPlanViewController
}

struct ConcreteTravelPlanViewBuilder: TravelPlanViewBuilder {
    private let travelPlanUseCaseProvider: TravelPlanUseCaseProvider
    
    init(_ travelPlanUseCaseProvider: TravelPlanUseCaseProvider) {
        self.travelPlanUseCaseProvider = travelPlanUseCaseProvider
    }
    
    private func createViewModel() -> ConcreteTravelPlanViewModel {
        ConcreteTravelPlanViewModel(travelPlanUseCaseProvider)
    }
    
    func build() -> TravelPlanViewController {
        let viewModel = createViewModel()
        return TravelPlanViewController(viewModel)
    }
}
