//
//  MemoryDownloadUseCase.swift
//  YeolmokTravel
//
//  Created by 김동욱 on 2023/01/24.
//

import Foundation

protocol MemoryDownloadUseCaseType {
    func download() async
}

final class MemoryDownloadUseCase {
    private let repository = MemoryRepository()
    private(set) var model = [Memory]()
    
    var count: Int {
        model.count
    }
    
    func memory(_ index: Int) -> Memory {
        model[index]
    }
    
    func download() async {
        let memories = await repository.readMemories()
        model = memories
    }
}
