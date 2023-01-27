//
//  MemoryRepository.swift
//  YeolmokTravel
//
//  Created by 김동욱 on 2022/12/24.
//

import Foundation
import FirebaseFirestore

/// Memory 관련 Firebase Firestore 연동
struct MemoryRepository: FirestoreRepository {
    private var database = Firestore.firestore()

    // write
    func upload(at index: Int, entity: some Entity) async {
        guard let entity = entity as? MemoryDTO else { return }
        try? await database.collection(DatabasePath.memories).document("\(DocumentPrefix.memory)\(entity.index)").setData([
            Key.title: entity.title,
            Key.index: entity.index,
            Key.uploadDate: DateConverter.dateToString(entity.uploadDate)
        ])
    }
    
    // read & return
    func download() async -> [Entity] {
        var memories = [MemoryDTO]()
        let memoriesSnapshot = try? await database.collection(DatabasePath.memories).getDocuments()
        
        for document in memoriesSnapshot!.documents {
            let data = document.data()
            memories.append(self.createMemory(data))
        }
        
        return memories
    }
    
    // delete
    func delete(at index: Int) async {
        try? await database.collection(DatabasePath.memories).document("\(index)").delete()
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
