//
//  MemoryCell.swift
//  YeolmokTravel
//
//  Created by 김동욱 on 2022/12/23.
//

import UIKit
import Combine
import JGProgressHUD
import FirebasePlatform

final class MemoryCell: UICollectionViewCell {
    // MARK: - Properties
    static let identifier = "MemoriesCollectionViewCell"
    weak var delegate: MemoryCellErrorDelegate?
    private var viewModel: MemoryCellViewModel?
    private var subscriptions = Set<AnyCancellable>()
    
    var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .systemBackground
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = .boldSystemFont(ofSize: FontSize.title)
        label.textColor = .white
        return label
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = .boldSystemFont(ofSize: FontSize.date)
        label.textColor = .white
        return label
    }()
    
    private let progressIndicator = JGProgressHUD()
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    // MARK: - Lifecycle
    override func prepareForReuse() {
        super.prepareForReuse()
        
        if progressIndicator.isVisible {
            progressIndicator.dismiss()
        }
        viewModel = nil
        imageView.image = nil
        titleLabel.text = ""
        dateLabel.text = ""
        
        subscriptions.forEach { $0.cancel() }
        subscriptions.removeAll()
    }
    
    func setViewModel(_ viewModel: DefaultMemoryCellViewModel) {
        self.viewModel = viewModel
        bind()
        configure()
    }
    
    // MARK: - Binding
    func bind() {
        viewModel?.imagePublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                self?.progressIndicator.dismiss()
                switch completion {
                case .failure(let error):
                    guard let error = error as? ImagesRepositoryError else { return }
                    self?.delegate?.errorDidOccurrued(error.rawValue)
                    break
                case .finished:
                    break
                }
            }) { [weak self] image in
                self?.progressIndicator.dismiss()
                self?.imageView.image = image
            }
            .store(in: &subscriptions)
    }
}

// MARK: - Configure view
private extension MemoryCell {
    private func configureView() {
        contentView.backgroundColor = .clear
        configureHierarchy()
        configureLayoutConstraint()
    }
    
    func configureHierarchy() {
        [imageView, titleLabel, dateLabel].forEach {
            contentView.addSubview($0)
        }
    }
    
    func configureLayoutConstraint() {
        imageView.snp.makeConstraints {
            $0.top.equalTo(contentView.snp.top)
            $0.leading.equalTo(contentView.snp.leading)
            $0.trailing.equalTo(contentView.snp.trailing)
            $0.height.equalTo(contentView.snp.width)
        }
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(imageView.snp.bottom)
                .offset(AppLayoutConstants.spacing)
            $0.leading.equalTo(contentView.snp.leading)
                .inset(AppLayoutConstants.spacing)
        }
        dateLabel.snp.makeConstraints {
            $0.bottom.equalTo(contentView.snp.bottom)
                .inset(AppLayoutConstants.spacing)
            $0.trailing.equalTo(contentView.snp.trailing)
                .inset(AppLayoutConstants.spacing)
        }
    }
    
    func configure() {
        progressIndicator.show(in: imageView)
        titleLabel.text = viewModel?.memory.title
        dateLabel.text = viewModel?.uploadDate
        viewModel?.read()
    }
}

// MARK: - Magic number
private extension MemoryCell {
    @frozen enum FontSize {
        static let title: CGFloat = 25
        static let date: CGFloat = 15
    }

    @frozen enum LayoutConstants {
        static let cornerRadius: CGFloat = 8
    }
}
