//
//  MemoryViewModel.swift
//  YeolmokTravel
//
//  Created by 김동욱 on 2023/01/24.
//

import Foundation
import Combine

private protocol MemoryViewModelType {
    // Input
    func add(_ memory: Memory)
    // Input & Output
    func memory(_ index: Int) -> Memory?
    // Output
    var reloadPublisher: PassthroughSubject<Void, Never> { get }
}

final class MemoryViewModel: MemoryViewModelType {
    private let useCase: ModelControlUsable
    let reloadPublisher = PassthroughSubject<Void, Never>()
    
    var count: Int {
        useCase.count
    }
    
    init(_ useCase: ModelControlUsable) {
        self.useCase = useCase
    }
    
    func add(_ memory: Memory) {
        useCase.add(memory)
        reloadPublisher.send()
    }
    
    func memory(_ index: Int) -> Memory? {
        useCase.query(index) as? Memory
    }
}
