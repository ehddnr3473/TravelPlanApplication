//
//  ImagesRepositoryMock.swift
//  YeolmokTravelTests
//
//  Created by 김동욱 on 2023/02/27.
//

import XCTest
import Foundation
import UIKit
import Domain

final class ImagesRepositoryMock: ImagesRepository {
    var expectation: XCTestExpectation?
    var error: Error?
    var images: [UIImage] = [
        UIImage(systemName: "0.circle")!,
        UIImage(systemName: "1.circle")!,
        UIImage(systemName: "2.circle")!
    ]
    
    func upload(at index: Int, _ image: UIImage) async throws {
        images.insert(image, at: index)
    }
    
    func read(at index: Int, _ completion: @escaping ((Result<UIImage, Error>) -> Void)) {
        if let error = error {
            completion(.failure(error))
        } else {
            completion(.success(images[index]))
        }
        expectation?.fulfill()
    }
    
    func delete(at index: Int) async throws {
        images.remove(at: index)
    }
}
