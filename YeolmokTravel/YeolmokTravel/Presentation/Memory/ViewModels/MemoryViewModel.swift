//
//  MemoryViewModel.swift
//  YeolmokTravel
//
//  Created by 김동욱 on 2023/01/24.
//

import Foundation
import Combine

final class MemoryViewModel {
    private let memoryDownloadUseCase = MemoryDownloadUseCase()
    private(set) var publisher = PassthroughSubject<Void, Never>()
    
    var count: Int {
        memoryDownloadUseCase.count
    }
    
    func memories(_ index: Int) -> Memory {
        memoryDownloadUseCase.memories(index)
    }
    
    func downloadMemories() async {
        await memoryDownloadUseCase.download()
        publisher.send()
    }
}
