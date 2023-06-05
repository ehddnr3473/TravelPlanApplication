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
