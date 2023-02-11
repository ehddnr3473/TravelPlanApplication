//
//  MemoryImageUseCaseProvider.swift
//  YeolmokTravel
//
//  Created by 김동욱 on 2023/02/11.
//

import Foundation

protocol MemoryImageUseCaseProvider: AnyObject {
    func provideMemoryUploadUseCase() -> MemoryImageUploadUseCase
    func provideMemoryReadUseCase() -> MemoryImageReadUseCase
    func provideMemoryDeleteUseCase() -> MemoryImageDeleteUseCase
}

final class ConcreteMemoryImageUseCaseProvider: MemoryImageUseCaseProvider {
    private let repository: AbstractMemoryImageRepository
    
    init(_ repository: AbstractMemoryImageRepository) {
        self.repository = repository
    }
    
    func provideMemoryUploadUseCase() -> MemoryImageUploadUseCase {
        ConcreteMemoryImageUploadUseCase(repository)
    }
    
    func provideMemoryReadUseCase() -> MemoryImageReadUseCase {
        ConcreteMemoryImageReadUseCase(repository)
    }
    
    func provideMemoryDeleteUseCase() -> MemoryImageDeleteUseCase {
        ConcreteMemoryImageDeleteUseCase(repository)
    }
}
