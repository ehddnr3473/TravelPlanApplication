//
//  TravelPlanUploadUseCase.swift
//  YeolmokTravel
//
//  Created by 김동욱 on 2023/02/11.
//

import Foundation

protocol TravelPlanUploadUseCase: AnyObject {
    func execute(at index: Int, travelPlan: TravelPlan) async throws
}

final class ConcreteTravelPlanUploadUseCase: TravelPlanUploadUseCase {
    private let repository: AbstractTravelPlanRepository
    
    init(_ repository: AbstractTravelPlanRepository) {
        self.repository = repository
    }
    
    func execute(at index: Int, travelPlan: TravelPlan) async throws {
        try await repository.upload(at: index, travelPlanDTO: travelPlan.toData())
    }
}
