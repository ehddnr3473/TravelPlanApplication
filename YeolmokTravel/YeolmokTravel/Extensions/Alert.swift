//
//  Alert.swift
//  YeolmokTravel
//
//  Created by 김동욱 on 2022/12/20.
//

import UIKit
import Foundation

extension UIViewController {
    @MainActor
    func alertWillAppear(_ message: String) {
        let alert = UIAlertController(title: AlertText.alertTitle, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: AlertText.okActionTitle, style: .default)
        alert.addAction(okAction)
        present(alert, animated: true)
    }
    
    @MainActor
    func actionSheetWillApear(_ title: String, _ message: String, _ okHandler: @escaping () -> Void) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        let okAction = UIAlertAction(title: AlertText.okActionTitle, style: .destructive) { _ in okHandler() }
        let cancelAction = UIAlertAction(title: AlertText.cancelActionTitle, style: .cancel)
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        present(alert, animated: true)
    }
}

enum AlertText {
    static let alertTitle = "알림"
    static let titleMessage = "제목을 입력해주세요."
    static let okActionTitle = "확인"
    static let cancelActionTitle = "취소"
    static let dateMessage = "시작 날짜가 종료 날짜 이후입니다."
    static let undefinedError = "알 수 없는 오류가 발생했습니다."
    static let fromDateErrorMessage = "From 날짜를 선택해주세요."
    static let toDateErrorMessage = "To 날짜를 선택해주세요."
    static let nilImageMessage = "사진을 선택해주세요."
}
