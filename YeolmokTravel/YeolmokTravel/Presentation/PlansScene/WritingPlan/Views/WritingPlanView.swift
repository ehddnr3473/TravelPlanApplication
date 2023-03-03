//
//  WritingPlanView.swift
//  YeolmokTravel
//
//  Created by 김동욱 on 2023/02/04.
//

import UIKit
import MapKit

final class WritingPlanView: UIView {
    // MARK: - Magic number/string
    @frozen enum Constants {
        // titleTextField + descriptionTextView + schduleTitleLabel
        static let nonSpacingHeightFromTitleLabelToScheduleLabel: CGFloat = 170
    }
    
    @frozen private enum LayoutConstants {
        static let cornerRadius: CGFloat = 5
        static let mediumFontSize: CGFloat = 20
        static let textViewHeight: CGFloat = 100
        static let buttonLength: CGFloat = 30
    }
    
    @frozen private enum TextConstants {
        static let schedule = "Schedule"
    }
    
    // MARK: - Properties
    let titleTextField = UITextField()
        .makeCustomTextField()
        .withFontSize(AppLayoutConstants.largeFontSize)
        .withPlaceholder(AppTextConstants.titlePlaceholder)
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.isScrollEnabled = true
        return scrollView
    }()
    
    let contentView = UIView()
    
    let descriptionTextView: UITextView = {
        let textView = UITextView()
        textView.textColor = .white
        textView.backgroundColor = .systemBackground
        textView.layer.cornerRadius = LayoutConstants.cornerRadius
        textView.layer.borderWidth = AppLayoutConstants.borderWidth
        textView.layer.borderColor = UIColor.white.cgColor
        textView.font = .boldSystemFont(ofSize: LayoutConstants.mediumFontSize)
        textView.autocorrectionType = .no
        textView.autocapitalizationType = .none
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
    
    let editScheduleButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setBackgroundImage(UIImage(systemName: AppTextConstants.editIcon), for: .normal)
        button.tintColor = AppStyles.mainColor
        return button
    }()
    
    let createScheduleButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setBackgroundImage(UIImage(systemName: AppTextConstants.plusIcon), for: .normal)
        button.tintColor = AppStyles.mainColor
        return button
    }()
    
    // MARK: - Init
    init(frame: CGRect,
         scrollViewContainerHeight: CGFloat) {
        super.init(frame: frame)
        backgroundColor = .systemBackground
        configureHierarchy()
        configureLayoutConstraint(scrollViewContainerHeight)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Configure view
private extension WritingPlanView {
    func configureHierarchy() {
        [titleTextField, descriptionTextView, scheduleTitleLabel, editScheduleButton, createScheduleButton].forEach {
            contentView.addSubview($0)
        }
        
        scrollView.addSubview(contentView)
        addSubview(scrollView)
    }
    
    func configureLayoutConstraint(_ scrollViewContainerHeight: CGFloat) {
        scrollView.snp.makeConstraints {
            $0.top.leading.bottom.trailing.equalToSuperview()
        }
        
        contentView.snp.makeConstraints {
            $0.top.equalTo(scrollView.contentLayoutGuide.snp.top)
            $0.leading.equalTo(scrollView.contentLayoutGuide.snp.leading)
            $0.bottom.equalTo(scrollView.contentLayoutGuide.snp.bottom)
            $0.trailing.equalTo(scrollView.contentLayoutGuide.snp.trailing)
            
            $0.width.equalTo(scrollView.frameLayoutGuide.snp.width)
            $0.height.equalTo(scrollViewContainerHeight)
        }
        
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
        
        createScheduleButton.snp.makeConstraints {
            $0.centerY.equalTo(scheduleTitleLabel)
            $0.trailing.equalToSuperview()
                .inset(AppLayoutConstants.spacing)
            $0.width.height.equalTo(LayoutConstants.buttonLength)
        }
        
        editScheduleButton.snp.makeConstraints {
            $0.centerY.equalTo(scheduleTitleLabel)
            $0.trailing.equalTo(createScheduleButton.snp.leading)
                .offset(-AppLayoutConstants.spacing)
            $0.width.height.equalTo(LayoutConstants.buttonLength)
        }
    }
}
