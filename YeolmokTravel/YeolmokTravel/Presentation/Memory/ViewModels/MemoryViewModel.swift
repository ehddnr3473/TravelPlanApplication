//
//  MemoryViewModel.swift
//  YeolmokTravel
//
//  Created by 김동욱 on 2023/01/24.
//

import Foundation
import Combine

final class MemoryViewModel {
    private let useCase = MemoryDownloadUseCase()
    private(set) var publisher = PassthroughSubject<Void, Never>()
    
    var count: Int {
        useCase.count
    }
    
    func memory(_ index: Int) -> Memory {
        useCase.memory(index)
    }
    
    func downloadMemories() async {
        await useCase.download()
        publisher.send()
    }
}
