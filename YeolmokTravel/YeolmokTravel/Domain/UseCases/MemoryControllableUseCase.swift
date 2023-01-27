//
//  MemoryDownloadUseCase.swift
//  YeolmokTravel
//
//  Created by 김동욱 on 2023/01/24.
//

import Foundation

/// [Memory] 모델을 직접 조작하는 use case
final class MemoryControllableUseCase: ModelControllableUseCase {
    private var memories: [Memory]
    
    var count: Int {
        memories.count
    }
    
    init(memories: [Memory]) {
        self.memories = memories
    }
    
    func query(_ index: Int) -> Model {
        memories[index]
    }
    
    func add(_ model: Model) {
        guard let memory = model as? Memory else { return }
        memories.append(memory)
    }
    
    func update(at index: Int, _ model: Model) { }
    
    func delete(_ index: Int) { }
}
