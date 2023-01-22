//
//  PostsMemoryNavigator.swift
//  YeolmokTravel
//
//  Created by 김동욱 on 2023/01/23.
//

import Foundation
import UIKit
import Combine

protocol PostsMemoryNavigable {
    func toPosts()
}

protocol MemoryTransfer: AnyObject {
    func writingHandler(_ memory: Memory)
}

final class PostsMemoryNavigator: PostsMemoryNavigable, MemoryTransfer {
    private let navigationController: UINavigationController
    private var model: Memories
    private(set) var publisher = PassthroughSubject<Void, Never>()
    
    var count: Int {
        model.memories.count
    }
    
    init(navigationController: UINavigationController, model: Memories) {
        self.navigationController = navigationController
        self.model = model
    }
    
    func memories(_ index: Int) -> Memory {
        model.memories[index]
    }
    
    func toPosts() {
        let writingMemoryViewController = WritingMemoryViewController()
        writingMemoryViewController.addDelegate = self
        writingMemoryViewController.memoryIndex = count
        writingMemoryViewController.modalPresentationStyle = .fullScreen
        navigationController.present(writingMemoryViewController, animated: true)
    }
    
    func writingHandler(_ memory: Memory) {
        model.add(memory)
        publisher.send()
    }
}
