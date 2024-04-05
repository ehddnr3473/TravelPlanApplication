//
//  AppNamespace.swift
//  YeolmokTravel
//
//  Created by 김동욱 on 2022/12/20.
//

import Foundation
import UIKit

@frozen enum AppStyles {
    static let mainColor = UIColor.systemGreen
    
    static var currentInterfaceStyle: UIUserInterfaceStyle {
        guard let windowScene = UIApplication.shared.connectedScenes.first 
                as? UIWindowScene else { return .unspecified }
        return windowScene.traitCollection.userInterfaceStyle
    }
    
    static func getAccentColor() -> UIColor {
        if currentInterfaceStyle == .light {
            return .black
        } else {
            return .white
        }
    }
    
    static func getBorderColor() -> CGColor {
        if currentInterfaceStyle == .light {
            return UIColor.black.cgColor
        } else {
            return UIColor.white.cgColor
        }
    }
    
    static func getContentBackgroundColor() -> UIColor {
        if currentInterfaceStyle == .light {
            return AppColor.pastelMintGreen
        } else {
            return .darkGray
        }
    }
    
    static func getTableCellTitleColor() -> UIColor {
        if currentInterfaceStyle == .light {
            return UIColor.black
        } else {
            return UIColor.white
        }
    }
}

@frozen enum AppLayoutConstants {
    static let spacing: CGFloat = 8
    static let largeSpacing: CGFloat = 20
    static let borderWidth: CGFloat = 1
    static let cornerRadius: CGFloat = 5
    static let titleFontSize: CGFloat = 30
    static let largeFontSize: CGFloat = 25
    static let cellHeight: CGFloat = 100
    static let mapViewHeight: CGFloat = 500
    static let buttonHeight: CGFloat = 44.44
}

@frozen enum AppNumberConstants {
    static let mapViewTag = 77
    static let scheduleTitleTextFieldTag = 44
}

@frozen enum AppTextConstants {
    static let plusIcon = "plus"
    static let editIcon = "pencil"
    static let leftBarButtonTitle = "Back"
    static let rightBarButtonTitle = "Done"
    static let titlePlaceholder = "Title"
    static let descriptionPlaceholder = "Detail"
}

@frozen enum AppColor {
    static let pastelMintGreen = UIColor(red: 183/255, green: 247/255, blue: 198/255, alpha: 1.0)
}
