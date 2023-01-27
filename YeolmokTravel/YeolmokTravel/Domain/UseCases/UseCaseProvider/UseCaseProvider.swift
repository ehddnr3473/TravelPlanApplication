//
//  UseCaseProvider.swift
//  YeolmokTravel
//
//  Created by 김동욱 on 2023/01/27.
//

import Foundation

final class UseCaseProvider {
    private let firestoreRepository: FirestoreRepository
    private let storageRepository: StorageRepository

    init(firestoreRepository: FirestoreRepository, storageRepository: StorageRepository) {
        self.firestoreRepository = firestoreRepository
        self.storageRepository = storageRepository
    }
    
    func createImagePostsUseCase() -> ImagePostsUseCase {
        ImagePostsUseCase(repository: storageRepository)
    }
    
    func createMemoryPostsUseCase() -> MemoryPostsUseCase {
        MemoryPostsUseCase(repository: firestoreRepository)
    }
    
    func createDefaultMemoryUseCase(_ model: [Memory]) -> DefaultMemoryUseCase {
        DefaultMemoryUseCase(memories: model, repository: firestoreRepository)
    }
    
    func createPlanPostsUseCase(_ model: OwnTravelPlan) -> PlanPostsUseCase {
        PlanPostsUseCase(model: model, repository: firestoreRepository)
    }
    
    func createPlanControllableUseCase(_ model: OwnTravelPlan) -> PlanControllableUseCase {
        PlanControllableUseCase(model: model, repository: firestoreRepository)
    }
}
