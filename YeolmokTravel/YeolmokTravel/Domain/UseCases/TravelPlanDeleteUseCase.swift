//
//  TravelPlanDeleteUseCase.swift
//  YeolmokTravel
//
//  Created by 김동욱 on 2023/02/11.
//

import Foundation

private protocol PlanDeleteUseCaseType {
    func excute(at index: Int)
}

final class PlanDeleteUseCase: PlanDeleteUseCaseType {
    private let repository: TextRepository
    
    init(_ repository: TextRepository) {
        self.repository = repository
    }
    
    func excute(at index: Int) {
        Task { await repository.delete(at: index)}
    }
}
