//
//  FirestorePostsUseCase.swift
//  YeolmokTravel
//
//  Created by 김동욱 on 2023/01/27.
//

import Foundation

protocol FirestorePostsUseCase {
    associatedtype ModelType: Model
    
    func upload(at index: Int, entity: ModelType)
    func delete(at index: Int)
}
