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

final class WritingScheduleViewModel: WritingScheduleViewModelType {
    private(set) var coordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(), longitude: CLLocationDegrees())
    
    deinit {
        print("deinit: WritingScheduleViewModel")
    }
    
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
            .map { combinedValue in
                guard let latitude = Double(combinedValue.0), let longitude = Double(combinedValue.1) else { return false }
                self.coordinate.latitude = latitude
                self.coordinate.longitude = longitude
                return CLLocationCoordinate2DIsValid(CLLocationCoordinate2D(latitude: latitude, longitude: longitude))
            }
            .eraseToAnyPublisher()
        
        return CoordinateOutput(buttonState: buttonStatePublisher)
    }
}
