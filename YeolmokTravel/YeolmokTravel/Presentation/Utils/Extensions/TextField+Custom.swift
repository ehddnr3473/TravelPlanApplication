//
//  TextField+Custom.swift
//  YeolmokTravel
//
//  Created by 김동욱 on 2023/03/03.
//

import Foundation
import UIKit

extension UITextField {
    func makeCustomTextField() -> Self {
        textColor = AppStyles.getAccentColor()
        backgroundColor = .systemBackground
        layer.cornerRadius = AppLayoutConstants.cornerRadius
        layer.borderWidth = AppLayoutConstants.borderWidth
        layer.borderColor = AppStyles.getBorderColor()
        autocorrectionType = .no
        autocapitalizationType = .none
        returnKeyType = .done
        leftView = UIView(frame: CGRect(x: .zero, y: .zero, width: AppLayoutConstants.spacing, height: .zero))
        leftViewMode = .always
        return self
    }
    
    func withPlaceholder(_ text: String) -> Self {
        placeholder = text
        return self
    }
    
    func withFontSize(_ fontSize: CGFloat) -> Self {
        font = .boldSystemFont(ofSize: fontSize)
        return self
    }
    
    func withKeyboardType(_ type: UIKeyboardType) -> Self {
        keyboardType = type
        return self
    }
}
