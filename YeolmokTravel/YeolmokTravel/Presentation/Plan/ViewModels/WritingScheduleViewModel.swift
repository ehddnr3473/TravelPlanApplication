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
    associatedtype TextInput
    associatedtype CoordinateInput
    associatedtype CoordinateOutput
    associatedtype SwitchInput
    associatedtype SwitchOutput
    associatedtype DateInput
    
    func subscribeText(_ input: TextInput)
    func transform(_ input: CoordinateInput) -> CoordinateOutput
    func transform(_ input: SwitchInput) -> SwitchOutput
    func subscribeDate(_ input: DateInput)
}

final class WritingScheduleViewModel {
    private(set) var planTracker: PlanTracker<Schedule>
    private(set) var model: Schedule
    
    private(set) var title: String
    private var description: String
    private var fromDate: Date?
    private var toDate: Date?
    private(set) var coordinate: CLLocationCoordinate2D
    
    private var subscriptions = Set<AnyCancellable>()
    
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
    
    private var verifyDate: Bool {
        guard let toDate = toDate, let fromDate = fromDate else { return true }
        return fromDate < toDate
    }
    
    init(_ model: Schedule) {
        self.model = model
        self.planTracker = PlanTracker(model)
        self.title = model.title
        self.description = model.description
        self.fromDate = model.fromDate
        self.toDate = model.toDate
        self.coordinate = model.coordinate
    }
    
    deinit {
        print("deinit: WritingScheduleViewModel")
    }
    
    func setSchedule() throws {
        if title == "" {
            throw ScheduleError.titleError
        } else if !verifyDate {
            throw ScheduleError.preToDateError
        } else if fromDate == nil && toDate != nil {
            throw ScheduleError.fromDateError
        } else if fromDate != nil && toDate == nil {
            throw ScheduleError.toDateError
        } else {
            model.setSchedule(title, description, coordinate, fromDate, toDate)
        }
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
    struct TextInput {
        let title: AnyPublisher<String, Never>
        let description: PassthroughSubject<String, Never>
    }
    
    // Coordinate
    struct CoordinateInput {
        let latitude: AnyPublisher<String, Never>
        let longitude: AnyPublisher<String, Never>
    }
    
    struct CoordinateOutput {
        let buttonState: AnyPublisher<Bool, Never>
    }
    
    // UISwitch
    struct SwitchInput {
        let switchIsOnPublisher: AnyPublisher<Bool, Never>
    }
    
    struct SwitchOutput {
        let datePickerStatePublisher: AnyPublisher<Bool, Never>
    }
    
    // UIDatePicker
    struct DateInput {
        let fromDatePublisher: AnyPublisher<Date, Never>
        let toDatePublisher: AnyPublisher<Date, Never>
    }
    
    struct DateOutput {
        let isVaildDatePublisher: AnyPublisher<Bool, Never>
    }
    
    /// UITextField
    /// - Parameter input: Title, Description text publisher
    /// - Operation: Subscribe view's value - titleTextField.text, descriptionTextField.text
    func subscribeText(_ input: TextInput) {
        input.title
            .sink { [weak self] titleText in
                self?.title = titleText
            }
            .store(in: &subscriptions)
        
        input.description
            .sink { [weak self] descriptionText in
                self?.description = descriptionText
            }
            .store(in: &subscriptions)
    }
    
    /// Coordinate TextFIelds <-> Show Map UIButton
    /// - Parameter input: Coordinate Text Publisher
    /// - Returns: UIButton - isEnabled Publisher
    func transform(_ input: CoordinateInput) -> CoordinateOutput {
        let buttonStatePublisher = input.latitude.combineLatest(input.longitude)
            .map { [weak self] latitude, longitude in
                guard let latitude = Double(latitude),
                        let longitude = Double(longitude),
                        CLLocationCoordinate2DIsValid(CLLocationCoordinate2D(latitude: latitude, longitude: longitude)) else { return false }
                self?.coordinate.latitude = latitude
                self?.coordinate.longitude = longitude
                return CLLocationCoordinate2DIsValid(CLLocationCoordinate2D(latitude: latitude, longitude: longitude))
            }
            .eraseToAnyPublisher()
        
        return CoordinateOutput(buttonState: buttonStatePublisher)
    }
    
    /// UISwitch <-> UIDatePicker
    /// - Parameter input: UISwitch IsOn Publisher
    /// - Returns: UIDatePicker - isEnabled, UIDatePicker - backgroundColor Publisher
    func transform(_ input: SwitchInput) -> SwitchOutput {
        let datePickerStatePublisher = input.switchIsOnPublisher
            .map { [weak self] in
                if $0 {
                    return true
                } else {
                    self?.fromDate = nil
                    self?.toDate = nil
                    return false
                }
            }
            .eraseToAnyPublisher()
        
        return SwitchOutput(datePickerStatePublisher: datePickerStatePublisher)
    }
    
    /// UIDatePicker
    /// - Parameter input: UIDatePicker Date Publisher
    /// - Operation: Subscribe view's value - fromDatePicker.date, toDatePicker.date
    func subscribeDate(_ input: DateInput) {
        input.fromDatePublisher
            .sink { [weak self] fromDate in
                self?.fromDate = fromDate
            }
            .store(in: &subscriptions)
        
        input.toDatePublisher
            .sink { [weak self] toDate in
                self?.toDate = toDate
            }
            .store(in: &subscriptions)
    }
}

enum ScheduleError: Error {
    case titleError
    case preToDateError
    case fromDateError
    case toDateError
}
