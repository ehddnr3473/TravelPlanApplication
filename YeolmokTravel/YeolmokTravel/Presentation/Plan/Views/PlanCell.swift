//
//  PlanCell.swift
//  YeolmokTravel
//
//  Created by 김동욱 on 2022/12/20.
//

import UIKit

/// TravelPlanView와 WritingPlanViewController에서 사용하는 공용 커스텀 셀
/// - Title Label
/// - Date Label
/// - Description Label
final class PlanCell: UITableViewCell {
    static let identifier = "PlanTableViewCell"
    // MARK: - Properties
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
    
    lazy var indicatorView: UIActivityIndicatorView = {
        let indicatorView = UIActivityIndicatorView()
        return indicatorView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureView()
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
}

// MARK: - Configure View
private extension PlanCell {
    private func configureView() {
        self.backgroundColor = .darkGray
        self.layer.borderWidth = LayoutConstants.borderWidth
        self.selectionStyle = .none
        configureHierarchy()
        configureLayoutConstraint()
    }
    
    private func configureHierarchy() {
        [titleLabel, dateLabel, descriptionLabel].forEach {
            self.addSubview($0)
        }
    }
    
    private func configureLayoutConstraint() {
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview()
                .inset(AppLayoutConstants.spacing)
            $0.leading.trailing.equalToSuperview()
                .inset(AppLayoutConstants.spacing)
        }
        
        dateLabel.snp.makeConstraints {
            $0.bottom.equalToSuperview()
                .inset(AppLayoutConstants.spacing)
            $0.leading.equalToSuperview()
                .inset(AppLayoutConstants.spacing)
        }
        
        descriptionLabel.snp.makeConstraints {
            $0.centerY.equalTo(dateLabel.snp.centerY)
            $0.leading.equalTo(dateLabel.snp.trailing)
                .offset(AppLayoutConstants.spacing)
            $0.trailing.equalToSuperview()
                .inset(AppLayoutConstants.spacing)
        }
    }
}

// Layout magic number
private enum LayoutConstants {
    static let titleFontSize: CGFloat = 20
    static let borderWidth: CGFloat = 0.5
    static let fontSize: CGFloat = 15
}
