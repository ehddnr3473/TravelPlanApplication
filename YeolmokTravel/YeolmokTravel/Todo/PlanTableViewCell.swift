//
//  PlanTableViewCell.swift
//  YeolmokTravel
//
//  Created by 김동욱 on 2022/12/20.
//

import UIKit
import SnapKit

/// TodoList를 표현하는 Custom Cell
class PlanTableViewCell: UITableViewCell {

    static let identifier = "PlanTableViewCell"
    
    var titleLabel: UILabel = {
        let label = UILabel()
        
        label.textAlignment = .left
        label.textColor = .white
        label.font = .boldSystemFont(ofSize: LayoutConstants.titleFontSize)
        
        return label
    }()
    
    var descriptionLabel: UILabel = {
        let label = UILabel()
        
        label.textAlignment = .left
        label.textColor = .lightGray
        label.font = .boldSystemFont(ofSize: LayoutConstants.descriptionFontSize)
        
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setUpUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    private func setUpUI() {
        self.backgroundColor = .darkGray
        self.layer.borderWidth = LayoutConstants.borderWidth
        setUpHierachy()
        setUpLayout()
    }
    
    private func setUpHierachy() {
        [titleLabel, descriptionLabel].forEach {
            self.addSubview($0)
        }
    }
    
    private func setUpLayout() {
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview()
                .inset(LayoutConstants.spacing)
            $0.leading.trailing.equalToSuperview()
                .inset(LayoutConstants.spacing)
        }
        
        descriptionLabel.snp.makeConstraints {
            $0.bottom.equalToSuperview()
                .inset(LayoutConstants.spacing)
            $0.leading.trailing.equalToSuperview()
                .inset(LayoutConstants.spacing)
        }
    }
}

// Layout magic number
private enum LayoutConstants {
    static let spacing: CGFloat = 15
    static let borderWidth: CGFloat = 0.5
    static let titleFontSize: CGFloat = 25
    static let descriptionFontSize: CGFloat = 15
}
