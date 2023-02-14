//
//  MemoryImageRepository.swift
//  YeolmokTravel
//
//  Created by 김동욱 on 2022/12/24.
//

import Foundation
import UIKit
import FirebaseStorage

enum MemoryImageRepositoryError: String, Error {
    case uploadError = "이미지 업로드를 실패했습니다."
    case readError = "이미지 다운로드를 실패했습니다."
    case deleteError = "이미지 삭제를 실패했습니다."
}

protocol AbstractMemoryImageRepository: AnyObject {
    func upload(at index: Int, _ image: UIImage) async throws
    func read(_ index: Int, _ completion: @escaping ((Result<UIImage, MemoryImageRepositoryError>) -> Void))
    func delete(_ index: Int) async throws
}

/// Firebase Storage 서비스를 사용
/// 이미지를 다운로드하고 캐시 전략 적용
final class MemoryImageRepository: AbstractMemoryImageRepository {
    private var cachedImages = [String: UIImage]()
    private let storageReference: StorageReference
    
    init() {
        let storage = Storage.storage()
        self.storageReference = storage.reference()
    }
    
    private func cachedImage(_ index: Int) -> UIImage? {
        if let image = cachedImages["\(index)"] {
            return image
        } else {
            return nil
        }
    }
    
    private func cacheImage(_ index: Int, image: UIImage) {
        cachedImages["\(index)"] = image
    }
    
    func upload(at index: Int, _ image: UIImage) async throws {
        if let data = image.pngData() {
            let imageReference = storageReference.child("\(DocumentConstants.memoriesPath)/\(index)")
            do {
                let _ = try await imageReference.putDataAsync(data)
                // using metadata
            } catch {
                throw MemoryImageRepositoryError.uploadError
            }
        }
    }
    
    /// 이미지 다운로드 함수
    /// - Parameters:
    ///   - index: Memories에서 Memory의 index이자, 이미지의 이름
    ///   - completion: UIImage publish
    func read(_ index: Int, _ completion: @escaping ((Result<UIImage, MemoryImageRepositoryError>) -> Void)) {
        if let image = cachedImage(index) {
            completion(.success(image))
            return
        }
        
        let imageReference = storageReference.child("\(DocumentConstants.memoriesPath)/\(index)")
        imageReference.getData(maxSize: .max) { data, error in
            if error != nil {
                completion(.failure(MemoryImageRepositoryError.readError))
                return
            }
            if let data = data {
                guard let image = UIImage(data: data) else {
                    completion(.failure(MemoryImageRepositoryError.readError))
                    return
                }
                self.cacheImage(index, image: image)
                completion(.success(image))
                return
            } else {
                completion(.failure(MemoryImageRepositoryError.readError))
                return
            }
        }
    }
    
    func delete(_ index: Int) async throws {
        let reference = storageReference.child("\(index)")
        do {
            try await reference.delete()
        } catch {
            throw MemoryImageRepositoryError.deleteError
        }
    }
}

private enum DocumentConstants {
    static let memoriesPath = "memories"
}
