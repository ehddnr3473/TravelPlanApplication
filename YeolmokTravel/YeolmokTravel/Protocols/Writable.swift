//
//  Writable.swift
//  YeolmokTravel
//
//  Created by 김동욱 on 2022/12/20.
//

import Foundation

enum WritingStyle: String {
    case add = "New"
    case edit = "Edit"
}

protocol Writable {
    var writingStyle: WritingStyle! { get }
}
