//
//  UseCaseProvider.swift
//  YeolmokTravel
//
//  Created by 김동욱 on 2023/01/27.
//

import Foundation

final class UseCaseProvider {
    private let planRepository: PlanRepository
    private let memoryRepository: MemoryRepository
    private let storageRepository: StorageRepository

    init(planRepository: PlanRepository, memoryRepository: MemoryRepository, storageRepository: StorageRepository) {
        self.planRepository = planRepository
        self.memoryRepository = memoryRepository
        self.storageRepository = storageRepository
    }
    
    func createImagePostsUseCase() -> ImagePostsUseCase {
        ImagePostsUseCase(repository: storageRepository)
    }
    
    func createMemoryPostsUseCase() -> MemoryPostsUseCase {
        MemoryPostsUseCase(repository: memoryRepository)
    }
    
    func createDefaultMemoryUseCase(_ model: [Memory]) -> MemoryControllableUseCase {
        MemoryControllableUseCase(memories: model)
    }
    
    func createPlanPostsUseCase(_ model: OwnTravelPlan) -> PlanPostsUseCase {
        PlanPostsUseCase(model: model, repository: planRepository)
    }
    
    func createPlanControllableUseCase(_ model: OwnTravelPlan) -> PlanControllableUseCase {
        PlanControllableUseCase(model: model)
    }
}
