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
    func createSchedule(_ schedule: Schedule)
    func updateSchedule(at index: Int, _ schedule: Schedule)
    func deleteSchedule(at index: Int)
    func swapSchedules(at source: Int, to destination: Int)
    func setTravelPlanTracker(_ title: String, _ description: String)
    
    // Output
    var calculateScrollViewContainerHeight: CGFloat { get }
    func isValidSave(_ title: String) throws
}

final class ConcreteWritingTravelPlanViewModel: WritingTravelPlanViewModel {
    private(set) var travelPlanTracker: TravelPlanTracker
    
    private(set) var title: String
    private(set) var description: String
    private(set) var schedules: CurrentValueSubject<[Schedule], Never>
    
    private var subscriptions = Set<AnyCancellable>()
    
    var calculateScrollViewContainerHeight: CGFloat {
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
    
    init(_ model: TravelPlan) {
        self.travelPlanTracker = TravelPlanTracker(model)
        self.title = model.title
        self.description = model.description
        self.schedules = CurrentValueSubject<[Schedule], Never>(model.schedules)
    }
    
    deinit {
        print("deinit: WritingTravelPlanViewModel")
    }
    
    func createSchedule(_ schedule: Schedule) {
        schedules.value.append(schedule)
    }
    
    func updateSchedule(at index: Int, _ schedule: Schedule) {
        schedules.value[index] = schedule
    }
    
    func deleteSchedule(at index: Int) {
        schedules.value.remove(at: index)
    }
    
    func swapSchedules(at source: Int, to destination: Int) {
        schedules.value.swapAt(source, destination)
    }
    
    func setTravelPlanTracker(_ title: String, _ description: String) {
        travelPlanTracker.travelPlan = TravelPlan(title: title,
                                                  description: description,
                                                  schedules: schedules.value)
    }
    
    func isValidSave(_ title: String) throws {
        guard title.count > 0 else { throw WritingTravelPlanError.emptyTitle }
    }
}
