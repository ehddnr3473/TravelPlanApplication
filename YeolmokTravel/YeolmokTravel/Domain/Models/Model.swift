//
//  Model.swift
//  YeolmokTravel
//
//  Created by 김동욱 on 2023/01/27.
//

import Foundation

protocol Model {
    associatedtype EntityType: Entity
    func toData() -> EntityType
}
