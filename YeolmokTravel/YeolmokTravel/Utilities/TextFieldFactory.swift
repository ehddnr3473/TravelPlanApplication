//
//  TextFieldFactory.swift
//  YeolmokTravel
//
//  Created by 김동욱 on 2023/02/22.
//

import Foundation
import UIKit

struct TextFieldFactory {
    @frozen private enum LayoutConstants {
        static let cornerRadius: CGFloat = 5
    }
    
    static func makeTitleTextField(_ fontSize: CGFloat, _ placeholder: String) -> UITextField {
        let textField = UITextField()
        textField.textColor = .white
        textField.backgroundColor = .systemBackground
        textField.layer.cornerRadius = LayoutConstants.cornerRadius
        textField.layer.borderWidth = AppLayoutConstants.borderWidth
        textField.layer.borderColor = UIColor.white.cgColor
        textField.font = .boldSystemFont(ofSize: fontSize)
        textField.placeholder = placeholder
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none
        textField.returnKeyType = .done
        textField.leftView = UIView(frame: CGRect(x: .zero,
                                                  y: .zero,
                                                  width: AppLayoutConstants.spacing,
                                                  height: .zero))
        textField.leftViewMode = .always
        return textField
    }
}
