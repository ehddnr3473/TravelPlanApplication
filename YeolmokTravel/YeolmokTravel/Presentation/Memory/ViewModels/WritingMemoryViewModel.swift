//
//  WritingMemoryViewModel.swift
//  YeolmokTravel
//
//  Created by 김동욱 on 2023/01/22.
//

import Foundation
import UIKit
import Combine

private protocol WritingMemoryViewModel: AnyObject {
    associatedtype Input
    associatedtype Output
    
    // Input
    func upload(_ index: Int, _ image: UIImage, _ memory: Memory) async throws
    
    func transform(input: Input) -> Output
}

final class ConcreteWritingMemoryViewModel: WritingMemoryViewModel {
    private let memoryUseCaseProvider: MemoryUseCaseProvider
    private let memoryImageUseCaseProvider: MemoryImageUseCaseProvider
    
    init(_ memoryUseCaseProvider: MemoryUseCaseProvider, _ memoryImageUseCaseProvider: MemoryImageUseCaseProvider) {
        self.memoryUseCaseProvider = memoryUseCaseProvider
        self.memoryImageUseCaseProvider = memoryImageUseCaseProvider
    }
    
    deinit {
        print("deinit: WritingMemoryViewModel")
    }
    
    func upload(_ index: Int, _ image: UIImage, _ memory: Memory) async throws {
        let memoryUploadUseCase = memoryUseCaseProvider.provideMemoryUploadUseCase()
        try await memoryUploadUseCase.execute(at: index, memory)
        
        let memoryImageUploadUseCase = memoryImageUseCaseProvider.provideMemoryImageUploadUseCase()
        try await memoryImageUploadUseCase.execute(at: index, image)
    }
}

extension ConcreteWritingMemoryViewModel {
    struct Input {
        let title: AnyPublisher<String, Never>
        let image: AnyPublisher<Bool, Never>
    }
    
    struct Output {
        let buttonState: AnyPublisher<Bool, Never>
    }
    
    func transform(input: Input) -> Output {
        let buttonStatePublisher = input.title.combineLatest(input.image)
            .map { title, image in
                title.count > 0 && image
            }
            .eraseToAnyPublisher()
        
        return Output(buttonState: buttonStatePublisher)
    }
}
