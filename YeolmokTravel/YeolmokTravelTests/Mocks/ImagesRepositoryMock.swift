//
//  ImagesRepositoryMock.swift
//  YeolmokTravelTests
//
//  Created by 김동욱 on 2023/02/27.
//

import XCTest
import Foundation
import UIKit

import protocol Domain.ImagesRepository

final class ImagesRepositoryMock: ImagesRepository {
    var error: Error?
    var images: [UIImage] = [
        UIImage(systemName: "0.circle")!,
        UIImage(systemName: "1.circle")!,
        UIImage(systemName: "2.circle")!
    ]
    
    func upload(key: String, _ image: UIImage) async throws {
        images.insert(image, at: Int(key)!)
    }
    
    func read(key: String, _ completion: @escaping ((Result<UIImage, Error>) -> Void)) {
        if let error = error {
            completion(.failure(error))
        } else {
            completion(.success(images[Int(key)!]))
        }
    }
    
    func delete(key: String) async throws {
        images.remove(at: Int(key)!)
    }
}
