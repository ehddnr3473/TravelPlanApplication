//
//  Button.swift
//  YeolmokTravel
//
//  Created by 김동욱 on 2023/02/05.
//

import Foundation
import UIKit

extension UIButton {
    var isValidAtTintColor: Bool {
        get {
            tintColor == AppStyles.mainColor
        }
        
        set {
            isEnabled = newValue
            tintColor = newValue ? AppStyles.mainColor : .systemGray
        }
    }
    
    var isValidAtBackgroundColor: Bool {
        get {
            backgroundColor == AppStyles.mainColor
        }
        
        set {
            isEnabled = newValue
            backgroundColor = newValue ? AppStyles.mainColor : .systemGray
        }
    }
}
