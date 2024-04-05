//
//  WritingMemoryView.swift
//  YeolmokTravel
//
//  Created by 김동욱 on 2023/02/23.
//

import UIKit
import JGProgressHUD

final class WritingMemoryView: UIView {
    // MARK: - Magic number/string
    @frozen private enum LayoutConstants {
        static let topBarHeight: CGFloat = 50
        static let stackViewCornerRadius: CGFloat = 10
        static let topBottomMargin: CGFloat = 10
        static let sideMargin: CGFloat = 15
        static let cornerRadius: CGFloat = 5
        static let imageViewWidthMultiplier: CGFloat = 0.8
        static let buttonWidth: CGFloat = 100
    }
    
    @frozen private enum TextConstants {
        static let title = "New memory"
        static let saveButtonTitle = "Save"
        static let cancelButtonTItle = "Cancel"
        static let createButtonTitle = "Load"
        static let deleteButtonTitle = "Delete"
    }
    
    @frozen private enum IndicatorConstants {
        static let titleText = "Uploading image.."
        static let detailText = "Please wait"
    }
    
    // MARK: - Properties
    private let topBarStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .equalCentering
        stackView.backgroundColor = AppStyles.getContentBackgroundColor()
        stackView.layer.cornerRadius = LayoutConstants.stackViewCornerRadius
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = UIEdgeInsets(top: LayoutConstants.topBottomMargin,
                                               left: LayoutConstants.sideMargin,
                                               bottom: LayoutConstants.topBottomMargin,
                                               right: LayoutConstants.sideMargin)
        stackView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        return stackView
    }()
    
    private let barTitleLabel: UILabel = {
        let label = UILabel()
        label.text = TextConstants.title
        label.textAlignment = .center
        label.font = .boldSystemFont(ofSize: AppLayoutConstants.largeFontSize)
        label.textColor = AppStyles.getAccentColor()
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
        button.setTitleColor(AppStyles.getAccentColor(), for: .normal)
        return button
    }()
    
    let titleTextField = UITextField()
        .makeCustomTextField()
        .withFontSize(AppLayoutConstants.largeFontSize)
        .withPlaceholder(AppTextConstants.titlePlaceholder)
    
    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.borderWidth = AppLayoutConstants.borderWidth
        imageView.layer.borderColor = AppStyles.getBorderColor()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    let imageLoadButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle(TextConstants.createButtonTitle, for: .normal)
        button.setTitleColor(.systemBackground, for: .normal)
        button.backgroundColor = AppStyles.mainColor
        button.layer.borderColor = AppStyles.getBorderColor()
        button.layer.borderWidth = AppLayoutConstants.borderWidth
        return button
    }()
    
    let imageDeleteButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle(TextConstants.deleteButtonTitle, for: .normal)
        button.setTitleColor(.systemBackground, for: .normal)
        button.backgroundColor = .systemRed
        button.layer.borderColor = AppStyles.getBorderColor()
        button.layer.borderWidth = AppLayoutConstants.borderWidth
        return button
    }()
    
    lazy var indicatorView: JGProgressHUD = {
        let headUpDisplay = JGProgressHUD()
        headUpDisplay.textLabel.text = IndicatorConstants.titleText
        headUpDisplay.detailTextLabel.text = IndicatorConstants.detailText
        return headUpDisplay
    }()
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Configure view
private extension WritingMemoryView {
    func configureView() {
        backgroundColor = .systemBackground
        configureHierarchy()
        configureLayoutConstraint()
    }
    
    func configureHierarchy() {
        [cancelBarButton, barTitleLabel, saveBarButton].forEach {
            topBarStackView.addArrangedSubview($0)
        }
        
        [topBarStackView, titleTextField, imageView, imageLoadButton, imageDeleteButton].forEach {
            addSubview($0)
        }
    }
    
    func configureLayoutConstraint() {
        topBarStackView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.width.equalToSuperview()
            $0.height.equalTo(LayoutConstants.topBarHeight)
        }
        
        titleTextField.snp.makeConstraints {
            $0.top.equalTo(topBarStackView.snp.bottom)
                .offset(AppLayoutConstants.largeSpacing)
            $0.leading.trailing.equalToSuperview()
                .inset(AppLayoutConstants.spacing)
        }
        
        imageView.snp.makeConstraints {
            $0.top.equalTo(titleTextField.snp.bottom)
                .offset(AppLayoutConstants.largeSpacing)
            $0.centerX.equalToSuperview()
            $0.width.equalToSuperview()
                .multipliedBy(LayoutConstants.imageViewWidthMultiplier)
            $0.height.equalTo(imageView.snp.width)
        }
        
        imageDeleteButton.snp.makeConstraints {
            $0.top.equalTo(imageView.snp.bottom)
                .offset(AppLayoutConstants.spacing)
            $0.width.equalTo(LayoutConstants.buttonWidth)
            $0.trailing.equalTo(snp.centerX)
                .offset(-AppLayoutConstants.spacing)
        }
        
        imageLoadButton.snp.makeConstraints {
            $0.top.equalTo(imageView.snp.bottom)
                .offset(AppLayoutConstants.spacing)
            $0.width.equalTo(LayoutConstants.buttonWidth)
            $0.leading.equalTo(snp.centerX)
                .offset(AppLayoutConstants.spacing)
        }
    }
}
