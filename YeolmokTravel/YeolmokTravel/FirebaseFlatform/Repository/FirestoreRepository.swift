//
//  FirestoreRepository.swift
//  YeolmokTravel
//
//  Created by 김동욱 on 2023/01/25.
//

import Foundation

protocol FirestoreRepository {
    associatedtype EntityType: Entity
    
    func upload(at index: Int, entity: EntityType) async
    func download() async -> [EntityType]
    func delete(at index: Int) async
}
