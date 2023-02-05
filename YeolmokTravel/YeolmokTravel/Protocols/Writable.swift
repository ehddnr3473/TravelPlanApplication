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

protocol Writable: AnyObject {
    associatedtype WritableModelType: Plan
    
    var writingStyle: WritingStyle { get }
    var addDelegate: PlanTransfer? { get set }
    var editDelegate: PlanTransfer? { get set }
    var isEditing: Bool { get }
    
    func fetchActionSheetText() -> (String, String)
    func save(_ plan: WritableModelType, _ index: Int?)
}

extension Writable {
    /// writingStyle이 add인가를 나타내는 연산 프로퍼티
    var isAdding: Bool {
        switch writingStyle {
        case .add:
            return true
        case .edit:
            return false
        }
    }
    
    func fetchActionSheetText() -> (String, String) {
        switch writingStyle {
        case .add:
            return (WritableAlertText.addTitle, WritableAlertText.message)
        case .edit:
            return (WritableAlertText.editTitle, WritableAlertText.message)
        }
    }
    
    func save(_ plan: WritableModelType, _ index: Int?) {
        switch writingStyle {
        case .add:
            addDelegate?.writingHandler(plan, nil)
        case .edit:
            editDelegate?.writingHandler(plan, index)
        }
    }
}

private enum WritableAlertText {
    static let addTitle = "입력한 내용이 있습니다."
    static let editTitle = "변경된 내용이 있습니다."
    static let message = "저장하지 않고 돌아가시겠습니까?"
}
