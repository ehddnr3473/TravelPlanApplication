//
//  PlanViewBuilder.swift
//  YeolmokTravel
//
//  Created by 김동욱 on 2023/01/24.
//

import Foundation

protocol TravelPlanViewBuilder: AnyObject {
    func build() -> TravelPlanViewController
}

final class ConcreteTravelPlanViewBuilder: TravelPlanViewBuilder {
    private let travelPlanUseCaseProvider: TravelPlanUseCaseProvider
    
    init(travelPlanUseCaseProvider: TravelPlanUseCaseProvider) {
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
