//
//  TextPostsUsable.swift
//  YeolmokTravel
//
//  Created by 김동욱 on 2023/01/27.
//

import Foundation

protocol TextPostsUsable {
    func upload(at index: Int, model: Model)
    func delete(at index: Int)
}
