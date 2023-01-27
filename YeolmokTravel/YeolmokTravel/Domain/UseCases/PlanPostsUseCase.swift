//
//  PlanPostsUseCase.swift
//  YeolmokTravel
//
//  Created by 김동욱 on 2023/01/22.
//

import Foundation


/// Firestore 관련 use case
struct PlanPostsUseCase: FirestorePostsUseCase {
    private let model: OwnTravelPlan
    private let repository: FirestoreRepository
    
    init(model: OwnTravelPlan, repository: FirestoreRepository) {
        self.model = model
        self.repository = repository
    }
    
    func upload(at index: Int, entity: Model) {
        Task { await repository.upload(at: index, entity: entity.toData()) }
    }
    
    func delete(at index: Int) {
        Task { await repository.delete(at: index) }
    }
    
    func write(at index: Int?) async {
        if let index = index {
            await repository.upload(at: index, entity: model.travelPlans[index].toData() as! TravelPlanDTO)
        } else {
            let lastIndex = model.travelPlans.count - NumberConstants.one
            await repository.upload(at: lastIndex, entity: model.travelPlans[lastIndex].toData() as! TravelPlanDTO)
        }
    }
}

private enum NumberConstants {
    static let one = 1
}
