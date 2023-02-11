//
//  MemoryImageUploadUseCase.swift
//  YeolmokTravel
//
//  Created by 김동욱 on 2023/02/11.
//

import Foundation
import UIKit

protocol MemoryImageUploadUseCase: AnyObject {
    func execute(at index: Int, _ image: UIImage) async throws
}

final class ConcreteMemoryImageUploadUseCase: MemoryImageUploadUseCase {
    private let repository: AbstractMemoryImageRepository
    
    init(_ repository: AbstractMemoryImageRepository) {
        self.repository = repository
    }
    
    func execute(at index: Int, _ image: UIImage) async throws {
        try await repository.upload(at: index, image)
    }
}
