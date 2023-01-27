//
//  WritingMemoryViewModel.swift
//  YeolmokTravel
//
//  Created by 김동욱 on 2023/01/22.
//

import Foundation
import UIKit
import Combine

final class WritingMemoryViewModel: WritingViewModelType {
    
    struct Input {
        let title: AnyPublisher<String, Never>
        let image: AnyPublisher<Bool, Never>
    }
    
    struct Output {
        let buttonState: AnyPublisher<Bool, Never>
    }
    
    private let imagePostsUseCase: StoragePostsUseCase
    private let memoryPostsUseCase: FirestorePostsUseCase
    
    init(imagePostsUseCase: StoragePostsUseCase, memoryPostsUseCase: FirestorePostsUseCase) {
        self.imagePostsUseCase = imagePostsUseCase
        self.memoryPostsUseCase = memoryPostsUseCase
    }
    
    deinit {
        print("deinit: WritingMemoryViewModel")
    }
    
    func transform(input: Input) -> Output {
        let buttonStatePublisher = input.title.combineLatest(input.image)
            .map { title, image in
                title.count > 0 && image
            }
            .eraseToAnyPublisher()
        
        return Output(buttonState: buttonStatePublisher)
    }
    
    func upload(_ index: Int, _ image: UIImage, _ memory: Memory) {
        imagePostsUseCase.upload(index, image)
        memoryPostsUseCase.upload(at: index, model: memory)
    }
}
