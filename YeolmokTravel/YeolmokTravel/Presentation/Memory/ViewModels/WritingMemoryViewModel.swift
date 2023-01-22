//
//  WritingMemoryViewModel.swift
//  YeolmokTravel
//
//  Created by 김동욱 on 2023/01/22.
//

import Foundation
import UIKit

final class WritingMemoryViewModel: WritingViewModelType {
    
    struct Input {
        
    }
    
    struct Output {
        
    }
    
    private let useCase = ImageLoadUseCase()
    
    func transform(input: Input) -> Output {
        
    }
    
    func upload(_ index: Int, _ image: UIImage) async throws {
        do {
            try await useCase.upload(index, image)
        } catch {
            throw error
        }
    }
}
