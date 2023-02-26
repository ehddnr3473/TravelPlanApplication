//
//  WritingPlanViewModel.swift
//  YeolmokTravel
//
//  Created by 김동욱 on 2023/01/24.
//

import Foundation
import Combine
import Domain
import FirebasePlatform

@frozen enum WritingPlanError: String, Error {
    case emptyTitle = "제목을 작성해주세요."
}

protocol WritingPlanViewModelInput {
    func didEndCreating(_ schedule: Schedule)
    func didEndUpdating(at index: Int, _ schedule: Schedule)
    func deleteSchedule(at index: Int)
    func swapSchedules(at source: Int, to destination: Int)
    func didTouchUpAnyButton()
    func validateAndGetPlan() throws -> Plan
}

protocol WritingPlanViewModelOutput {
    var title: CurrentValueSubject<String, Never> { get }
    var description: CurrentValueSubject<String, Never> { get }
    var schedules: CurrentValueSubject<[Schedule], Never> { get }
    var isChanged: Bool { get }
    var calculatedContentViewHeight: CGFloat { get }
    func getDateString(at index: Int) -> String
}

protocol WritingPlanViewModel: WritingPlanViewModelInput, WritingPlanViewModelOutput, AnyObject  {}

final class DefaultWritingPlanViewModel: WritingPlanViewModel {
    private var planTracker: PlanTracker
    // MARK: - Output
    let title: CurrentValueSubject<String, Never>
    let description: CurrentValueSubject<String, Never>
    let schedules: CurrentValueSubject<[Schedule], Never>
    var isChanged: Bool { planTracker.isChanged }
    
    var calculatedContentViewHeight: CGFloat {
        if schedules.value.count == 0 {
            return WritingPlanView.Constants.nonSpacingHeightFromTitleLabelToScheduleLabel +
            AppLayoutConstants.spacing * 2 +
            AppLayoutConstants.largeSpacing
        } else {
            return WritingPlanView.Constants.nonSpacingHeightFromTitleLabelToScheduleLabel +
            AppLayoutConstants.spacing * 5 +
            AppLayoutConstants.largeSpacing * 2 +
            Double(schedules.value.count) * AppLayoutConstants.cellHeight +
            AppLayoutConstants.mapViewHeight +
            AppLayoutConstants.largeFontSize +
            AppLayoutConstants.buttonHeight
        }
    }
    
    func getDateString(at index: Int) -> String {
        let schedule = schedules.value[index]
        if let fromDate = schedule.fromDate, let toDate = schedule.toDate {
            let slicedFromDate = DateConverter.dateToString(fromDate)
            let slicedToDate = DateConverter.dateToString(toDate)
            if slicedFromDate == slicedToDate {
                return slicedFromDate
            } else {
                return "\(slicedFromDate) ~ \(slicedToDate)"
            }
        } else {
            return DateConverter.Constants.nilDateText
        }
    }
    
    // MARK: - Init
    init(_ plan: Plan) {
        self.title = CurrentValueSubject<String, Never>(plan.title)
        self.description = CurrentValueSubject<String, Never>(plan.description)
        self.schedules = CurrentValueSubject<[Schedule], Never>(plan.schedules)
        self.planTracker = PlanTracker(plan)
    }
}

// MARK: - Input. View event methods
extension DefaultWritingPlanViewModel {
    func didEndCreating(_ schedule: Schedule) {
        schedules.value.append(schedule)
    }
    
    func didEndUpdating(at index: Int, _ schedule: Schedule) {
        schedules.value[index] = schedule
    }
    
    func deleteSchedule(at index: Int) {
        schedules.value.remove(at: index)
    }
    
    func swapSchedules(at source: Int, to destination: Int) {
        schedules.value.swapAt(source, destination)
    }
    
    func didTouchUpAnyButton() {
        planTracker.plan = Plan(title: title.value,
                                description: description.value,
                                schedules: schedules.value)
    }
    
    func validateAndGetPlan() throws -> Plan {
        guard title.value.count > 0 else { throw WritingPlanError.emptyTitle }
        return Plan(title: title.value,
                    description: description.value,
                    schedules: schedules.value)
    }
}
