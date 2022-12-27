//
//  ImageLoader.swift
//  YeolmokTravel
//
//  Created by 김동욱 on 2022/12/24.
//

import Foundation
import UIKit
import FirebaseStorage

/// Firebase Storage 서비스를 사용
/// 이미지를 다운로드하고 캐시 전략 적용
final class ImageLoader {
    private var cachedImages = [String: UIImage]()
    private let storageReference: StorageReference
    
    init() {
        let storage = Storage.storage()
        self.storageReference = storage.reference()
    }
    
    func cachedImage(_ index: Int) -> UIImage? {
        if let image = cachedImages["\(index)"] {
            return image
        } else {
            return nil
        }
    }
    
    func cacheImage(_ index: Int, image: UIImage) {
        cachedImages["\(index)"] = image
    }
    
    func upload(_ index: Int, _ image: UIImage) async {
        if let data = image.pngData() {
            let imageReference = storageReference.child("\(DocumentConstants.memoriesPath)/\(index)")
            do {
                let _ = try await imageReference.putDataAsync(data)
                // using metadata
            } catch {
                print(error)
            }
        }
    }
    
    /// 이미지 다운로드 함수
    /// - Parameters:
    ///   - index: Memories에서 Memory의 index이자, 이미지의 이름
    ///   - completion: UIImage publish
    func download(_ index: Int, _ completion: @escaping ((UIImage?) -> Void)) {
        if let image = cachedImage(index) {
            completion(image)
            return
        }
        
        let imageReference = storageReference.child("\(DocumentConstants.memoriesPath)/\(index)")
        imageReference.getData(maxSize: .max) { data, error in
            if let error = error {
                print(error)
            }
            if let data = data {
                let image = UIImage(data: data)
                self.cacheImage(index, image: image!)
                completion(image)
                return
            } else {
                completion(nil)
                return
            }
        }
    }
}

private enum DocumentConstants {
    static let memoriesPath = "memories"
}
