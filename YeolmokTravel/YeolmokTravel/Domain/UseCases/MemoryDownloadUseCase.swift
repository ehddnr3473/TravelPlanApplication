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

final class MemoryDownloadUseCase: MemoryDownloadUseCaseType {
    private let repository = MemoryRepository()
    private var memories = [Memory]()
    
    var count: Int {
        memories.count
    }
    
    func memory(_ index: Int) -> Memory {
        memories[index]
    }
    
    func download() async {
        memories = await repository.downloadMemories()
    }
}
