//
//  WritingTravelViewModel.swift
//  YeolmokTravel
//
//  Created by 김동욱 on 2023/01/24.
//

import Foundation
import Combine
import CoreLocation

enum WritingTravelPlanError: String, Error {
    case emptyTitle = "제목을 작성해주세요."
}

private protocol WritingTravelPlanViewModel: AnyObject {
    // Input(Schedules update) -> Output(Schedules changed information)
    func createSchedule(_ schedule: YTSchedule)
    func updateSchedule(at index: Int, _ schedule: YTSchedule)
    func deleteSchedule(at index: Int)
    func swapSchedules(at source: Int, to destination: Int)
    func setTravelPlanTracker() // travelPlanTracker.travelPlan set
    func editingChangedTitleTextField(_ title: String)
    func editingChangedDescriptionTextField(_ description: String)
    
    // Output
    var calculatedScrollViewContainerHeight: CGFloat { get }
    func createTravelPlan() throws -> YTTravelPlan
}

final class ConcreteWritingTravelPlanViewModel: WritingTravelPlanViewModel {
    private(set) var travelPlanTracker: YTTravelPlanTracker
    
    private(set) var title: String
    private(set) var description: String
    private(set) var schedules: CurrentValueSubject<[YTSchedule], Never> // [Schedule]이 변경되었을 때만 바인딩을 통해 업데이트를 수행
    
    private var subscriptions = Set<AnyCancellable>()
    
    var calculatedScrollViewContainerHeight: CGFloat {
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
    
    init(_ model: YTTravelPlan) {
        self.travelPlanTracker = YTTravelPlanTracker(model)
        self.title = model.title
        self.description = model.description
        self.schedules = CurrentValueSubject<[YTSchedule], Never>(model.schedules)
    }
    
    deinit {
        print("deinit: WritingTravelPlanViewModel")
    }
    
    func createSchedule(_ schedule: YTSchedule) {
        schedules.value.append(schedule)
    }
    
    func updateSchedule(at index: Int, _ schedule: YTSchedule) {
        schedules.value[index] = schedule
    }
    
    func deleteSchedule(at index: Int) {
        schedules.value.remove(at: index)
    }
    
    func swapSchedules(at source: Int, to destination: Int) {
        schedules.value.swapAt(source, destination)
    }
    
    func setTravelPlanTracker() {
        travelPlanTracker.travelPlan = YTTravelPlan(title: title,
                                                    description: description,
                                                    schedules: schedules.value)
    }
    
    func editingChangedTitleTextField(_ title: String) {
        self.title = title
    }
    
    func editingChangedDescriptionTextField(_ description: String) {
        self.description = description
    }
    
    func createTravelPlan() throws -> YTTravelPlan {
        guard title.count > 0 else { throw WritingTravelPlanError.emptyTitle }
        return YTTravelPlan(title: title, description: description, schedules: schedules.value)
    }
}
