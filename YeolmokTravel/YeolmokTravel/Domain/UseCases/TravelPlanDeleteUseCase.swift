//
//  TravelPlanDeleteUseCase.swift
//  YeolmokTravel
//
//  Created by 김동욱 on 2023/02/11.
//

import Foundation

protocol TravelPlanDeleteUseCase: AnyObject {
    func execute(at index: Int) async throws
}

final class ConcreteTravelPlanDeleteUseCase: TravelPlanDeleteUseCase {
    private let repository: AbstractTravelPlanRepository
    
    init(_ repository: AbstractTravelPlanRepository) {
        self.repository = repository
    }
    
    func execute(at index: Int) async throws {
        try await repository.delete(at: index)
    }
}
