//
//  MemoryViewModel.swift
//  YeolmokTravel
//
//  Created by 김동욱 on 2023/01/24.
//

import Foundation
import Combine

final class MemoryViewModel {
    private let useCase: DefaultMemoryUseCase
    private(set) var publisher = PassthroughSubject<Void, Never>()
    
    var count: Int {
        useCase.count
    }
    
    init(useCase: DefaultMemoryUseCase) {
        self.useCase = useCase
    }
    
    func memory(_ index: Int) -> Memory {
        useCase.memory(index)
    }
    
    func add(_ memory: Memory) {
        useCase.add(memory)
        publisher.send()
    }
}
