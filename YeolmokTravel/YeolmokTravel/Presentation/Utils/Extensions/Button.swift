//
//  Button.swift
//  YeolmokTravel
//
//  Created by 김동욱 on 2023/02/05.
//

import Foundation
import UIKit

extension UIButton {
    var isValidAtBackgroundColor: Bool {
        get {
            backgroundColor == AppStyles.mainColor
        }
        
        set {
            isEnabled = newValue
            backgroundColor = newValue ? AppStyles.mainColor : .systemGray
        }
    }
    
    var isEditingAtTintColor: Bool {
        get {
            tintColor == .systemRed
        }
        
        set {
            tintColor = newValue ? .systemRed : AppStyles.mainColor
        }
    }
}
