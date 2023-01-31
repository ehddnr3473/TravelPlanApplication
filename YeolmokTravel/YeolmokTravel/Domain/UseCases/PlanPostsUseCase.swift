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
    private let repository: TextRepository
    
    init(model: OwnTravelPlan, repository: TextRepository) {
        self.model = model
        self.repository = repository
    }
    
    func upload(at index: Int, model: Model) {
        Task { await repository.upload(at: index, entity: model.toData()) }
    }
    
    func delete(at index: Int) {
        Task { await repository.delete(at: index) }
    }
}
