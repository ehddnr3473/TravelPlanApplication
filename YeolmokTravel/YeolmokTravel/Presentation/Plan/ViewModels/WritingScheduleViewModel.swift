//
//  WritingScheduleViewModel.swift
//  YeolmokTravel
//
//  Created by 김동욱 on 2023/02/03.
//

import Foundation
import Combine
import CoreLocation

enum ScheduleError: String, Error {
    case titleError = "제목을 입력해주세요."
    case preToDateError = "시작 날짜가 종료 날짜 이후입니다."
    case fromDateError = "From 날짜를 선택해주세요."
    case toDateError = "To 날짜를 선택해주세요."
    case coordinateError = "유효하지 않은 좌표입니다."
}

private protocol WritingScheduleViewModel: AnyObject {
    // Input
    func setScheduleTracker() // scheduleTracker.schedule set
    
    // Output
    func isValidSave(_ latitude: String, _ longitude: String) throws
}

final class ConcreteWritingScheduleViewModel: WritingScheduleViewModel {
    private(set) var model: Schedule
    private(set) var scheduleTracker: ScheduleTracker
    
    private var subscriptions = Set<AnyCancellable>()
    
    private var verifyPreFromDate: Bool {
        guard let toDate = model.toDate,
              let fromDate = model.fromDate,
              let slicedFromDate = DateConverter.stringToDate(DateConverter.dateToString(fromDate)),
              let slicedToDate = DateConverter.stringToDate(DateConverter.dateToString(toDate)) else { return true }
        return slicedFromDate <= slicedToDate
    }
    
    init(_ model: Schedule) {
        self.model = model
        self.scheduleTracker = ScheduleTracker(model)
    }
    
    deinit {
        print("deinit: WritingScheduleViewModel")
    }
    
    func setScheduleTracker() {
        scheduleTracker.schedule = model
    }
    
    func setCoordinate(_ latitude: String, _ longitude: String) {
        guard let latitude = Double(latitude),
              let longitude = Double(longitude),
              CLLocationCoordinate2DIsValid(CLLocationCoordinate2D(latitude: latitude, longitude: longitude)) else { return }
        model.coordinate.latitude = latitude
        model.coordinate.longitude = longitude
    }
    
    func isValidSave(_ latitude: String, _ longitude: String) throws {
        if model.title == "" {
            throw ScheduleError.titleError
        } else if !verifyPreFromDate {
            throw ScheduleError.preToDateError
        } else if model.fromDate == nil && model.toDate != nil {
            throw ScheduleError.fromDateError
        } else if model.fromDate != nil && model.toDate == nil {
            throw ScheduleError.toDateError
        } else if !isValidCoordinate(latitude, longitude) {
            throw ScheduleError.coordinateError
        }
    }
    
    func isValidCoordinate(_ latitude: String, _ longitude: String) -> Bool {
        guard let latitude = Double(latitude) else { return false }
        guard let longitude = Double(longitude) else { return false }
        guard CLLocationCoordinate2DIsValid(
            CLLocationCoordinate2D(latitude: latitude,longitude: longitude)
        ) else { return false }
        return true
    }
    
    func toggledSwitch(_ isOn: Bool, _ fromDate: Date, _ toDate: Date) {
        if isOn {
            model.fromDate = fromDate
            model.toDate = toDate
        } else {
            model.fromDate = nil
            model.toDate = nil
        }
    }
    
    func editingChangedTitleTextField(_ title: String) {
        model.title = title
    }
    
    func didChangeDescriptionTextView(_ description: String) {
        model.description = description
    }
    
    func editingChangedCoordinateTextField(_ latitude: String, _ longitude: String) -> Bool {
        guard isValidCoordinate(latitude, longitude) else { return false }
        guard let latitude = Double(latitude), let longitude = Double(longitude) else { return false }
        model.coordinate.latitude = latitude
        model.coordinate.longitude = longitude
        return true
    }
    
    func valueChangedFromDatePicker(_ date: Date) {
        model.fromDate = date
    }
    
    func valueChangedToDatePicker(_ date: Date) {
        model.toDate = date
    }
}
