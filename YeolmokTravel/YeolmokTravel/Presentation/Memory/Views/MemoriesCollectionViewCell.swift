//
//  MemoriesCollectionViewCell.swift
//  YeolmokTravel
//
//  Created by 김동욱 on 2022/12/23.
//

import UIKit
import Combine
import JGProgressHUD

final class MemoriesCollectionViewCell: UICollectionViewCell {
    // MARK: - Properties
    static let identifier = "MemoriesCollectionViewCell"
    private(set) var viewModel: MemoriesLoader?
    private var subscriptions = Set<AnyCancellable>()
    
    var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .black
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
    
    private let progressIndicator: JGProgressHUD = {
        let indicator = JGProgressHUD()
        return indicator
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        if progressIndicator.isVisible {
            progressIndicator.dismiss()
        }
        viewModel = nil
        imageView.image = nil
        titleLabel.text = ""
        dateLabel.text = ""
    }
    
    func setViewModel(_ viewModel: MemoriesLoader) {
        self.viewModel = viewModel
        setBindings()
        configure()
    }
}

// MARK: - SetUp View
extension MemoriesCollectionViewCell {
    private func setUpUI() {
        contentView.backgroundColor = .clear
        setUpHierachy()
        setUpLayout()
    }
    
    private func setUpHierachy() {
        [imageView, titleLabel, dateLabel].forEach {
            contentView.addSubview($0)
        }
    }
    
    private func setUpLayout() {
        imageView.snp.makeConstraints {
            $0.top.equalTo(contentView.snp.top)
            $0.leading.equalTo(contentView.snp.leading)
            $0.trailing.equalTo(contentView.snp.trailing)
            $0.height.equalTo(contentView.snp.width)
        }
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(imageView.snp.bottom)
                .offset(LayoutConstants.spacing)
            $0.leading.equalTo(contentView.snp.leading)
                .inset(LayoutConstants.spacing)
        }
        dateLabel.snp.makeConstraints {
            $0.bottom.equalTo(contentView.snp.bottom)
                .inset(LayoutConstants.spacing)
            $0.trailing.equalTo(contentView.snp.trailing)
                .inset(LayoutConstants.spacing)
        }
    }
    
    private func setBindings() {
        viewModel?.publisher
            .receive(on: RunLoop.main)
            .sink { image in
                self.progressIndicator.dismiss()
                self.imageView.image = image
            }
            .store(in: &subscriptions)
    }
    
    private func configure() {
        progressIndicator.show(in: imageView)
        viewModel?.downloadImage()
        titleLabel.text = viewModel?.title
        dateLabel.text = viewModel?.uploadDate
    }
}

private enum FontSize {
    static let title: CGFloat = 25
    static let date: CGFloat = 15
}

private enum LayoutConstants {
    static let spacing: CGFloat = 8
    static let cornerRadius: CGFloat = 8
}
