//
//  WritingScheduleViewControllerFactory.swift
//  YeolmokTravel
//
//  Created by 김동욱 on 2023/02/21.
//

import Foundation
import Domain

final class WritingScheduleViewControllerFactory {
    func makeWritingScheduleViewController(with schedule: Schedule,
                                             writingStyle: WritingStyle,
                                             delegate: ScheduleTransferDelegate,
                                             scheduleListIndex: Int?) -> WritingScheduleViewController {
        WritingScheduleViewController(
            viewModel: DefaultWritingScheduleViewModel(schedule),
            writingStyle: writingStyle,
            delegate: delegate,
            scheduleListIndex: scheduleListIndex
        )
    }
}
