//
//  ModelControlUsable.swift
//  YeolmokTravel
//
//  Created by 김동욱 on 2023/01/27.
//

import Foundation

protocol ModelControlUsable: AnyObject {
    var count: Int { get }
    func query(_ index: Int) -> Model
    func add(_ model: Model)
    func update(at index: Int, _ model: Model)
    func delete(_ index: Int)
}
