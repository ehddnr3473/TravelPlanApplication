//
//  TopBarView.swift
//  YeolmokTravel
//
//  Created by 김동욱 on 2023/02/12.
//

import Foundation
import UIKit

/// Modal View 상단 바
final class TopBarView: UIView {
    // MARK: - Properties
    private let topBarStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.distribution = .equalCentering
        stackView.backgroundColor = .darkGray
        stackView.layer.cornerRadius = LayoutConstants.stackViewCornerRadius
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = UIEdgeInsets(top: LayoutConstants.topBottomMargin,
                                               left: LayoutConstants.sideMargin,
                                               bottom: LayoutConstants.topBottomMargin,
                                               right: LayoutConstants.sideMargin)
        stackView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        return stackView
    }()
    
    let barTitleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = .boldSystemFont(ofSize: LayoutConstants.fontSize)
        label.textColor = .white
        return label
    }()
    
    let saveBarButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle(TextConstants.saveButtonTitle, for: .normal)
        button.setTitleColor(AppStyles.mainColor, for: .normal)
        button.setTitleColor(.systemGray, for: .disabled)
        button.isEnabled = false
        return button
    }()
    
    let cancelBarButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle(TextConstants.cancelButtonTItle, for: .normal)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}

private extension TopBarView {
    func configureView() {
        configureHierarchy()
        configureLayoutConstraint()
    }
    
    func configureHierarchy() {
        [cancelBarButton, barTitleLabel, saveBarButton].forEach {
            topBarStackView.addArrangedSubview($0)
        }
        addSubview(topBarStackView)
    }
    
    func configureLayoutConstraint() {
        topBarStackView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.equalToSuperview()
            $0.height.greaterThanOrEqualToSuperview()
        }
    }
}

private enum LayoutConstants {
    static let spacing: CGFloat = 8
    static let largeSpacing: CGFloat = 20
    static let stackViewCornerRadius: CGFloat = 10
    static let fontSize: CGFloat = 25
    static let topBottomMargin: CGFloat = 10
    static let sideMargin: CGFloat = 15
}

private enum TextConstants {
    static let saveButtonTitle = "Save"
    static let cancelButtonTItle = "Cancel"
}

