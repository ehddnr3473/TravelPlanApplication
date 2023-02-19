//
//  YTMemory.swift
//  YeolmokTravel
//
//  Created by 김동욱 on 2022/12/24.
//

import Foundation

/// YTMemory Model
struct YTMemory {
    let title: String
    let index: Int
    let uploadDate: Date
}

extension YTMemory: Hashable {
    var id: Int {
        index
    }
}
