//
//  MemoryRepository.swift
//  YeolmokTravel
//
//  Created by 김동욱 on 2022/12/24.
//

import Foundation
import FirebaseFirestore

enum MemoryRepositoryError: String, Error {
    case uploadError = "메모리 업로드를 실패했습니다."
    case readError = "메모리 다운로드를 실패했습니다."
    case deleteError = "메모리 삭제를 실패했습니다."
}

protocol AbstractMemoryRepository: AnyObject {
    func upload(at index: Int, entity: MemoryDTO) async throws
    func read() async throws -> [MemoryDTO]
    func delete(at index: Int) async throws
}

/// Memory 관련 Firebase Firestore 연동
final class MemoryRepository: AbstractMemoryRepository {
    private var database = Firestore.firestore()

    // write
    func upload(at index: Int, entity: MemoryDTO) async throws {
        do {
            try await database.collection(DatabasePath.memories).document("\(DocumentPrefix.memory)\(entity.index)").setData([
                Key.title: entity.title,
                Key.index: entity.index,
                Key.uploadDate: DateConverter.dateToString(entity.uploadDate)
            ])
        } catch {
            throw MemoryRepositoryError.uploadError
        }
    }
    
    // read & return
    func read() async throws -> [MemoryDTO] {
        var memories = [MemoryDTO]()
        do {
            let memoriesSnapshot = try await database.collection(DatabasePath.memories).getDocuments()
            
            for document in memoriesSnapshot.documents {
                let data = document.data()
                memories.append(self.createMemory(data))
            }
            
            return memories
        } catch {
            throw MemoryRepositoryError.readError
        }
    }
    
    // delete
    func delete(at index: Int) async throws {
        do {
            try await database.collection(DatabasePath.memories).document("\(index)").delete()
        } catch {
            throw MemoryRepositoryError.deleteError
        }
    }
    
    // 다운로드한 데이터로 Memory 생성하여 반환
    private func createMemory(_ data: Dictionary<String, Any>) -> MemoryDTO {
        let memories = MemoryDTO(title: data[Key.title] as! String,
                              index: data[Key.index] as! Int,
                              uploadDate: DateConverter.stringToDate(data[Key.uploadDate] as! String)!)
        return memories
    }
}

private enum Key {
    static let title = "title"
    static let index = "index"
    static let uploadDate = "date"
}

private enum DocumentPrefix {
    static let memory = "memory"
}
