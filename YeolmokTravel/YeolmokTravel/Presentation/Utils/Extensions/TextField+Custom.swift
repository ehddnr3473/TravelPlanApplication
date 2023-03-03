//
//  TextField+Custom.swift
//  YeolmokTravel
//
//  Created by 김동욱 on 2023/03/03.
//

import Foundation
import UIKit

extension UITextField {
    func makeCustomTextField(_ fontSize: CGFloat, _ placeholderText: String) -> Self {
        textColor = .white
        backgroundColor = .systemBackground
        layer.cornerRadius = AppLayoutConstants.cornerRadius
        layer.borderWidth = AppLayoutConstants.borderWidth
        layer.borderColor = UIColor.white.cgColor
        font = .boldSystemFont(ofSize: fontSize)
        placeholder = placeholderText
        autocorrectionType = .no
        autocapitalizationType = .none
        returnKeyType = .done
        leftView = UIView(frame: CGRect(x: .zero, y: .zero, width: AppLayoutConstants.spacing, height: .zero))
        leftViewMode = .always
        return self
    }
}
