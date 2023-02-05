//
//  Button.swift
//  YeolmokTravel
//
//  Created by 김동욱 on 2023/02/05.
//

import Foundation
import UIKit

extension UIButton {
    var isValid: Bool {
        get {
            tintColor == .systemGreen
        }
        
        set {
            isEnabled = newValue
            tintColor = newValue ? .systemGreen : .systemGray
        }
    }
}
