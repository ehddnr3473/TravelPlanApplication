//
//  ImageLoader.swift
//  YeolmokTravel
//
//  Created by 김동욱 on 2022/12/24.
//

import Foundation
import UIKit
import FirebaseStorage

class ImageLoader {
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
            let imageReference = storageReference.child("memories/\(index)")
            let storageMetadata = try? await imageReference.putDataAsync(data)
            // using metadata
        }
    }
    
    func download(_ index: Int, _ completion: @escaping ((UIImage?) -> Void)) {
        if let image = cachedImage(index) {
            completion(image)
            return
        }
        
        let imageReference = storageReference.child("memories/\(index)")
        imageReference.getData(maxSize: 1*1024*1024) { data, _ in
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
