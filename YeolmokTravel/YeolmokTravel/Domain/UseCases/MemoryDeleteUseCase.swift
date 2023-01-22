//
//  MemoryDeleteUseCase.swift
//  YeolmokTravel
//
//  Created by 김동욱 on 2023/01/23.
//

import Foundation

struct MemoryDeleteUseCase {
    private let repository = MemoryRepository()
    
    func delete(_ index: Int) {
        Task { await repository.delete(at: index) }
    }
}
