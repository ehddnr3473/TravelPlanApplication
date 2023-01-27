//
//  Entity.swift
//  YeolmokTravel
//
//  Created by 김동욱 on 2023/01/27.
//

import Foundation

protocol Entity {
    associatedtype DomainType: Model
    func toDomain() -> DomainType
}