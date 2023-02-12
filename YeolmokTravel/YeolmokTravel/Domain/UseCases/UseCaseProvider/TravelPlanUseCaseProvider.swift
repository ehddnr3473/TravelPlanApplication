//
//  UseCaseProvider.swift
//  YeolmokTravel
//
//  Created by 김동욱 on 2023/01/27.
//

import Foundation

protocol TravelPlanUseCaseProvider: AnyObject {
    func provideTravelPlanUploadUseCase() -> TravelPlanUploadUseCase
    func provideTravelPlanReadUseCase() -> TravelPlanReadUseCase
    func provideTravelPlanDeleteUseCase() -> TravelPlanDeleteUseCase
    func provideTravelPlanSwapUseCase() -> TravelPlanSwapUseCase
}

final class ConcreteTravelPlanUseCaseProvider: TravelPlanUseCaseProvider {
    private let repository: AbstractTravelPlanRepository

    init(_ repository: AbstractTravelPlanRepository) {
        self.repository = repository
    }
    
    func provideTravelPlanUploadUseCase() -> TravelPlanUploadUseCase {
        ConcreteTravelPlanUploadUseCase(repository)
    }
    
    func provideTravelPlanReadUseCase() -> TravelPlanReadUseCase {
        ConcreteTravelPlanReadUseCase(repository)
    }
    
    func provideTravelPlanDeleteUseCase() -> TravelPlanDeleteUseCase {
        ConcreteTravelPlanDeleteUseCase(repository)
    }
    
    func provideTravelPlanSwapUseCase() -> TravelPlanSwapUseCase {
        ConcreteTravelPlanSwapUseCase(repository)
    }
}
