//
//  Writable.swift
//  YeolmokTravel
//
//  Created by 김동욱 on 2022/12/20.
//

import Foundation

@frozen enum WritingStyle: String {
    case create = "New"
    case update = "Edit"
}

@frozen fileprivate enum TextConstants {
    static let addTitle = "입력한 내용이 있습니다."
    static let editTitle = "변경된 내용이 있습니다."
    static let message = "저장하지 않고 돌아가시겠습니까?"
}

protocol Writable: AnyObject {
    var writingStyle: WritingStyle { get }
    var isChangedText: (String, String) { get }
}

extension Writable {
    var isChangedText: (String, String) {
        switch writingStyle {
        case .create:
            return (TextConstants.addTitle, TextConstants.message)
        case .update:
            return (TextConstants.editTitle, TextConstants.message)
        }
    }
}
