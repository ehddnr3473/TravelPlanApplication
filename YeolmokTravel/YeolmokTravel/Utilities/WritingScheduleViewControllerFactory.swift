//
//  WritingScheduleViewControllerFactory.swift
//  YeolmokTravel
//
//  Created by 김동욱 on 2023/02/21.
//

import Foundation

final class WritingScheduleViewControllerFactory {
    func makeWritingScheduleViewController(with model: YTSchedule,
                                             writingStyle: WritingStyle,
                                             delegate: ScheduleTransferDelegate,
                                             scheduleListIndex: Int?) -> WritingScheduleViewController {
        WritingScheduleViewController(
            viewModel: ConcreteWritingScheduleViewModel(model),
            writingStyle: writingStyle,
            delegate: delegate,
            scheduleListIndex: scheduleListIndex
        )
    }
}
