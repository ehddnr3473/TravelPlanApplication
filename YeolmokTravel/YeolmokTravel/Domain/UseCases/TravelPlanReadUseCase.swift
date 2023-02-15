//
//  TravelPlanReadUseCase.swift
//  YeolmokTravel
//
//  Created by 김동욱 on 2023/02/11.
//

import Foundation

protocol TravelPlanReadUseCase {
    func execute() async throws -> [TravelPlan]
}

struct ConcreteTravelPlanReadUseCase: TravelPlanReadUseCase {
    private let travelPlanRepository: AbstractTravelPlanRepository
    
    init(_ travelPlanRepository: AbstractTravelPlanRepository) {
        self.travelPlanRepository = travelPlanRepository
    }
    
    func execute() async throws -> [TravelPlan] {
        try await travelPlanRepository.read()
    }
}
