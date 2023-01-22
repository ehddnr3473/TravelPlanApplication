//
//  WritingViewModelType.swift
//  YeolmokTravel
//
//  Created by 김동욱 on 2023/01/22.
//

import Foundation

protocol WritingViewModelType {
    associatedtype Input
    associatedtype Output
    
    func transform(input: Input) -> Output
}
