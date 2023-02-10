//
//  PlanUploadUseCase.swift
//  YeolmokTravel
//
//  Created by 김동욱 on 2023/02/11.
//

import Foundation

private protocol TravelPlanUploadUseCaseType {
    func excute(at index: Int, model: TravelPlan)
}

final class TravelPlanUploadUseCase: TravelPlanUploadUseCaseType {
    private let repository: TextRepository
    
    init(_ repository: TextRepository) {
        self.repository = repository
    }
    
    func excute(at index: Int, model: TravelPlan) {
        Task { await repository.upload(at: index, entity: model.toData()) }
    }
}
