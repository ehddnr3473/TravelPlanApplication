//
//  FirebaseStorePostsUseCase.swift
//  YeolmokTravel
//
//  Created by 김동욱 on 2023/01/27.
//

import Foundation

protocol FirebaseStorePostsUseCase {
    associatedtype Repository: FirestoreRepository
    associatedtype Entity
    
    var repository: Repository { get set }
    
    func upload(at index: Int, entity: Entity)
    func delete(at index: Int)
}
