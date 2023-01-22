//
//  MemoryRepository.swift
//  YeolmokTravel
//
//  Created by 김동욱 on 2022/12/24.
//

import Foundation
import FirebaseFirestore

/// Memory 관련 Firebase Firestore 연동
struct MemoryRepository {
    private var database = Firestore.firestore()

    // write
    func writeMemory(_ memory: Memory) async {
        try? await database.collection(DatabasePath.memories).document("\(DocumentPrefix.memory)\(memory.index)").setData([
            Key.title: memory.title,
            Key.index: memory.index,
            Key.uploadDate: DateConverter.dateToString(memory.uploadDate)
        ])
    }
    
    // read & return
    func readMemories() async -> [Memory] {
        var memories = [Memory]()
        let memoriesSnapshot = try? await database.collection(DatabasePath.memories).getDocuments()
        
        for document in memoriesSnapshot!.documents {
            let data = document.data()
            memories.append(self.createMemory(data))
        }
        
        return memories
    }
    
    // 다운로드한 데이터로 Memory 생성하여 반환
    private func createMemory(_ data: Dictionary<String, Any>) -> Memory {
        let memories = Memory(title: data[Key.title] as! String,
                              index: data[Key.index] as! Int,
                              uploadDate: DateConverter.stringToDate(data[Key.uploadDate] as! String)!)
        return memories
    }
    
    // delete
    func delete(at index: Int) async {
        try? await database.collection(DatabasePath.memories).document("\(index)").delete()
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
