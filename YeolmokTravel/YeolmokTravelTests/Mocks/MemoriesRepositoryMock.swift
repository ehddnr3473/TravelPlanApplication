//
//  MemoriesRepositoryMock.swift
//  YeolmokTravelTests
//
//  Created by 김동욱 on 2023/02/27.
//

import Foundation
import Domain

final class MemoriesRepositoryMock: MemoriesRepository {
    var memories: [Memory] = [
        Memory(
            id: 0,
            title: "title0",
            uploadDate: Date(timeIntervalSince1970: 0)
        ),
        Memory(
            id: 1,
            title: "title1",
            uploadDate: Date(timeIntervalSince1970: 1)
        ),
        Memory(
            id: 2,
            title: "title2",
            uploadDate: Date(timeIntervalSince1970: 2)
        )
    ]
    
    func upload(_ memory: Memory) async throws {
        memories.insert(memory, at: memory.id)
    }
    
    func read() async throws -> [Memory] {
        memories
    }
    
    func delete(key: String) async throws {
        memories.remove(at: Int(key)!)
    }
}
