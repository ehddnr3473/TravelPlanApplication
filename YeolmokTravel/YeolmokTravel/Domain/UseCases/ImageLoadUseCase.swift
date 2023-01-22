//
//  ImageLoadUseCase.swift
//  YeolmokTravel
//
//  Created by 김동욱 on 2023/01/22.
//

import Foundation
import UIKit

protocol ImageLoadUseCaseType {
    func upload(_ index: Int, _ image: UIImage) async throws
    func download(_ index: Int, completion: @escaping ((Result<UIImage, ImageLoadError>) -> Void))
}

struct ImageLoadUseCase: ImageLoadUseCaseType {
    private let repository = ImageRepository()
    
    func upload(_ index: Int, _ image: UIImage) async throws {
        do {
            try await repository.upload(index, image)
        } catch {
            throw error
        }
    }
    
    func download(_ index: Int, completion: @escaping ((Result<UIImage, ImageLoadError>) -> Void)) {
        repository.download(index, completion)
    }
}
