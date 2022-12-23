//
//  DateConverter.swift
//  YeolmokTravel
//
//  Created by 김동욱 on 2022/12/23.
//

import Foundation

enum DateConverter {
    static let nilDateText = "날짜 미지정"
    private static let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yy.MM.dd"
        return dateFormatter
    }()
    
    static func dateToString(_ date: Date?) -> String {
        if let date = date {
            return dateFormatter.string(from: date)
        } else {
            return ""
        }
    }
    
    static func stringToDate(_ string: String) -> Date? {
        dateFormatter.date(from: string)
    }
}
