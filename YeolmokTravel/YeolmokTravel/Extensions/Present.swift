//
//  Present.swift
//  YeolmokTravel
//
//  Created by 김동욱 on 2022/12/21.
//

import UIKit
import Foundation

extension UIViewController {
    @MainActor
    func presentWritableView(_ writableView: some Writable) {
        if let writingTravelPlanView = writableView as? WritingTravelPlanViewController {
            present(writingTravelPlanView, animated: true)
        } else if let writingScheduleView = writableView as? WritingScheduleViewController {
            present(writingScheduleView, animated: true)
        }
    }
}
