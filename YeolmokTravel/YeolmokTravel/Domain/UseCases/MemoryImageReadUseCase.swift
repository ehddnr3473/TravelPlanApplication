//
//  MemoryImageReadUseCase.swift
//  YeolmokTravel
//
//  Created by 김동욱 on 2023/02/11.
//

import Foundation
import UIKit

protocol MemoryImageReadUseCase: AnyObject {
    func execute(at index: Int, completion: @escaping ((Result<UIImage, MemoryImageRepositoryError>) -> Void))
}

final class ConcreteMemoryImageReadUseCase: MemoryImageReadUseCase {
    private let repository: AbstractMemoryImageRepository
    
    init(_ repository: AbstractMemoryImageRepository) {
        self.repository = repository
    }
    
    func execute(at index: Int, completion: @escaping ((Result<UIImage, MemoryImageRepositoryError>) -> Void)) {
        repository.read(index, completion)
    }
}
