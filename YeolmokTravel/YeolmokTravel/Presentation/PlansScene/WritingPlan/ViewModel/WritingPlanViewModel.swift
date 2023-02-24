//
//  WritingPlanViewModel.swift
//  YeolmokTravel
//
//  Created by 김동욱 on 2023/01/24.
//

import Foundation
import Combine

@frozen enum WritingTravelPlanError: String, Error {
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
    var calculatedContentViewHeight: CGFloat { get }
    var isChanged: Bool { get }
}

protocol WritingPlanViewModel: WritingPlanViewModelInput, WritingPlanViewModelOutput, AnyObject  { }

final class DefaultWritingPlanViewModel: WritingPlanViewModel {
    private var planTracker: PlanTracker
    // MARK: - Output
    let title: CurrentValueSubject<String, Never>
    let description: CurrentValueSubject<String, Never>
    let schedules: CurrentValueSubject<[Schedule], Never>
    var isChanged: Bool { planTracker.isChanged }
    
    var calculatedContentViewHeight: CGFloat {
        if schedules.value.count == 0 {
            return AppLayoutConstants.writingTravelPlanViewHeight +
            AppLayoutConstants.largeSpacing * 2
        } else {
            return AppLayoutConstants.writingTravelPlanViewHeight +
            Double(schedules.value.count) * AppLayoutConstants.cellHeight +
            AppLayoutConstants.mapViewHeight +
            AppLayoutConstants.largeFontSize +
            AppLayoutConstants.spacing +
            AppLayoutConstants.buttonHeight +
            AppLayoutConstants.largeSpacing * 3
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
        guard title.value.count > 0 else { throw WritingTravelPlanError.emptyTitle }
        return Plan(title: title.value,
                    description: description.value,
                    schedules: schedules.value)
    }
}
