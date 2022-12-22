//
//  PlanTableViewCell.swift
//  YeolmokTravel
//
//  Created by 김동욱 on 2022/12/20.
//

import UIKit

/// TravelPlanView와 WritingPlanViewController에서 사용하는 공용 커스텀 셀
/// - Title Label
/// - Date Label
/// - Description Label
class PlanTableViewCell: UITableViewCell {
    static let identifier = "PlanTableViewCell"
    
    var titleLabel: UILabel = {
        let label = UILabel()
        
        label.textAlignment = .left
        label.textColor = .white
        label.font = .boldSystemFont(ofSize: LayoutConstants.titleFontSize)
        
        return label
    }()
    
    var dateLabel: UILabel = {
        let label = UILabel()
        
        label.textAlignment = .left
        label.textColor = .lightGray
        label.font = .boldSystemFont(ofSize: LayoutConstants.fontSize)
        label.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        
        return label
    }()
    
    var descriptionLabel: UILabel = {
        let label = UILabel()
        
        label.textAlignment = .left
        label.textColor = .lightGray
        label.font = .boldSystemFont(ofSize: LayoutConstants.fontSize)
        
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
        
        titleLabel.text = ""
        dateLabel.text = ""
        descriptionLabel.text = ""
    }
    
    private func setUpUI() {
        self.backgroundColor = .darkGray
        self.layer.borderWidth = LayoutConstants.borderWidth
        self.selectionStyle = .none
        setUpHierachy()
        setUpLayout()
    }
    
    private func setUpHierachy() {
        [titleLabel, dateLabel, descriptionLabel].forEach {
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
        
        dateLabel.snp.makeConstraints {
            $0.bottom.equalToSuperview()
                .inset(LayoutConstants.spacing)
            $0.leading.equalToSuperview()
                .inset(LayoutConstants.spacing)
        }
        
        descriptionLabel.snp.makeConstraints {
            $0.centerY.equalTo(dateLabel.snp.centerY)
            $0.leading.equalTo(dateLabel.snp.trailing)
                .offset(LayoutConstants.spacing)
            $0.trailing.equalToSuperview()
                .inset(LayoutConstants.spacing)
        }
    }
}

// Layout magic number
private enum LayoutConstants {
    static let spacing: CGFloat = 15
    static let borderWidth: CGFloat = 0.5
    static let titleFontSize: CGFloat = 25
    static let fontSize: CGFloat = 15
}
