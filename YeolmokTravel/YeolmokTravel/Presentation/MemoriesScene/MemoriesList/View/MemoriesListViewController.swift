//
//  MemoryView.swift
//  YeolmokTravel
//
//  Created by 김동욱 on 2022/12/23.
//

import UIKit
import Combine
import Domain
import FirebasePlatform

protocol MemoryTransferDelegate: AnyObject {
    func create(_ memory: Memory)
}

protocol MemoryCellErrorDelegate: AnyObject {
    func errorDidOccurrued(_ message: String)
}

final class MemoriesListViewController: UIViewController {
    @frozen enum Section: CaseIterable {
        case main
    }
    // MARK: - Properties
    private let viewModel: MemoriesListViewModel
    private weak var coordinator: MemoriesWriteFlowCoordinator?
    private var subscriptions = Set<AnyCancellable>()
    private let memoriesUseCaseProvider: MemoriesUseCaseProvider
    private let imagesUseCaseProvider: ImagesUseCaseProvider
    private var dataSource: UICollectionViewDiffableDataSource<Section, Memory>!
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .white
        label.text = TextConstants.title
        label.font = .boldSystemFont(ofSize: AppLayoutConstants.titleFontSize)
        return label
    }()
    
    private let createButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setBackgroundImage(UIImage(systemName: TextConstants.plusIconName), for: .normal)
        button.tintColor = AppStyles.mainColor
        return button
    }()
    
    private lazy var memoriesCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: createCompositionalLayout())
        collectionView.backgroundColor = .systemBackground
        collectionView.showsVerticalScrollIndicator = false
        return collectionView
    }()
    
    // MARK: - Init
    init(viewModel: MemoriesListViewModel,
         coordinator: MemoriesWriteFlowCoordinator,
         memoriesUseCaseProvider: MemoriesUseCaseProvider,
         imagesUseCaseProvider: ImagesUseCaseProvider) {
        self.viewModel = viewModel
        self.coordinator = coordinator
        self.memoriesUseCaseProvider = memoriesUseCaseProvider
        self.imagesUseCaseProvider = imagesUseCaseProvider
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        configureAction()
        configureDataSource()
        bind()
        fetchMemories()
    }
    
    // MARK: - Private
    private func fetchMemories() {
        Task {
            do {
                try await viewModel.read()
            } catch {
                guard let error = error as? MemoriesRepositoryError else { return }
                alertWillAppear(error.rawValue)
            }
        }
    }
    
    private func bind() {
        viewModel.memories
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.apply()
            }
            .store(in: &subscriptions)
    }
}

// MARK: - Configure view
private extension MemoriesListViewController {
    func configureView() {
        view.backgroundColor = .systemBackground
        configureHierarchy()
        configureLayoutConstraint()
    }
    
    func configureHierarchy() {
        [titleLabel, createButton, memoriesCollectionView].forEach {
            view.addSubview($0)
        }
    }
    
    func configureLayoutConstraint() {
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            $0.leading.equalToSuperview()
                .inset(AppLayoutConstants.spacing)
        }
        
        createButton.snp.makeConstraints {
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
    
    func configureAction() {
        createButton.addTarget(self, action: #selector(touchUpCreateButton), for: .touchUpInside)
    }
    
    func createCompositionalLayout() -> UICollectionViewCompositionalLayout {
        let item = NSCollectionLayoutItem(
            layoutSize:
                NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(LayoutConstants.original),
                    heightDimension: .fractionalHeight(LayoutConstants.original)
                )
        )
        
        item.contentInsets = NSDirectionalEdgeInsets(
            top: LayoutConstants.inset,
            leading: .zero,
            bottom: LayoutConstants.inset,
            trailing: .zero
        )
        
        let group = NSCollectionLayoutGroup.vertical(
            layoutSize:
                NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(LayoutConstants.original),
                    heightDimension: .fractionalWidth(LayoutConstants.magnification)
                ),
            subitems: [item]
        )
        
        let section = NSCollectionLayoutSection(group: group)
        
        let layout = UICollectionViewCompositionalLayout(section: section)
        
        return layout
    }
}

// MARK: - User Interacion
private extension MemoriesListViewController {
    @objc func touchUpCreateButton() {
        coordinator?.toWriteMemory(index: self.viewModel.memories.value.count,
                                   delegate: self,
                                   memoriesUseCaseProvider,
                                   imagesUseCaseProvider)
    }
}

// MARK: - UICollectionView
private extension MemoriesListViewController {
    func configureDataSource() {
        let cellRegistration = UICollectionView.CellRegistration<MemoryCell, Memory> { [self] (cell, indexPath, _) in
            // Cell assembling of MVVM
            let viewModel = DefaultMemoryCellViewModel(viewModel.memories.value[indexPath.row], imagesUseCaseProvider)
            cell.didDequeue(with: viewModel)
            cell.delegate = self
        }
        
        dataSource = UICollectionViewDiffableDataSource<Section, Memory>(collectionView: memoriesCollectionView) { (collectionView: UICollectionView, indexPath: IndexPath, itemIdentifier: Memory) -> UICollectionViewCell? in
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: itemIdentifier)
        }
    }
    
    func apply() {
        let memories = viewModel.memories.value
        var snapshot = NSDiffableDataSourceSnapshot<Section, Memory>()
        snapshot.appendSections([.main])
        snapshot.appendItems(memories)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
}

// MARK: - MemoryTransferDelegate
extension MemoriesListViewController: MemoryTransferDelegate {
    func create(_ memory: Memory) {
        viewModel.create(memory)
    }
}

// MARK: - MemoryCellErrorDelegate
extension MemoriesListViewController: MemoryCellErrorDelegate {
    func errorDidOccurrued(_ message: String) {
        alertWillAppear(message)
    }
}

// MARK: - Magic number/string
private extension MemoriesListViewController {
    @frozen enum LayoutConstants {
        static let buttonSize = CGSize(width: 44.44, height: 44.44)
        static let memoriesCollectionViewTopOffset: CGFloat = 20
        static let memoriesCollectionViewWidthMultiplier: CGFloat = 0.9
        static let inset: CGFloat = 10
        static let original: CGFloat = 1.0
        static let magnification: CGFloat = 1.3
    }
    
    @frozen enum TextConstants {
        static let title = "Memories"
        static let plusIconName = "plus"
    }
}
