//
//  MemoryView.swift
//  YeolmokTravel
//
//  Created by 김동욱 on 2022/12/23.
//

import UIKit
import Combine

/// Memories tab
final class MemoryViewController: UIViewController {
    // MARK: - Properties
    private let viewModel: MemoryViewModel
    private let useCaseProvider: UseCaseProvider
    private var subscriptions = Set<AnyCancellable>()
    
    init(_ viewModel: MemoryViewModel, useCaseProvider: UseCaseProvider) {
        self.viewModel = viewModel
        self.useCaseProvider = useCaseProvider
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) not implemented")
    }
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .white
        label.text = TextConstants.title
        label.font = .boldSystemFont(ofSize: AppLayoutConstants.titleFontSize)
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
        configureView()
        configure()
        setBindings()
    }
}

// MARK: - Configure View
private extension MemoryViewController {
    func configureView() {
        view.backgroundColor = .black
        configureHierarchy()
        configureLayoutConstraint()
    }
    
    func configureHierarchy() {
        [titleLabel, addButton, memoriesCollectionView].forEach {
            view.addSubview($0)
        }
    }
    
    func configureLayoutConstraint() {
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            $0.leading.equalToSuperview()
                .inset(AppLayoutConstants.spacing)
        }
        
        addButton.snp.makeConstraints {
            $0.centerY.equalTo(titleLabel.snp.centerY)
            $0.trailing.equalToSuperview()
                .inset(AppLayoutConstants.spacing)
            $0.size.equalTo(LayoutConstants.buttonSize)
        }
        
        memoriesCollectionView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(titleLabel.snp.bottom)
                .offset(LayoutConstants.memoriesCollectionViewTopOffset)
            $0.width.equalToSuperview()
                .multipliedBy(LayoutConstants.memoriesCollectionViewWidthMultiplier)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
                .inset(AppLayoutConstants.spacing)
        }
    }
    
    func configure() {
        memoriesCollectionView.dataSource = self
    }
    
    func createCompositionalLayout() -> UICollectionViewCompositionalLayout {
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
}

// MARK: - User Interacion
private extension MemoryViewController {
    @MainActor
    func reload() {
        memoriesCollectionView.reloadData()
    }
    
    @objc func touchUpAddButton() {
        let viewModel = WritingMemoryViewModel(imagePostsUseCase: useCaseProvider.createImagePostsUseCase(),
                                               memoryPostsUseCase: useCaseProvider.createMemoryPostsUseCase())
        let writingMemoryViewController = WritingMemoryViewController()
        writingMemoryViewController.viewModel = viewModel
        writingMemoryViewController.memoryIndex = self.viewModel.count
        writingMemoryViewController.addDelegate = self
        writingMemoryViewController.modalPresentationStyle = .fullScreen
        present(writingMemoryViewController, animated: true)
    }
    
    func setBindings() {
        viewModel.reloadPublisher
            .sink { [weak self] _ in
                self?.reload()
            }
            .store(in: &subscriptions)
    }
}

// MARK: - CollectionView
extension MemoryViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // Cell assembling of MVVM
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MemoriesCollectionViewCell.identifier, for: indexPath) as? MemoriesCollectionViewCell, let model = viewModel.memory(indexPath.row) else { return UICollectionViewCell() }
        let viewModel = ImageLoader(model, useCaseProvider.createImagePostsUseCase())
        cell.setViewModel(viewModel)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.count
    }
}

protocol MemoryTransfer {
    func writingHandler(_ memory: Memory)
}

extension MemoryViewController: MemoryTransfer {
    func writingHandler(_ memory: Memory) {
        viewModel.add(memory)
    }
}

private enum TextConstants {
    static let title = "Memories"
    static let plusIconName = "plus"
}

private enum LayoutConstants {
    static let buttonSize = CGSize(width: 44.44, height: 44.44)
    static let memoriesCollectionViewTopOffset: CGFloat = 20
    static let memoriesCollectionViewWidthMultiplier: CGFloat = 0.9
    static let inset: CGFloat = 10
    static let original: CGFloat = 1.0
    static let magnification: CGFloat = 1.3
}
