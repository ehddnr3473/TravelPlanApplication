//
//  WritingScheduleViewModel.swift
//  YeolmokTravel
//
//  Created by 김동욱 on 2023/02/03.
//

import Foundation
import Combine
import UIKit

private protocol WritingScheduleViewModelType {
    associatedtype TitleInput
    associatedtype TitleOutput
    associatedtype SwitchInput
    associatedtype SwitchOutput
}

final class WritingScheduleViewModel {
    deinit {
        print("deinit: WritingPlanViewModel")
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
    
    
    /// UITextField <-> Save UIButton
    /// - Parameter input: Title Text Publisher
    /// - Returns: UIButton - isEnabled Publisher
    func transform(input: TitleInput) -> TitleOutput {
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
}
