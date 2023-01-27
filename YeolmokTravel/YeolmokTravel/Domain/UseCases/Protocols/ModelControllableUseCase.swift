//
//  ModelControllableUseCase.swift
//  YeolmokTravel
//
//  Created by 김동욱 on 2023/01/27.
//

import Foundation

protocol ModelControllableUseCase {
    func add(_ model: Model)
    func update(at index: Int, _ model: Model)
    func delete(_ index: Int)
}
