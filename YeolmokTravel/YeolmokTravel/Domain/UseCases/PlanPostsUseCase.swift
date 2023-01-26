//
//  PlanPostsUseCase.swift
//  YeolmokTravel
//
//  Created by 김동욱 on 2023/01/22.
//

import Foundation

struct PlanPostsUseCase: FirebaseStorePostsUseCase {
    var repository: PlanRepository
    
    init(repository: PlanRepository) {
        self.repository = repository
    }
    
    func upload(at index: Int, entity: TravelPlan) {
        Task { await repository.upload(at: index, entity: entity.toData()) }
    }
    
    func delete(at index: Int) {
        Task { await repository.delete(at: index) }
    }
}
