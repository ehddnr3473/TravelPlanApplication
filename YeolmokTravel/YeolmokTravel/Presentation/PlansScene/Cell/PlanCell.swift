//
//  PlanCell.swift
//  YeolmokTravel
//
//  Created by 김동욱 on 2022/12/20.
//

import UIKit

/// PlansListViewController와 WritingPlanViewController에서 사용하는 공용 커스텀 셀 클래스
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
    
    lazy var indicatorView: UIActivityIndicatorView? = nil
    
    // MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    // MARK: - Lifecycle
    override func prepareForReuse() {
        super.prepareForReuse()
        
        titleLabel.text = ""
        dateLabel.text = ""
        descriptionLabel.text = ""
    }
}

// MARK: - Configure view
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
            addSubview($0)
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

// MARK: - Indicator
extension PlanCell {
    func createIndicator() {
        indicatorView = UIActivityIndicatorView()
        guard let indicatorView = indicatorView else { return }
        
        DispatchQueue.main.async { [weak self] in
            self?.addSubview(indicatorView)
            indicatorView.snp.makeConstraints {
                $0.trailing.equalToSuperview()
                    .inset(LayoutConstants.indicatorTrailing)
                $0.centerY.equalToSuperview()
            }
        }
    }
    
    func startIndicator() {
        isUserInteractionEnabled = false
        guard let indicatorView = indicatorView else { return }
        DispatchQueue.main.async {
            indicatorView.startAnimating()
        }
    }
    
    func stopAndDeallocateIndicator() {
        guard let indicatorView = indicatorView else { return }
        DispatchQueue.main.async {
            indicatorView.stopAnimating()
            indicatorView.snp.removeConstraints()
            indicatorView.removeFromSuperview()
        }
        self.indicatorView = nil
        isUserInteractionEnabled = true
    }
}

// MARK: - Magic number
private extension PlanCell {
    @frozen enum LayoutConstants {
        static let titleFontSize: CGFloat = 20
        static let borderWidth: CGFloat = 0.5
        static let fontSize: CGFloat = 15
        static let indicatorTrailing: CGFloat = 50
    }
}
