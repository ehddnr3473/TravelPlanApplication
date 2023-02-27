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
            title: "title0",
            index: 0,
            uploadDate: Date(timeIntervalSince1970: 0)
        ),
        Memory(
            title: "title1",
            index: 1,
            uploadDate: Date(timeIntervalSince1970: 1)
        ),
        Memory(
            title: "title2",
            index: 2,
            uploadDate: Date(timeIntervalSince1970: 2)
        )
    ]
    
    func upload(at index: Int, memory: Domain.Memory) async throws {
        memories.insert(memory, at: index)
    }
    
    func read() async throws -> [Domain.Memory] {
        memories
    }
    
    func delete(at index: Int) async throws {
        memories.remove(at: index)
    }
}
