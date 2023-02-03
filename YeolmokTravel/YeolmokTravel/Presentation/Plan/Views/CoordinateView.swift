//
//  CoordinateView.swift
//  YeolmokTravel
//
//  Created by 김동욱 on 2023/02/03.
//

import UIKit

final class CoordinateView: UIView {
    let latitudeTextField: UITextField = {
        let textField = UITextField()
        
        textField.textColor = .white
        textField.backgroundColor = .black
        textField.layer.cornerRadius = LayoutConstants.cornerRadius
        textField.layer.borderWidth = LayoutConstants.borderWidth
        textField.layer.borderColor = UIColor.white.cgColor
        textField.font = .boldSystemFont(ofSize: LayoutConstants.mediumFontSize)
        textField.placeholder = TextConstants.latitudePlaceholder
        textField.keyboardType = .decimalPad
        
        textField.leftView = UIView(frame: CGRect(x: .zero,
                                                  y: .zero,
                                                  width: LayoutConstants.spacing,
                                                  height: .zero))
        textField.leftViewMode = .always
        
        return textField
    }()
    
    let longitudeTextField: UITextField = {
        let textField = UITextField()
        
        textField.textColor = .white
        textField.backgroundColor = .black
        textField.layer.cornerRadius = LayoutConstants.cornerRadius
        textField.layer.borderWidth = LayoutConstants.borderWidth
        textField.layer.borderColor = UIColor.white.cgColor
        textField.font = .boldSystemFont(ofSize: LayoutConstants.mediumFontSize)
        textField.placeholder = TextConstants.longitudePlaceholder
        textField.keyboardType = .decimalPad
        
        textField.leftView = UIView(frame: CGRect(x: .zero,
                                                  y: .zero,
                                                  width: LayoutConstants.spacing,
                                                  height: .zero))
        textField.leftViewMode = .always
        
        return textField
    }()
    
    lazy var mapButton: UIButton = {
        let button = UIButton(type: .custom)
        
        button.setTitle(TextConstants.buttonTitle, for: .normal)
        button.setImage(UIImage(systemName: TextConstants.mapIcon), for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: LayoutConstants.mediumFontSize, weight: .bold)
        button.layer.borderWidth = LayoutConstants.borderWidth
        button.layer.cornerRadius = LayoutConstants.cornerRadius
        button.layer.borderColor = UIColor.systemGray.cgColor
        button.backgroundColor = .systemGreen
        
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
                .inset(LayoutConstants.spacing)
        }
        
        longitudeTextField.snp.makeConstraints {
            $0.top.equalTo(latitudeTextField.snp.bottom)
                .offset(LayoutConstants.spacing)
            $0.leading.trailing.equalToSuperview()
                .inset(LayoutConstants.spacing)
        }
        
        mapButton.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(longitudeTextField.snp.bottom)
                .offset(LayoutConstants.spacing)
            $0.height.equalTo(LayoutConstants.buttonHeight)
            $0.width.equalTo(mapButton.snp.height)
                .multipliedBy(LayoutConstants.buttonWidthMultiplier)
        }
    }
}

private enum LayoutConstants {
    static let spacing: CGFloat = 8
    static let cornerRadius: CGFloat = 5
    static let borderWidth: CGFloat = 1
    static let mediumFontSize: CGFloat = 20
    static let buttonHeight: CGFloat = 44.44
    static let buttonWidthMultiplier: CGFloat = 3
}

private enum TextConstants {
    static let latitudePlaceholder = "latitude"
    static let longitudePlaceholder = "longitude"
    static let buttonTitle = "Show Map"
    static let mapIcon = "map"
}
