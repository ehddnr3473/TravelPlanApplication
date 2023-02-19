//
//  MemoryViewModel.swift
//  YeolmokTravel
//
//  Created by 김동욱 on 2023/01/24.
//

import Foundation
import Combine
import Domain

private protocol MemoryViewModel: AnyObject {
    // Input -> Output(Model information)
    func read() async throws
    func create(_ memory: YTMemory)
}

final class ConcreteMemoryViewModel: MemoryViewModel {
    private(set) var model = CurrentValueSubject<[YTMemory], Never>([])
    private let useCaseProvider: MemoryUseCaseProvider
    
    init(_ useCaseProvider: MemoryUseCaseProvider) {
        self.useCaseProvider = useCaseProvider
    }
    
    func read() async throws {
        let readUseCase = useCaseProvider.provideMemoryReadUseCase()
        model.send(try await readUseCase.execute().map { YTMemory(memory: $0) })
    }
    
    func create(_ memory: YTMemory) {
        model.value.append(memory)
    }
}
