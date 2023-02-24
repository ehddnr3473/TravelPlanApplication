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

protocol Writable: AnyObject {
    var writingStyle: WritingStyle { get }
    
    func fetchActionSheetText() -> (String, String)
}

extension Writable {
    func fetchActionSheetText() -> (String, String) {
        switch writingStyle {
        case .create:
            return (WritableAlertText.addTitle, WritableAlertText.message)
        case .update:
            return (WritableAlertText.editTitle, WritableAlertText.message)
        }
    }
}

private enum WritableAlertText {
    static let addTitle = "입력한 내용이 있습니다."
    static let editTitle = "변경된 내용이 있습니다."
    static let message = "저장하지 않고 돌아가시겠습니까?"
}
