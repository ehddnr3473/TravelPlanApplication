//
//  AppNamespace.swift
//  YeolmokTravel
//
//  Created by 김동욱 on 2022/12/20.
//

import UIKit
import Foundation

enum AppStyles {
    static let titleFontSize: CGFloat = 30
    static let mainColor = UIColor.systemGreen
}

enum DateUtilities {
    static let nilDateText = "날짜 미지정"
    static let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yy.MM.dd"
        return dateFormatter
    }()
}
