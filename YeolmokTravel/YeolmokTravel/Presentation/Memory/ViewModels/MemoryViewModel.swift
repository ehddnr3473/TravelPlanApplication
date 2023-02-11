//
//  MemoryViewModel.swift
//  YeolmokTravel
//
//  Created by 김동욱 on 2023/01/24.
//

import Foundation
import Combine

private protocol MemoryViewModel {
    // Input -> Output(Model information)
    func read() async throws
    func create(_ memory: Memory)
}

final class ConcreteMemoryViewModel: MemoryViewModel {
    private(set) var model = CurrentValueSubject<[Memory], Never>([])
    private let useCaseProvider: MemoryUseCaseProvider
    
    init(_ useCaseProvider: MemoryUseCaseProvider) {
        self.useCaseProvider = useCaseProvider
    }
    
    func read() async throws {
        let readUseCase = useCaseProvider.provideMemoryReadUseCase()
        model.send(try await readUseCase.execute())
    }
    
    func create(_ memory: Memory) {
        model.value.append(memory)
    }
}
