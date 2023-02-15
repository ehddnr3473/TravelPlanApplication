//
//  UseCaseProviderFactory.swift
//  YeolmokTravel
//
//  Created by 김동욱 on 2023/02/15.
//

import Foundation

protocol TravelPlanUseCaseProviderFactory {
    func createTravelPlanUseCaseProvider() -> TravelPlanUseCaseProvider
}

protocol MemoryUseCaseProviderFactory {
    func createMemoryUseCaseProvider() -> MemoryUseCaseProvider
}

protocol MemoryImageUseCaseProviderFactory {
    func createMemoryImageUseCaseProvider() -> MemoryImageUseCaseProvider
}

struct ConcreteUseCaseProviderFactory: TravelPlanUseCaseProviderFactory, MemoryUseCaseProviderFactory, MemoryImageUseCaseProviderFactory {
    private let travelPlanRepository: AbstractTravelPlanRepository
    private let memoryRepository: AbstractMemoryRepository
    private let memoryImageRepository: AbstractMemoryImageRepository
    
    init(_ travelPlanRepository: AbstractTravelPlanRepository,
         _ memoryRepository: AbstractMemoryRepository,
         _ memoryImageRepository: AbstractMemoryImageRepository) {
        self.travelPlanRepository = travelPlanRepository
        self.memoryRepository = memoryRepository
        self.memoryImageRepository = memoryImageRepository
    }
    
    func createTravelPlanUseCaseProvider() -> TravelPlanUseCaseProvider {
        ConcreteTravelPlanUseCaseProvider(travelPlanRepository)
    }
    
    func createMemoryUseCaseProvider() -> MemoryUseCaseProvider {
        ConcreteMemoryUseCaseProvider(memoryRepository)
    }
    
    func createMemoryImageUseCaseProvider() -> MemoryImageUseCaseProvider {
        ConcreteMemoryImageUseCaseProvider(memoryImageRepository)
    }
}
