//
//  WritingScheduleViewModel.swift
//  YeolmokTravel
//
//  Created by 김동욱 on 2023/02/03.
//

import Foundation
import Combine
import UIKit
import CoreLocation

private protocol WritingScheduleViewModelType: AnyObject {
    associatedtype TitleInput
    associatedtype TitleOutput
    associatedtype SwitchInput
    associatedtype SwitchOutput
    associatedtype CoordinateInput
    associatedtype CoordinateOutput
}

final class WritingScheduleViewModel {
    private(set) var planTracker: PlanTracker<Schedule>
    private(set) var model: Schedule
    
    private var title = ""
    private var description = ""
    private var fromDate: Date?
    private var toDate: Date?
    private(set) var coordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(), longitude: CLLocationDegrees())
    
    var modelTitle: String {
        model.title
    }
    
    var modelDescription: String {
        model.description
    }
    
    var modelFromDate: Date? {
        model.fromDate
    }
    
    var modelToDate: Date? {
        model.toDate
    }
    
    var modelLatitude: CLLocationDegrees {
        model.coordinate.latitude
    }
    
    var modelLongitude: CLLocationDegrees {
        model.coordinate.longitude
    }
    
    init(_ model: Schedule) {
        self.model = model
        self.planTracker = PlanTracker(model)
    }
    
    deinit {
        print("deinit: WritingScheduleViewModel")
    }
    
    func setSchedule() {
        model.setSchedule(title, description, coordinate, fromDate, toDate)
    }
    
    func setPlan() {
        planTracker.setPlan(Schedule(title: title,
                                     description: description,
                                     coordinate: coordinate,
                                     fromDate: fromDate,
                                     toDate: toDate))
    }
}

extension WritingScheduleViewModel: WritingScheduleViewModelType {
    // Title UITextField
    struct TitleInput {
        let title: AnyPublisher<String, Never>
    }
    
    struct TitleOutput {
        let buttonState: AnyPublisher<Bool, Never>
    }
    
    // UISwitch
    struct SwitchInput {
        let statePublisher: AnyPublisher<Bool, Never>
    }
    
    struct SwitchOutput {
        let datePickerStatePublisher: AnyPublisher<Bool, Never>
        let backgroundColorPublisher: AnyPublisher<UIColor, Never>
    }
    
    // Coordinate
    struct CoordinateInput {
        let latitude: AnyPublisher<String, Never>
        let longitude: AnyPublisher<String, Never>
    }
    
    struct CoordinateOutput {
        let buttonState: AnyPublisher<Bool, Never>
    }
    
    /// UITextField <-> Save UIButton
    /// - Parameter input: Title Text Publisher
    /// - Returns: UIButton - isEnabled Publisher
    func transform(_ input: TitleInput) -> TitleOutput {
        let buttonStatePublisher = input.title
            .map { $0.count > 0 }
            .eraseToAnyPublisher()
        
        return TitleOutput(buttonState: buttonStatePublisher)
    }
    
    /// UISwitch <-> UIDatePicker
    /// - Parameter input: UISwitch IsOn Publisher
    /// - Returns: UIDatePicker - isEnabled, UIDatePicker - backgroundColor Publisher
    func transform(_ input: SwitchInput) -> SwitchOutput {
        let statePublisher = input.statePublisher
            .eraseToAnyPublisher()
        
        let backgroundColorPublisher = statePublisher
            .map {
                if $0 {
                    return UIColor.white
                } else {
                    return UIColor.systemGray
                }
            }
            .eraseToAnyPublisher()
        
        return SwitchOutput(datePickerStatePublisher: statePublisher, backgroundColorPublisher: backgroundColorPublisher)
    }
    
    /// Coordinate TextFIelds <-> Show Map UIButton
    /// - Parameter input: Coordinate Text Publisher
    /// - Returns: UIButton - isEnabled Publisher
    func transform(_ input: CoordinateInput) -> CoordinateOutput {
        let buttonStatePublisher = input.latitude.combineLatest(input.longitude)
            .map { [weak self] in
                guard let latitude = Double($0), let longitude = Double($1) else { return false }
                self?.coordinate.latitude = latitude
                self?.coordinate.longitude = longitude
                return CLLocationCoordinate2DIsValid(CLLocationCoordinate2D(latitude: latitude, longitude: longitude))
            }
            .eraseToAnyPublisher()
        
        return CoordinateOutput(buttonState: buttonStatePublisher)
    }
}
