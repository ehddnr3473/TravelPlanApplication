//
//  MemoryUseCaseProvider.swift
//  YeolmokTravel
//
//  Created by 김동욱 on 2023/02/11.
//

import Foundation

protocol MemoryUseCaseProvider: AnyObject {
    func provideMemoryUploadUseCase() -> MemoryUploadUseCase
    func provideMemoryReadUseCase() -> MemoryReadUseCase
    func provideMemoryDeleteUseCase() -> MemoryDeleteUseCase
}

final class ConcreteMemoryUseCaseProvider: MemoryUseCaseProvider {
    private let repository: AbstractMemoryRepository
    
    init(_ repository: AbstractMemoryRepository) {
        self.repository = repository
    }
    
    func provideMemoryUploadUseCase() -> MemoryUploadUseCase {
        ConcreteMemoryUploadUseCase(repository)
    }
    
    func provideMemoryReadUseCase() -> MemoryReadUseCase {
        ConcreteMemoryReadUseCase(repository)
    }
    
    func provideMemoryDeleteUseCase() -> MemoryDeleteUseCase {
        ConcreteMemoryDeleteUseCase(repository)
    }
}
