//
//  MemoryImageUseCaseProvider.swift
//  YeolmokTravel
//
//  Created by 김동욱 on 2023/02/11.
//

import Foundation

protocol MemoryImageUseCaseProvider: AnyObject {
    func provideMemoryImageUploadUseCase() -> MemoryImageUploadUseCase
    func provideMemoryImageReadUseCase() -> MemoryImageReadUseCase
    func provideMemoryImageDeleteUseCase() -> MemoryImageDeleteUseCase
}

final class ConcreteMemoryImageUseCaseProvider: MemoryImageUseCaseProvider {
    private let repository: AbstractMemoryImageRepository
    
    init(_ repository: AbstractMemoryImageRepository) {
        self.repository = repository
    }
    
    func provideMemoryImageUploadUseCase() -> MemoryImageUploadUseCase {
        ConcreteMemoryImageUploadUseCase(repository)
    }
    
    func provideMemoryImageReadUseCase() -> MemoryImageReadUseCase {
        ConcreteMemoryImageReadUseCase(repository)
    }
    
    func provideMemoryImageDeleteUseCase() -> MemoryImageDeleteUseCase {
        ConcreteMemoryImageDeleteUseCase(repository)
    }
}
