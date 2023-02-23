//
//  WritingScheduleView.swift
//  YeolmokTravel
//
//  Created by 김동욱 on 2023/02/22.
//

import UIKit

final class WritingScheduleView: UIView {
    private enum TextConstants {
        static let from = "From"
        static let to = "To"
        static let latitudePlaceholder = "latitude"
        static let longitudePlaceholder = "longitude"
        static let buttonTitle = "Show Map"
        static let mapIcon = "map"
    }
    
    private enum LayoutConstants {
        static let cornerRadius: CGFloat = 5
        static let mediumFontSize: CGFloat = 20
        static let descriptionTextViewHeight: CGFloat = 100
        static let dateBackgroundViewHeight: CGFloat = 170
        static let buttonHeight: CGFloat = 44.44
        static let buttonWidthMultiplier: CGFloat = 4
    }
    
    // MARK: - Properties
    let titleTextField = TextFieldFactory
        .makeTitleTextField(
            AppLayoutConstants.largeFontSize,
            AppTextConstants.titlePlaceholder
        )
    
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
    
    // 날짜 관련 뷰
    let dateBackgroundView: UIView = {
        let view = UIView()
        view.layer.borderWidth = AppLayoutConstants.borderWidth
        view.layer.borderColor = UIColor.white.cgColor
        view.backgroundColor = .darkGray
        return view
    }()
    
    let dateSwitch: UISwitch = {
        let `switch` = UISwitch()
        `switch`.isOn = false
        return `switch`
    }()
    
    private let fromLabel: UILabel = {
        let label = UILabel()
        label.text = TextConstants.from
        label.font = .boldSystemFont(ofSize: LayoutConstants.mediumFontSize)
        label.textAlignment = .center
        label.textColor = .white
        return label
    }()
    
    let fromDatePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.preferredDatePickerStyle = .compact
        datePicker.datePickerMode = .date
        datePicker.tintColor = AppStyles.mainColor
        datePicker.backgroundColor = .systemGray
        datePicker.isEnabled = false
        return datePicker
    }()
    
    private let toLabel: UILabel = {
        let label = UILabel()
        label.text = TextConstants.to
        label.font = .boldSystemFont(ofSize: LayoutConstants.mediumFontSize)
        label.textAlignment = .center
        label.textColor = .white
        return label
    }()
    
    let toDatePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.preferredDatePickerStyle = .compact
        datePicker.datePickerMode = .date
        datePicker.tintColor = AppStyles.mainColor
        datePicker.backgroundColor = .systemGray
        datePicker.isEnabled = false
        return datePicker
    }()
    
    /*
     좌표값 관련 뷰
      - 위도 입력 텍스트필드
      - 경도 입력 텍스트필드
      - MapView를 보여줄 버튼
     */
    let latitudeTextField: UITextField = {
        let textField = TextFieldFactory.makeTitleTextField(
            LayoutConstants.mediumFontSize,
            TextConstants.longitudePlaceholder
        )
        textField.keyboardType = .decimalPad
        
        return textField
    }()
    
    let longitudeTextField: UITextField = {
        let textField = TextFieldFactory.makeTitleTextField(
            LayoutConstants.mediumFontSize,
            TextConstants.longitudePlaceholder
        )
        textField.keyboardType = .decimalPad
        return textField
    }()
    
    lazy var mapButton: UIButton = {
        let button = createConfigurationButton()
        button.tintColor = .systemBackground
        button.layer.cornerRadius = LayoutConstants.cornerRadius
        button.layer.borderWidth = AppLayoutConstants.borderWidth
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

private extension WritingScheduleView {
    func configureView() {
        configureHierarchy()
        configureLayoutConstraint()
    }
    
    func configureHierarchy() {
        [dateSwitch, fromLabel, fromDatePicker, toLabel, toDatePicker].forEach {
            dateBackgroundView.addSubview($0)
        }
        
        [titleTextField, descriptionTextView, dateBackgroundView, latitudeTextField, longitudeTextField, mapButton].forEach {
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
            $0.height.equalTo(LayoutConstants.descriptionTextViewHeight)
        }
        
        dateBackgroundView.snp.makeConstraints {
            $0.top.equalTo(descriptionTextView.snp.bottom)
                .offset(AppLayoutConstants.largeSpacing)
            $0.leading.trailing.equalToSuperview()
                .inset(AppLayoutConstants.spacing)
            $0.height.equalTo(LayoutConstants.dateBackgroundViewHeight)
        }
        
        dateSwitch.snp.makeConstraints {
            $0.top.equalToSuperview()
                .offset(AppLayoutConstants.spacing)
            $0.trailing.equalToSuperview()
                .inset(AppLayoutConstants.largeSpacing)
        }
        
        fromLabel.snp.makeConstraints {
            $0.top.equalTo(dateSwitch.snp.bottom)
                .offset(AppLayoutConstants.largeSpacing)
            $0.leading.equalToSuperview()
                .inset(AppLayoutConstants.largeSpacing)
        }
        
        fromDatePicker.snp.makeConstraints {
            $0.centerY.equalTo(fromLabel.snp.centerY)
            $0.trailing.equalToSuperview()
                .inset(AppLayoutConstants.largeSpacing)
        }
        
        toLabel.snp.makeConstraints {
            $0.top.equalTo(fromLabel.snp.bottom)
                .offset(AppLayoutConstants.largeSpacing)
            $0.leading.equalToSuperview()
                .inset(AppLayoutConstants.largeSpacing)
        }
        
        toDatePicker.snp.makeConstraints {
            $0.centerY.equalTo(toLabel.snp.centerY)
            $0.trailing.equalToSuperview()
                .inset(AppLayoutConstants.largeSpacing)
        }
        
        latitudeTextField.snp.makeConstraints {
            $0.top.equalTo(dateBackgroundView.snp.bottom)
                .offset(AppLayoutConstants.largeSpacing)
            $0.leading.trailing.equalToSuperview()
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
            .withTintColor(.systemBackground, renderingMode: .alwaysTemplate)
        configuration.imagePlacement = .leading
        configuration.imagePadding = AppLayoutConstants.spacing
        return UIButton(configuration: configuration)
    }
}
