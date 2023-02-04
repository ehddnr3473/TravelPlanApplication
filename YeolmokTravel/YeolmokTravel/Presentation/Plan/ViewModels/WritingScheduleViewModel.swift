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
    associatedtype TextOutput
    associatedtype CoordinateInput
    associatedtype CoordinateOutput
    associatedtype SwitchInput
    associatedtype SwitchOutput
    associatedtype DateInput
    associatedtype DateOutput
    
    func transform(_ input: TextInput) -> TextOutput
    func transform(_ input: CoordinateInput) -> CoordinateOutput
    func transform(_ input: SwitchInput) -> SwitchOutput
    func transform(_ input: DateInput) -> DateOutput
}

final class WritingScheduleViewModel {
    private(set) var planTracker: PlanTracker<Schedule>
    private(set) var model: Schedule
    
    private var title: String
    private var description: String
    private var fromDate: Date?
    private var toDate: Date?
    private(set) var coordinate: CLLocationCoordinate2D
    
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
            throw AlertError.titleError
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
        let description: CurrentValueSubject<String, Never>
    }
    
    struct TextOutput {
        let buttonState: AnyPublisher<Bool, Never>
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
    
    // UISwitch
    struct SwitchInput {
        let statePublisher: AnyPublisher<Bool, Never>
    }
    
    struct SwitchOutput {
        let datePickerStatePublisher: AnyPublisher<Bool, Never>
        let backgroundColorPublisher: AnyPublisher<UIColor, Never>
    }
    
    // UIDatePicker
    struct DateInput {
        let fromDatePublisher: AnyPublisher<Date, Never>
        let toDatePublisher: AnyPublisher<Date, Never>
    }
    
    struct DateOutput {
        let isVaildDatePublisher: AnyPublisher<Bool, Never>
    }
    
    /// UITextField <-> Save UIButton
    /// - Parameter input: Title Text Publisher
    /// - Returns: UIButton - isEnabled Publisher
    func transform(_ input: TextInput) -> TextOutput {
        let buttonStatePublisher = input.title.combineLatest(input.description)
            .map { [weak self] combinedValue in
                self?.title = combinedValue.0
                self?.description = combinedValue.1
                if combinedValue.0.count > 0 && combinedValue.1.count > 0 {
                    return true
                } else {
                    return false
                }
            }
            .eraseToAnyPublisher()
        
        let backgroundColorPublisher = input.title.combineLatest(input.description)
            .map { combinedValue in
                if combinedValue.0.count > 0 && combinedValue.1.count > 0 {
                    return UIColor.systemGreen
                } else {
                    return UIColor.systemGray
                }
            }
            .eraseToAnyPublisher()
        
        return TextOutput(buttonState: buttonStatePublisher, backgroundColorPublisher: backgroundColorPublisher)
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
    
    /// UISwitch <-> UIDatePicker
    /// - Parameter input: UISwitch IsOn Publisher
    /// - Returns: UIDatePicker - isEnabled, UIDatePicker - backgroundColor Publisher
    func transform(_ input: SwitchInput) -> SwitchOutput {
        let statePublisher = input.statePublisher
        
        let backgroundColorPublisher = statePublisher
            .map { [weak self] in
                if $0 {
                    return UIColor.white
                } else {
                    self?.fromDate = nil
                    self?.toDate = nil
                    return UIColor.systemGray
                }
            }
            .eraseToAnyPublisher()
        
        return SwitchOutput(datePickerStatePublisher: statePublisher, backgroundColorPublisher: backgroundColorPublisher)
    }
    
    /// UIDatePicker <-> fromDate, toDate
    /// - Parameter input: UIDatePicker Date Publisher
    /// - Returns: isValid Date Publisher
    func transform(_ input: DateInput) -> DateOutput {
        let dateCombineLatest = input.fromDatePublisher.combineLatest(input.toDatePublisher)
            .map { [weak self] combinedValue in
                if combinedValue.0 > combinedValue.1 {
                    return false
                } else {
                    self?.fromDate = combinedValue.0
                    self?.toDate = combinedValue.1
                    return true
                }
            }
            .eraseToAnyPublisher()
        
        return DateOutput(isVaildDatePublisher: dateCombineLatest)
    }
}
