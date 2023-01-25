//
//  Repository.swift
//  YeolmokTravel
//
//  Created by 김동욱 on 2023/01/25.
//

import Foundation

protocol AbstractRepository {
    associatedtype T
    
    func upload(entity: T) async
    func download(entity: T) async -> [T]
    func delete(at index: Int) async
}
