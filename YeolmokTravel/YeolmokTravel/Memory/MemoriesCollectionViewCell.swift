//
//  MemoriesCollectionViewCell.swift
//  YeolmokTravel
//
//  Created by 김동욱 on 2022/12/23.
//

import UIKit

final class MemoriesCollectionViewCell: UICollectionViewCell {
    // MARK: - Properties
    static let identifier = "MemoriesCollectionViewCell"
    var imageView: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()
    
    var titleLabel: UILabel = {
        let label = UILabel()
        
        label.textAlignment = .left
        label.font = .boldSystemFont(ofSize: FontSize.title)
        label.textColor = .white
        
        return label
    }()
    
    var descriptionLabel: UILabel = {
        let label = UILabel()
        
        label.textAlignment = .left
        label.font = .boldSystemFont(ofSize: FontSize.description)
        label.textColor = .white
        
        return label
    }()
    
    var dateLabel: UILabel = {
        let label = UILabel()
        
        label.textAlignment = .left
        label.font = .boldSystemFont(ofSize: FontSize.date)
        label.textColor = .white
        
        return label
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
        
        imageView.image = nil
        titleLabel.text = ""
        descriptionLabel.text = ""
        dateLabel.text = ""
    }
}

// MARK: - SetUp View
extension MemoriesCollectionViewCell {
    private func setUpUI() {
        contentView.backgroundColor = .black
        setUpHierachy()
        setUpLayout()
    }
    
    private func setUpHierachy() {
        [imageView, titleLabel, descriptionLabel, dateLabel].forEach {
            contentView.addSubview($0)
        }
    }
    
    private func setUpLayout() {
        imageView.snp.makeConstraints {
            $0.top.equalTo(contentView.snp.top)
            $0.leading.equalTo(contentView.snp.leading)
            $0.trailing.equalTo(contentView.snp.trailing)
            $0.height.equalTo(contentView.snp.width)
                .multipliedBy(LayoutConstants.widthMultiplier)
        }
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(imageView.snp.bottom).offset(LayoutConstants.spacing)
            $0.leading.equalTo(contentView.snp.leading)
                .inset(LayoutConstants.spacing)
        }
        descriptionLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(LayoutConstants.spacing)
            $0.leading.equalTo(contentView.snp.leading)
                .inset(LayoutConstants.spacing)
        }
        dateLabel.snp.makeConstraints {
            $0.top.equalTo(descriptionLabel.snp.bottom)
                .offset(LayoutConstants.spacing)
            $0.leading.equalTo(contentView.snp.leading)
                .inset(LayoutConstants.spacing)
        }
        
    }
}

private enum FontSize {
    static let title: CGFloat = 25
    static let description: CGFloat = 20
    static let date: CGFloat = 15
}

private enum LayoutConstants {
    static let spacing: CGFloat = 8
    static let widthMultiplier: CGFloat = 0.7
}
