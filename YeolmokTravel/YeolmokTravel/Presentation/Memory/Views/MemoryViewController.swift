//
//  MemoryView.swift
//  YeolmokTravel
//
//  Created by 김동욱 on 2022/12/23.
//

import UIKit
import Combine

protocol MemoryTransferDelegate: AnyObject {
    func create(_ memory: Memory)
}

/// Memories tab
final class MemoryViewController: UIViewController {
    enum Section: CaseIterable {
        case main
    }
    // MARK: - Properties
    private let viewModel: ConcreteMemoryViewModel
    private var subscriptions = Set<AnyCancellable>()
    private let memoryUseCaseProvider: MemoryUseCaseProvider
    private let memoryImageUseCaseProvider: MemoryImageUseCaseProvider
    private var dataSource: UICollectionViewDiffableDataSource<Section, Memory>!
    
    init(_ viewModel: ConcreteMemoryViewModel, _ memoryUseCaseProvider: MemoryUseCaseProvider, _ memoryImageUseCaseProvider: MemoryImageUseCaseProvider) {
        self.viewModel = viewModel
        self.memoryUseCaseProvider = memoryUseCaseProvider
        self.memoryImageUseCaseProvider = memoryImageUseCaseProvider
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .white
        label.text = TextConstants.title
        label.font = .boldSystemFont(ofSize: AppLayoutConstants.titleFontSize)
        return label
    }()
    
    private let addButton: UIButton = {
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        configure()
        configureDataSource()
        setBindings()
        fetchMemories()
    }
}

// MARK: - Configure View
private extension MemoryViewController {
    func configureView() {
        view.backgroundColor = .systemBackground
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
        addButton.addTarget(self, action: #selector(touchUpAddButton), for: .touchUpInside)
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
private extension MemoryViewController {
    @MainActor func reload() {
        memoriesCollectionView.reloadData()
    }
    
    @objc func touchUpAddButton() {
        let viewModel = ConcreteWritingMemoryViewModel(memoryUseCaseProvider, memoryImageUseCaseProvider)
        let writingMemoryViewController = WritingMemoryViewController(viewModel,
                                                                      self.viewModel.model.value.count,
                                                                      delegate: self)
        writingMemoryViewController.modalPresentationStyle = .fullScreen
        present(writingMemoryViewController, animated: true)
    }
    
    func setBindings() {
        viewModel.model
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.apply()
            }
            .store(in: &subscriptions)
    }
}

// MARK: - CollectionView
private extension MemoryViewController {
    func fetchMemories() {
        Task {
            do {
                try await viewModel.read()
            } catch {
                guard let error = error as? MemoryRepositoryError else { return }
                DispatchQueue.main.async {
                    self.alertWillAppear(error.rawValue)
                }
            }
        }
    }
    
    func configureDataSource() {
        let cellRegistration = UICollectionView.CellRegistration<MemoryCell, Memory> { [self] (cell, indexPath, memory) in // memory
            // Cell assembling of MVVM
            let viewModel = ConcreteMemoryCellViewModel(viewModel.model.value[indexPath.row], memoryImageUseCaseProvider)
            cell.setViewModel(viewModel)
        }
        
        dataSource = UICollectionViewDiffableDataSource<Section, Memory>(collectionView: memoriesCollectionView) { (collectionView: UICollectionView, indexPath: IndexPath, itemIdentifier: Memory) -> UICollectionViewCell? in
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: itemIdentifier)
        }
    }
    
    func apply() {
        let memories = viewModel.model.value
        var snapshot = NSDiffableDataSourceSnapshot<Section, Memory>()
        snapshot.appendSections([.main])
        snapshot.appendItems(memories)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
}

extension MemoryViewController: MemoryTransferDelegate {
    func create(_ memory: Memory) {
        viewModel.create(memory)
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
