//
//  DatePicker.swift
//  YeolmokTravel
//
//  Created by 김동욱 on 2023/02/04.
//

import Foundation
import UIKit
import Combine

extension UIDatePicker {
    var datePublisher: AnyPublisher<Date, Never> {
        controlPublisher(for: .valueChanged)
            .map { $0 as! UIDatePicker }
            .map { $0.date }
            .eraseToAnyPublisher()
    }
}
