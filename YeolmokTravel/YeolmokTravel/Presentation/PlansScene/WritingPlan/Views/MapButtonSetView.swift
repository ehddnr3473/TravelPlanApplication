//
//  MapButtonSetView.swift
//  YeolmokTravel
//
//  Created by 김동욱 on 2023/02/06.
//

import UIKit

/// Map Camera를 제어하기 위한 뷰
/// - previousButton: 이전 좌표로 카메라 이동
/// - centerButton: 중심으로 카메라 이동
/// - nextButton: 다음 좌표로 카메라 이동
final class MapButtonSetView: UIView {
    @frozen private enum ButtonStyle {
        case leftImage
        case rightImage
    }
    
    // MARK: - Magic number/string
    @frozen private enum LayoutConstants {
        static let cornerRadius: CGFloat = 8
        static let buttonFontSize: CGFloat = 20
    }
    
    @frozen private enum TextConstants {
        static let previousTitle = "Pre"
        static let nextTitle = "Next"
        static let previousIcon = "arrow.left.circle.fill"
        static let centerIcon = "scope"
        static let nextIcon = "arrow.right.circle.fill"
    }
    
    // MARK: - Properties
    private let buttonStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = AppLayoutConstants.spacing
        return stackView
    }()
    
    let centerButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(systemName: TextConstants.centerIcon)?
            .withTintColor(.systemBackground, renderingMode: .alwaysTemplate), for: .normal)
        button.tintColor = .systemBackground
        button.layer.cornerRadius = LayoutConstants.cornerRadius
        button.backgroundColor = AppStyles.mainColor
        return button
    }()
    
    lazy var previousButton = createConfigurationButton(.leftImage)
    lazy var nextButton = createConfigurationButton(.rightImage)
    
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
    
    private func createConfigurationButton(_ buttonStyle: ButtonStyle) -> UIButton {
        var container = AttributeContainer()
        container.font = .systemFont(ofSize: LayoutConstants.buttonFontSize)
        
        var configuration = UIButton.Configuration.plain()
        switch buttonStyle {
        case .leftImage:
            configuration.attributedTitle = AttributedString(TextConstants.previousTitle, attributes: container)
            configuration.image = UIImage(systemName: TextConstants.previousIcon)?
                .withTintColor(.systemBackground, renderingMode: .alwaysTemplate)
            configuration.imagePlacement = .leading
        case .rightImage:
            configuration.attributedTitle = AttributedString(TextConstants.nextTitle, attributes: container)
            configuration.image = UIImage(systemName: TextConstants.nextIcon)?
                .withTintColor(.systemBackground, renderingMode: .alwaysTemplate)
            configuration.imagePlacement = .trailing
        }
        configuration.imagePadding = AppLayoutConstants.spacing
        
        let button = UIButton(configuration: configuration)
        button.tintColor = .systemBackground
        button.layer.cornerRadius = LayoutConstants.cornerRadius
        button.backgroundColor = AppStyles.mainColor
        return button
    }
}
