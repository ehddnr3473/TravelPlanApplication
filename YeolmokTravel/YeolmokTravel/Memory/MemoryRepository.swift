//
//  MemoryRepository.swift
//  YeolmokTravel
//
//  Created by 김동욱 on 2022/12/24.
//

import Foundation
import FirebaseFirestore

/// Memory 관련 Firebase Firestore, Storage 연동
struct MemoryRepository {
    private var database = Firestore.firestore()

    // write
    func writeMemory(at index: Int, _ memory: Memory) async {
        try? await database.collection(DatabasePath.plans).document("\(index)").setData([
            Key.title: memory.title,
            Key.imageName: memory.imageName,
            Key.uploadDate: memory.uploadDate
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
                              imageName: data[Key.imageName] as! String,
                              uploadDate: DateConverter.stringToDate(data[Key.uploadDate] as! String)!)
        return memories
    }
}

private enum Key {
    static let title = "title"
    static let imageName = "imageName"
    static let uploadDate = "date"
}
