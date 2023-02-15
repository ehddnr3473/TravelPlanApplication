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
    private let repository: AbstractTravelPlanRepository
    
    init(_ repository: AbstractTravelPlanRepository) {
        self.repository = repository
    }
    
    func execute() async throws -> [TravelPlan] {
        try await repository.read()
    }
}
