//
//  MapButtonSetView.swift
//  YeolmokTravel
//
//  Created by 김동욱 on 2023/02/06.
//

import UIKit

final class MapButtonSetView: UIView {
    // MARK: - Properties
    private let buttonStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = AppLayoutConstants.spacing
        return stackView
    }()
    
    let previousButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(systemName: TextConstants.previousIcon)?
            .withTintColor(.black, renderingMode: .alwaysTemplate), for: .normal)
        button.setTitle(TextConstants.previousTitle, for: .normal)
        button.layer.cornerRadius = LayoutConstants.cornerRadius
        button.tintColor = .black
        button.backgroundColor = AppStyles.mainColor
        return button
    }()
    
    let centerButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(systemName: TextConstants.centerIcon)?
            .withTintColor(.black, renderingMode: .alwaysTemplate), for: .normal)
        button.layer.cornerRadius = LayoutConstants.cornerRadius
        button.tintColor = .black
        button.backgroundColor = AppStyles.mainColor
        return button
    }()
    
    let nextButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(systemName: TextConstants.nextIcon)?
            .withTintColor(.black, renderingMode: .alwaysTemplate), for: .normal)
        button.setTitle(TextConstants.nextTitle, for: .normal)
        button.layer.cornerRadius = LayoutConstants.cornerRadius
        button.tintColor = .black
        button.backgroundColor = AppStyles.mainColor
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

// MARK: - Configure View
private extension MapButtonSetView {
    func configureView() {
        configureHierarchy()
        configureLayoutConstraint()
    }
    
    func configureHierarchy() {
        [previousButton, centerButton, nextButton].forEach {
            buttonStackView.addArrangedSubview($0)
        }
        addSubview(buttonStackView)
    }
    
    func configureLayoutConstraint() {
        buttonStackView.snp.makeConstraints {
            $0.top.leading.bottom.trailing.equalToSuperview()
        }
    }
}

private enum LayoutConstants {
    static let cornerRadius: CGFloat = 8
}

private enum TextConstants {
    static let previousTitle = "Previous"
    static let nextTitle = "Next"
    static let previousIcon = "arrow.left.circle.fill"
    static let centerIcon = "scope"
    static let nextIcon = "arrow.right.circle.fill"
}
