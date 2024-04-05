//
//  WritingScheduleView.swift
//  YeolmokTravel
//
//  Created by 김동욱 on 2023/02/22.
//

import UIKit

import JGProgressHUD

final class WritingScheduleView: UIView {
    // MARK: - Magic number/string
    @frozen private enum LayoutConstants {
        static let cornerRadius: CGFloat = 5
        static let mediumFontSize: CGFloat = 20
        static let descriptionTextViewHeight: CGFloat = 100
        static let dateContainerViewHeight: CGFloat = 170
        static let coordinateContainerViewHeight: CGFloat = 220
        static let buttonHeight: CGFloat = 44.44
        static let buttonWidthMultiplier: CGFloat = 4
    }
    
    @frozen private enum TextConstants {
        static let from = "From"
        static let to = "To"
        static let latitudePlaceholder = "latitude"
        static let longitudePlaceholder = "longitude"
        static let buttonTitle = "Show Map"
        static let mapIcon = "map"
        static let coordinateSearchTextFieldPlaceholder = "Type place name or address."
    }
    
    @frozen private enum IndicatorConstants {
        static let titleText = "Searching.."
        static let detailText = "Please wait"
    }
    
    // MARK: - Properties
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.isScrollEnabled = false
        return scrollView
    }()
    
    let contentView = UIView()
    
    let titleTextField = UITextField()
        .makeCustomTextField()
        .withFontSize(AppLayoutConstants.largeFontSize)
        .withPlaceholder(AppTextConstants.titlePlaceholder)
    
    let descriptionTextView: UITextView = {
        let textView = UITextView()
        textView.textColor = AppStyles.getAccentColor()
        textView.backgroundColor = .systemBackground
        textView.layer.cornerRadius = LayoutConstants.cornerRadius
        textView.layer.borderWidth = AppLayoutConstants.borderWidth
        textView.layer.borderColor = AppStyles.getBorderColor()
        textView.font = .boldSystemFont(ofSize: LayoutConstants.mediumFontSize)
        textView.autocorrectionType = .no
        textView.autocapitalizationType = .none
        return textView
    }()
    
    // 날짜 관련 뷰
    private let dateContainerView: UIView = {
        let view = UIView()
        view.layer.borderWidth = AppLayoutConstants.borderWidth
        view.layer.borderColor = AppStyles.getBorderColor()
        view.backgroundColor = AppStyles.getContentBackgroundColor()
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
        label.textColor = AppStyles.getAccentColor()
        return label
    }()
    
    let fromDatePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.preferredDatePickerStyle = .compact
        datePicker.datePickerMode = .date
        datePicker.tintColor = AppStyles.mainColor
        datePicker.backgroundColor = AppStyles.getContentBackgroundColor()
        datePicker.isEnabled = false
        return datePicker
    }()
    
    private let toLabel: UILabel = {
        let label = UILabel()
        label.text = TextConstants.to
        label.font = .boldSystemFont(ofSize: LayoutConstants.mediumFontSize)
        label.textAlignment = .center
        label.textColor = AppStyles.getAccentColor()
        return label
    }()
    
    let toDatePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.preferredDatePickerStyle = .compact
        datePicker.datePickerMode = .date
        datePicker.tintColor = AppStyles.mainColor
        datePicker.backgroundColor = .systemBackground
        datePicker.isEnabled = false
        return datePicker
    }()
    
    /*
     좌표값 관련 뷰
      - 위도 입력 텍스트필드
      - 경도 입력 텍스트필드
      - MapView를 보여줄 버튼
     */
    
    private let coordinateContainerView: UIView = {
        let view = UIView()
        view.layer.borderWidth = AppLayoutConstants.borderWidth
        view.layer.borderColor = AppStyles.getBorderColor()
        view.backgroundColor = AppStyles.getContentBackgroundColor()
        return view
    }()
    
    let coordinateSearchTextField: UISearchTextField = {
        let searchTextField = UISearchTextField()
        searchTextField.autocorrectionType = .no
        searchTextField.autocapitalizationType = .none
        searchTextField.returnKeyType = .search
        searchTextField.placeholder = TextConstants.coordinateSearchTextFieldPlaceholder
        searchTextField.backgroundColor = .systemBackground
        return searchTextField
    }()
    
    let latitudeTextField = UITextField()
        .makeCustomTextField()
        .withFontSize(LayoutConstants.mediumFontSize)
        .withPlaceholder(TextConstants.latitudePlaceholder)
        .withKeyboardType(.decimalPad)
    
    let longitudeTextField = UITextField()
        .makeCustomTextField()
        .withFontSize(LayoutConstants.mediumFontSize)
        .withPlaceholder(TextConstants.longitudePlaceholder)
        .withKeyboardType(.decimalPad)
    
    lazy var mapButton: UIButton = {
        let button = createConfigurationButton()
        button.tintColor = .systemBackground
        button.layer.cornerRadius = LayoutConstants.cornerRadius
        button.layer.borderWidth = AppLayoutConstants.borderWidth
        button.layer.borderColor = UIColor.systemGray.cgColor
        button.backgroundColor = AppStyles.mainColor
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
        super.init(coder: coder)
    }
}

// MARK: - Configure view
private extension WritingScheduleView {
    func configureView() {
        configureHierarchy()
        configureLayoutConstraint()
    }
    
    func configureHierarchy() {
        [dateSwitch, fromLabel, fromDatePicker, toLabel, toDatePicker].forEach {
            dateContainerView.addSubview($0)
        }
        
        [coordinateSearchTextField, latitudeTextField, longitudeTextField, mapButton].forEach {
            coordinateContainerView.addSubview($0)
        }
        
        [titleTextField, descriptionTextView, dateContainerView, coordinateContainerView].forEach {
            contentView.addSubview($0)
        }
        
        scrollView.addSubview(contentView)
        addSubview(scrollView)
    }
    
    func configureLayoutConstraint() {
        scrollView.snp.makeConstraints {
            $0.top.leading.trailing.bottom.equalToSuperview()
        }
        
        contentView.snp.makeConstraints {
            $0.top.equalTo(scrollView.contentLayoutGuide.snp.top)
            $0.leading.equalTo(scrollView.contentLayoutGuide.snp.leading)
            $0.bottom.equalTo(scrollView.contentLayoutGuide.snp.bottom)
            $0.trailing.equalTo(scrollView.contentLayoutGuide.snp.trailing)
            
            $0.width.equalTo(scrollView.frameLayoutGuide.snp.width)
            $0.height.equalTo(scrollView.frameLayoutGuide.snp.height)
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
            $0.height.equalTo(LayoutConstants.descriptionTextViewHeight)
        }
        
        dateContainerView.snp.makeConstraints {
            $0.top.equalTo(descriptionTextView.snp.bottom)
                .offset(AppLayoutConstants.largeSpacing)
            $0.leading.trailing.equalToSuperview()
                .inset(AppLayoutConstants.spacing)
            $0.height.equalTo(LayoutConstants.dateContainerViewHeight)
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
        
        coordinateContainerView.snp.makeConstraints {
            $0.top.equalTo(dateContainerView.snp.bottom)
                .offset(AppLayoutConstants.largeSpacing)
            $0.leading.trailing.equalToSuperview()
                .inset(AppLayoutConstants.spacing)
            $0.height.equalTo(LayoutConstants.coordinateContainerViewHeight)
        }
        
        coordinateSearchTextField.snp.makeConstraints {
            $0.top.equalToSuperview()
                .inset(AppLayoutConstants.largeSpacing)
            $0.leading.trailing.equalToSuperview()
                .inset(AppLayoutConstants.spacing)
        }
        
        latitudeTextField.snp.makeConstraints {
            $0.top.equalTo(coordinateSearchTextField.snp.bottom)
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
                .offset(AppLayoutConstants.largeSpacing)
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
