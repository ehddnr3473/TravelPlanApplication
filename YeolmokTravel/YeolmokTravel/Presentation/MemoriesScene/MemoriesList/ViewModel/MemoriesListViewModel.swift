//
//  MemoryViewModel.swift
//  YeolmokTravel
//
//  Created by 김동욱 on 2023/01/24.
//

import Foundation
import Combine
import Domain


protocol MemoriesListViewModel: AnyObject {
    // Output
    var memories: CurrentValueSubject<[YTMemory], Never> { get }
    func read() async throws
    // Input
    func create(_ memory: YTMemory)
}

final class DefaultMemoriesListViewModel: MemoriesListViewModel {
    private let useCaseProvider: MemoriesUseCaseProvider
    // MARK: - Output
    let memories = CurrentValueSubject<[YTMemory], Never>([])
    
    // MARK: - Init
    init(useCaseProvider: MemoriesUseCaseProvider) {
        self.useCaseProvider = useCaseProvider
    }
    
    func read() async throws {
        let readUseCase = useCaseProvider.provideReadMemoriesUseCase()
        memories.send(try await readUseCase.execute().map { YTMemory(memory: $0)})
    }
    
    // MARK: - Input
    func create(_ memory: YTMemory) {
        memories.value.append(memory)
    }
}
