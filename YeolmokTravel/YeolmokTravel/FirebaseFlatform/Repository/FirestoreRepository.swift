//
//  FirestoreRepository.swift
//  YeolmokTravel
//
//  Created by 김동욱 on 2023/01/25.
//

import Foundation

protocol FirestoreRepository {
    func upload(at index: Int, entity: Entity) async
    func download() async -> [Entity]
    func delete(at index: Int) async
}
