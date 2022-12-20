//
//  WritingScheduleViewController.swift
//  YeolmokTravel
//
//  Created by 김동욱 on 2022/12/20.
//

import UIKit

class WritingScheduleViewController: UIViewController, Writable {
    typealias Model = WritableSchedule
    
    var model: Model!
    var writingStyle: WritingStyle!
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
