//
//  WritingTravelViewModel.swift
//  YeolmokTravel
//
//  Created by 김동욱 on 2023/01/24.
//

import Foundation
import Combine

final class WritingPlanViewModel: WritingViewModelType {
    struct Input {
        let title: AnyPublisher<String, Never>
    }
    
    struct Output {
        let buttonState: AnyPublisher<Bool, Never>
    }
    
    func transform(input: Input) -> Output {
        let buttonStatePublisher = input.title
            .map { $0.count > 0 }
            .eraseToAnyPublisher()
        
        return Output(buttonState: buttonStatePublisher)
    }
}
