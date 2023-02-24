//
//  Alert.swift
//  YeolmokTravel
//
//  Created by 김동욱 on 2022/12/20.
//

import UIKit
import Foundation

extension UIViewController {
    /*
     @MainActor를 명시하면 메서드를 메인 스레드에서만 호출할 수 있음.
     메인 스레드가 아닌 스레드에서 호출시 "Call must be made on main thread" 에러 발생.
     */
    func alertWillAppear(_ message: String) {
        let alert = UIAlertController(title: AlertText.alertTitle, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: AlertText.okActionTitle, style: .default)
        alert.addAction(okAction)
        DispatchQueue.main.async { [weak self] in
            self?.present(alert, animated: true)
        }
    }
    
    func actionSheetWillAppear(_ title: String, _ message: String, _ okHandler: @escaping () -> Void) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        let okAction = UIAlertAction(title: AlertText.okActionTitle, style: .destructive) { _ in okHandler() }
        let cancelAction = UIAlertAction(title: AlertText.cancelActionTitle, style: .cancel)
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        DispatchQueue.main.async { [weak self] in
            self?.present(alert, animated: true)
        }
    }
}

enum AlertText {
    static let alertTitle = "알림"
    static let okActionTitle = "확인"
    static let cancelActionTitle = "취소"
    static let undefinedError = "알 수 없는 오류가 발생했습니다."
}
