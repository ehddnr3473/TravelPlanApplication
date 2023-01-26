//
//  FirestoreRepository.swift
//  YeolmokTravel
//
//  Created by 김동욱 on 2023/01/25.
//

import Foundation

protocol FirestoreRepository {
    associatedtype DTOType
    
    func upload(at index: Int, entity: DTOType) async
    func download() async -> [DTOType]
    func delete(at index: Int) async
}
