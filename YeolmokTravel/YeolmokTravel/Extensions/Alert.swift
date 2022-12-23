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
    func actionSheetWillApear(_ title: String, _ message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        let okAction = UIAlertAction(title: AlertText.okActionTitle, style: .destructive) { _ in
            self.dismiss(animated: true)
        }
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
}
