//
//  TravelPlanUploadUseCase.swift
//  YeolmokTravel
//
//  Created by 김동욱 on 2023/02/11.
//

import Foundation

protocol TravelPlanUploadUseCase {
    func execute(at index: Int, travelPlan: TravelPlan) async throws
}

struct ConcreteTravelPlanUploadUseCase: TravelPlanUploadUseCase {
    private let repository: AbstractTravelPlanRepository
    
    init(_ repository: AbstractTravelPlanRepository) {
        self.repository = repository
    }
    
    func execute(at index: Int, travelPlan: TravelPlan) async throws {
        try await repository.upload(at: index, travelPlanDTO: travelPlan.toData())
    }
}
