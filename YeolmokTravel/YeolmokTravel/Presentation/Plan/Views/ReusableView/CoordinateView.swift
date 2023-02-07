//
//  CoordinateView.swift
//  YeolmokTravel
//
//  Created by 김동욱 on 2023/02/03.
//

import UIKit

/// 좌표값 관련 뷰
/// - 위도 입력 텍스트필드
/// - 경도 입력 텍스트필드
/// - Map을 보여줄 버튼
final class CoordinateView: UIView {
    // MARK: - Properties
    let latitudeTextField: UITextField = {
        let textField = UITextField()
        textField.textColor = .white
        textField.backgroundColor = .black
        textField.layer.cornerRadius = LayoutConstants.cornerRadius
        textField.layer.borderWidth = AppLayoutConstants.borderWidth
        textField.layer.borderColor = UIColor.white.cgColor
        textField.font = .boldSystemFont(ofSize: LayoutConstants.mediumFontSize)
        textField.placeholder = TextConstants.latitudePlaceholder
        textField.keyboardType = .decimalPad
        
        textField.leftView = UIView(frame: CGRect(x: .zero,
                                                  y: .zero,
                                                  width: AppLayoutConstants.spacing,
                                                  height: .zero))
        textField.leftViewMode = .always
        return textField
    }()
    
    let longitudeTextField: UITextField = {
        let textField = UITextField()
        textField.textColor = .white
        textField.backgroundColor = .black
        textField.layer.cornerRadius = LayoutConstants.cornerRadius
        textField.layer.borderWidth = AppLayoutConstants.borderWidth
        textField.layer.borderColor = UIColor.white.cgColor
        textField.font = .boldSystemFont(ofSize: LayoutConstants.mediumFontSize)
        textField.placeholder = TextConstants.longitudePlaceholder
        textField.keyboardType = .decimalPad
        textField.leftView = UIView(frame: CGRect(x: .zero,
                                                  y: .zero,
                                                  width: AppLayoutConstants.spacing,
                                                  height: .zero))
        textField.leftViewMode = .always
        return textField
    }()
    
    lazy var mapButton: UIButton = {
        let button = createConfigurationButton()
        button.tintColor = .black
        button.layer.borderWidth = AppLayoutConstants.borderWidth
        button.layer.cornerRadius = LayoutConstants.cornerRadius
        button.layer.borderColor = UIColor.systemGray.cgColor
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
private extension CoordinateView {
    func configureView() {
        configureHierarchy()
        configureLayoutConstraint()
    }
    
    func configureHierarchy() {
        [latitudeTextField, longitudeTextField, mapButton].forEach {
            addSubview($0)
        }
    }
    
    func configureLayoutConstraint() {
        latitudeTextField.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
                .inset(AppLayoutConstants.spacing)
        }
        
        longitudeTextField.snp.makeConstraints {
            $0.top.equalTo(latitudeTextField.snp.bottom)
                .offset(AppLayoutConstants.spacing)
            $0.leading.trailing.equalToSuperview()
                .inset(AppLayoutConstants.spacing)
        }
        
        mapButton.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(longitudeTextField.snp.bottom)
                .offset(AppLayoutConstants.spacing)
            $0.height.equalTo(LayoutConstants.buttonHeight)
            $0.width.equalTo(mapButton.snp.height)
                .multipliedBy(LayoutConstants.buttonWidthMultiplier)
        }
    }
    
    func createConfigurationButton() -> UIButton {
        var container = AttributeContainer()
        container.font = .systemFont(ofSize: LayoutConstants.mediumFontSize, weight: .bold)
        
        var configuration = UIButton.Configuration.plain()
        configuration.attributedTitle = AttributedString(TextConstants.buttonTitle, attributes: container)
        
        configuration.image = UIImage(systemName: TextConstants.mapIcon)?
            .withTintColor(.black, renderingMode: .alwaysTemplate)
        configuration.imagePlacement = .leading
        configuration.imagePadding = AppLayoutConstants.spacing
        return UIButton(configuration: configuration)
    }
}

private enum LayoutConstants {
    static let cornerRadius: CGFloat = 5
    static let mediumFontSize: CGFloat = 20
    static let buttonHeight: CGFloat = 44.44
    static let buttonWidthMultiplier: CGFloat = 4
}

private enum TextConstants {
    static let latitudePlaceholder = "latitude"
    static let longitudePlaceholder = "longitude"
    static let buttonTitle = "Show Map"
    static let mapIcon = "map"
}
