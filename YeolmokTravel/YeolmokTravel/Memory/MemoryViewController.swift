//
//  MemoryView.swift
//  YeolmokTravel
//
//  Created by 김동욱 on 2022/12/23.
//

import UIKit

final class MemoryViewController: UIViewController, MemoryTransfer {
    // MARK: - Properties
    var model: Memories!
    private let imageLoader = ImageLoader()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        
        label.textAlignment = .center
        label.textColor = .white
        label.text = TextConstants.title
        label.font = .boldSystemFont(ofSize: AppStyles.titleFontSize)
        
        return label
    }()
    
    private lazy var addButton: UIButton = {
        let button = UIButton(type: .custom)
        
        button.setBackgroundImage(UIImage(systemName: TextConstants.plusIconName), for: .normal)
        button.tintColor = AppStyles.mainColor
        button.addTarget(self, action: #selector(touchUpAddButton), for: .touchUpInside)
        
        return button
    }()
    
    private lazy var memoriesCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: createCompositionalLayout())
        collectionView.register(MemoriesCollectionViewCell.self, forCellWithReuseIdentifier: MemoriesCollectionViewCell.identifier)
        collectionView.backgroundColor = .black
        collectionView.showsVerticalScrollIndicator = false
        return collectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
        configure()
    }
}

// MARK: - SetUp View
extension MemoryViewController {
    private func setUpUI() {
        view.backgroundColor = .black
        setUpHierachy()
        setUpLayout()
    }
    
    private func setUpHierachy() {
        [titleLabel, addButton, memoriesCollectionView].forEach {
            view.addSubview($0)
        }
    }
    
    private func setUpLayout() {
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            $0.leading.equalToSuperview()
                .inset(LayoutConstants.spacing)
        }
        
        addButton.snp.makeConstraints {
            $0.centerY.equalTo(titleLabel.snp.centerY)
            $0.trailing.equalToSuperview()
                .inset(LayoutConstants.spacing)
            $0.size.equalTo(LayoutConstants.buttonSize)
        }
        
        memoriesCollectionView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(titleLabel.snp.bottom)
                .offset(LayoutConstants.memoriesCollectionViewTopOffset)
            $0.width.equalToSuperview()
                .multipliedBy(LayoutConstants.memoriesCollectionViewWidthMultiplier)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
                .inset(LayoutConstants.spacing)
        }
    }
    
    private func configure() {
        memoriesCollectionView.dataSource = self
    }
    
    private func createCompositionalLayout() -> UICollectionViewCompositionalLayout {
        let item = NSCollectionLayoutItem(layoutSize:
                                            NSCollectionLayoutSize(widthDimension: .fractionalWidth(LayoutConstants.original),
                                                                   heightDimension: .fractionalHeight(LayoutConstants.original)))
        item.contentInsets = NSDirectionalEdgeInsets(top: LayoutConstants.inset, leading: .zero, bottom: LayoutConstants.inset, trailing: .zero)
        
        let group = NSCollectionLayoutGroup.vertical(layoutSize:
                                                        NSCollectionLayoutSize(widthDimension: .fractionalWidth(LayoutConstants.original),
                                                                               heightDimension: .fractionalWidth(LayoutConstants.magnification)), subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        
        let layout = UICollectionViewCompositionalLayout(section: section)
        
        return layout
    }
    
    @MainActor
    private func reload() {
        memoriesCollectionView.reloadData()
    }
    
    @objc func touchUpAddButton() {
        let writingMemoryViewController = WritingMemoryViewController()
        writingMemoryViewController.addDelegate = self
        writingMemoryViewController.memoryIndex = model.memories.count
        writingMemoryViewController.modalPresentationStyle = .fullScreen
        present(writingMemoryViewController, animated: true)
    }
    // task말고 await 처리해서 해결
    func memoryHandler(_ image: UIImage, _ memory: Memory) async {
        model.add(memory)
        await imageLoader.upload(memory.index, image)
        await model.write(at: memory.index)
        reload()
    }
}

// MARK: - CollectionView
extension MemoryViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // Cell assembling of MVVM
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MemoriesCollectionViewCell.identifier, for: indexPath) as? MemoriesCollectionViewCell else { return UICollectionViewCell() }
        let viewModel = MemoriesLoader(model.memories[indexPath.row], imageLoader)
        cell.setViewModel(viewModel)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        model.memories.count
    }
}

private enum TextConstants {
    static let title = "Memories"
    static let plusIconName = "plus"
}

private enum LayoutConstants {
    static let spacing: CGFloat = 8
    static let buttonSize = CGSize(width: 44.44, height: 44.44)
    static let memoriesCollectionViewTopOffset: CGFloat = 20
    static let memoriesCollectionViewWidthMultiplier: CGFloat = 0.9
    static let inset: CGFloat = 10
    static let original: CGFloat = 1.0
    static let magnification: CGFloat = 1.3
}
