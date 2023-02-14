//
//  ConcreteMemoryCellViewModel.swift
//  YeolmokTravel
//
//  Created by 김동욱 on 2022/12/24.
//

import Foundation
import Combine
import UIKit

private protocol MemoryCellViewModel: AnyObject {
    // Output
    var model: Memory { get }
    var uploadDate: String { get }
    func read()
    
    init(_ model: Memory, _ useCaseProvider: MemoryImageUseCaseProvider)
}

/// Memory를 Model로부터 가져와서 MemoriesCollectionViewCell에 데이터 제공
/// Model을 사용자 액션으로부터 업데이트하고 업로드 요청
final class ConcreteMemoryCellViewModel: MemoryCellViewModel {
    let model: Memory
    private let useCaseProvider: MemoryImageUseCaseProvider
    let imagePublisher = PassthroughSubject<UIImage, MemoryImageRepositoryError>()
    
    var uploadDate: String {
        DateConverter.dateToString(model.uploadDate)
    }
    
    init(_ model: Memory, _ useCaseProvider: MemoryImageUseCaseProvider) {
        self.model = model
        self.useCaseProvider = useCaseProvider
    }
    
    func read() {
        let readUseCase = useCaseProvider.provideMemoryImageReadUseCase()
        readUseCase.execute(at: model.index) { result in
            switch result {
            case .success(let image):
                self.imagePublisher.send(image)
            case .failure(let error):
                self.imagePublisher.send(completion: .failure(error))
            }
        }
    }
}
