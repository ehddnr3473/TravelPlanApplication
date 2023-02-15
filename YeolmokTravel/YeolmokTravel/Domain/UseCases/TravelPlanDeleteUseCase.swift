//
//  TravelPlanDeleteUseCase.swift
//  YeolmokTravel
//
//  Created by 김동욱 on 2023/02/11.
//

import Foundation

protocol TravelPlanDeleteUseCase {
    func execute(at index: Int) async throws
}

struct ConcreteTravelPlanDeleteUseCase: TravelPlanDeleteUseCase {
    private let travelPlanRepository: AbstractTravelPlanRepository
    
    init(_ travelPlanRepository: AbstractTravelPlanRepository) {
        self.travelPlanRepository = travelPlanRepository
    }
    
    func execute(at index: Int) async throws {
        try await travelPlanRepository.delete(at: index)
    }
}
