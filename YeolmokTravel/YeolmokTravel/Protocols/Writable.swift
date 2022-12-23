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
    associatedtype ModelType: Plan
    
    var writingStyle: WritingStyle! { get }
    var planTracker: PlanTracker<ModelType>! { get set }
    var model: ModelType! { get set }
    var addDelegate: PlanTransfer? { get set }
    var editDelegate: PlanTransfer? { get set }
    
    func fetchActionSheetText() -> (String, String)
    func save(_ plan: ModelType, _ index: Int?)
}

extension Writable {
    func fetchActionSheetText() -> (String, String) {
        switch writingStyle {
        case .add:
            return (AlertText.addTitle, AlertText.message)
        case .edit:
            return (AlertText.editTitle, AlertText.message)
        case .none:
            return ("", "")
        }
    }
    
    func save(_ plan: ModelType, _ index: Int?) {
        switch writingStyle {
        case .add:
            addDelegate?.writingHandler(plan, nil)
        case .edit:
            editDelegate?.writingHandler(plan, index)
        case .none:
            break
        }
    }
}

private enum AlertText {
    static let addTitle = "입력한 내용이 있습니다."
    static let editTitle = "변경된 내용이 있습니다."
    static let message = "저장하지 않고 돌아가시겠습니까?"
}
