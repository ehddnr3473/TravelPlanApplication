//
//  WritingTravelPlanView.swift
//  YeolmokTravel
//
//  Created by 김동욱 on 2023/02/04.
//

import UIKit

final class WritingTravelPlanView: UIView {
    // MARK: - Properties
    let titleTextField: UITextField = {
        let textField = UITextField()
        textField.textColor = .white
        textField.backgroundColor = .black
        textField.layer.cornerRadius = LayoutConstants.cornerRadius
        textField.layer.borderWidth = AppLayoutConstants.borderWidth
        textField.layer.borderColor = UIColor.white.cgColor
        textField.font = .boldSystemFont(ofSize: AppLayoutConstants.largeFontSize)
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none
        
        textField.leftView = UIView(frame: CGRect(x: .zero,
                                                  y: .zero,
                                                  width: AppLayoutConstants.spacing,
                                                  height: .zero))
        textField.leftViewMode = .always
        return textField
    }()
    
    let descriptionTextView: UITextView = {
        let textView = UITextView()
        textView.textColor = .white
        textView.backgroundColor = .black
        textView.layer.cornerRadius = LayoutConstants.cornerRadius
        textView.layer.borderWidth = AppLayoutConstants.borderWidth
        textView.layer.borderColor = UIColor.white.cgColor
        textView.font = .boldSystemFont(ofSize: LayoutConstants.mediumFontSize)
        return textView
    }()
    
    private let scheduleTitleLabel: UILabel = {
        let label = UILabel()
        label.text = TextConstants.schedule
        label.textAlignment = .center
        label.textColor = .white
        label.font = .boldSystemFont(ofSize: AppLayoutConstants.largeFontSize)
        return label
    }()
    
    lazy var addScheduleButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setBackgroundImage(UIImage(systemName: TextConstants.plusIcon), for: .normal)
        button.tintColor = AppStyles.mainColor
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
private extension WritingTravelPlanView {
    func configureView() {
        configureHierarchy()
        configureLayoutConstraint()
    }
    
    func configureHierarchy() {
        [titleTextField, descriptionTextView, scheduleTitleLabel, addScheduleButton].forEach {
            addSubview($0)
        }
    }
    
    func configureLayoutConstraint() {
        titleTextField.snp.makeConstraints {
            $0.top.equalToSuperview()
                .inset(AppLayoutConstants.spacing)
            $0.leading.trailing.equalToSuperview()
                .inset(AppLayoutConstants.spacing)
        }
        
        descriptionTextView.snp.makeConstraints {
            $0.top.equalTo(titleTextField.snp.bottom)
                .offset(AppLayoutConstants.spacing)
            $0.leading.trailing.equalToSuperview()
                .inset(AppLayoutConstants.spacing)
            $0.height.equalTo(LayoutConstants.textViewHeight)
        }
        
        scheduleTitleLabel.snp.makeConstraints {
            $0.top.equalTo(descriptionTextView.snp.bottom)
                .offset(AppLayoutConstants.largeSpacing)
            $0.leading.equalToSuperview()
                .inset(AppLayoutConstants.spacing)
        }
        
        addScheduleButton.snp.makeConstraints {
            $0.centerY.equalTo(scheduleTitleLabel)
            $0.trailing.equalToSuperview()
                .inset(AppLayoutConstants.spacing)
            $0.width.height.equalTo(LayoutConstants.buttonLength)
        }
    }
}

private enum LayoutConstants {
    static let cornerRadius: CGFloat = 5
    static let mediumFontSize: CGFloat = 20
    static let textViewHeight: CGFloat = 100
    static let buttonLength: CGFloat = 30
}

private enum TextConstants {
    static let schedule = "Schedule"
    static let plusIcon = "plus"
}
