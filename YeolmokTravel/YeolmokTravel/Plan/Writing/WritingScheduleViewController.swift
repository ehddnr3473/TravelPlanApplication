//
//  WritingScheduleViewController.swift
//  YeolmokTravel
//
//  Created by 김동욱 on 2022/12/20.
//

import UIKit

/// 여행 계획 추가 및 수정을 위한 ViewController
final class WritingScheduleViewController: UIViewController, Writable {
    typealias ModelType = Schedule
    // MARK: - Properties
    var planTracker: PlanTracker<ModelType>!
    var model: ModelType! {
        didSet {
            planTracker = PlanTracker(model)
        }
    }
    var writingStyle: WritingStyle!
    var addDelegate: PlanTransfer?
    var editDelegate: PlanTransfer?
    var scheduleListIndex: Int? // 여행 계획 '추가'를 위해 프레젠테이션했다면 nil.
    
    private let topBarStackView: UIStackView = {
        let stackView = UIStackView()
        
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
    
    private let barTitleLabel: UILabel = {
        let label = UILabel()
        
        label.textAlignment = .center
        label.font = .boldSystemFont(ofSize: LayoutConstants.largeFontSize)
        label.textColor = .white
        
        return label
    }()
    
    private lazy var saveBarButton: UIButton = {
        let button = UIButton(type: .custom)
        
        button.setTitle(TextConstants.saveButtonTitle, for: .normal)
        button.addTarget(self, action: #selector(touchUpSaveBarButton), for: .touchUpInside)
        button.setTitleColor(AppStyles.mainColor, for: .normal)
        
        return button
    }()
    
    private lazy var cancelBarButton: UIButton = {
        let button = UIButton(type: .custom)
        
        button.setTitle(TextConstants.cancelButtonTItle, for: .normal)
        button.addTarget(self, action: #selector(touchUpCancelBarButton), for: .touchUpInside)
        
        return button
    }()
    
    private let titleTextField: UITextField = {
        let textField = UITextField()
        
        textField.textColor = .white
        textField.backgroundColor = .black
        textField.layer.cornerRadius = LayoutConstants.cornerRadius
        textField.layer.borderWidth = LayoutConstants.borderWidth
        textField.layer.borderColor = UIColor.white.cgColor
        textField.font = .boldSystemFont(ofSize: LayoutConstants.largeFontSize)
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none
        
        textField.leftView = UIView(frame: CGRect(x: .zero,
                                                  y: .zero,
                                                  width: LayoutConstants.spacing,
                                                  height: .zero))
        textField.leftViewMode = .always
        
        return textField
    }()
    
    private let descriptionTextView: UITextView = {
        let textView = UITextView()
        
        textView.textColor = .white
        textView.backgroundColor = .black
        textView.layer.cornerRadius = LayoutConstants.cornerRadius
        textView.layer.borderWidth = LayoutConstants.borderWidth
        textView.layer.borderColor = UIColor.white.cgColor
        textView.font = .boldSystemFont(ofSize: LayoutConstants.mediumFontSize)
        
        return textView
    }()
    
    private let dateBackgroundView: UIView = {
        let view = UIView()
        
        view.layer.borderWidth = LayoutConstants.borderWidth
        view.layer.borderColor = UIColor.white.cgColor
        view.backgroundColor = .darkGray
        
        return view
    }()
    
    private lazy var dateSwitch: UISwitch = {
        let `switch` = UISwitch()
        
        `switch`.isOn = false
        `switch`.addTarget(self, action: #selector(toggleSwitch), for: .valueChanged)
        
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
    
    private let fromDatePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        
        datePicker.preferredDatePickerStyle = .compact
        datePicker.datePickerMode = .date
        datePicker.tintColor = .systemGreen
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
    
    private let toDatePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        
        datePicker.preferredDatePickerStyle = .compact
        datePicker.datePickerMode = .date
        datePicker.tintColor = .systemGreen
        datePicker.backgroundColor = .systemGray
        datePicker.isEnabled = false
        
        return datePicker
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
    }
}

extension WritingScheduleViewController {
    private func setUpUI() {
        view.backgroundColor = .black
        
        switch writingStyle {
        case .add:
            barTitleLabel.text = "\(writingStyle.rawValue) \(TextConstants.schedule)"
        case .edit:
            barTitleLabel.text = "\(writingStyle.rawValue) \(TextConstants.schedule)"
        case .none:
            break
        }
        
        setUpUIValue()
        setUpHierachy()
        setUpLayout()
    }
    
    private func setUpHierachy() {
        [cancelBarButton, barTitleLabel, saveBarButton].forEach {
            topBarStackView.addArrangedSubview($0)
        }
        
        [dateSwitch, fromLabel, fromDatePicker, toLabel, toDatePicker].forEach {
            dateBackgroundView.addSubview($0)
        }
        
        [topBarStackView, titleTextField, descriptionTextView, dateBackgroundView].forEach {
            view.addSubview($0)
        }
    }
    
    private func setUpLayout() {
        topBarStackView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            $0.width.equalToSuperview()
            $0.height.greaterThanOrEqualTo(LayoutConstants.stackViewHeight)
        }
        
        titleTextField.snp.makeConstraints {
            $0.top.equalTo(topBarStackView.snp.bottom).offset(LayoutConstants.largeSpacing)
            $0.leading.trailing.equalToSuperview()
                .inset(LayoutConstants.spacing)
        }
        
        descriptionTextView.snp.makeConstraints {
            $0.top.equalTo(titleTextField.snp.bottom)
                .offset(LayoutConstants.spacing)
            $0.leading.trailing.equalToSuperview()
                .inset(LayoutConstants.spacing)
            $0.height.equalTo(LayoutConstants.descriptionTextViewHeight)
        }
        
        dateBackgroundView.snp.makeConstraints {
            $0.top.equalTo(descriptionTextView.snp.bottom)
                .offset(LayoutConstants.largeSpacing)
            $0.leading.trailing.equalToSuperview()
                .inset(LayoutConstants.spacing)
            $0.height.equalTo(LayoutConstants.dateBackgroundViewHeight)
        }
        
        dateSwitch.snp.makeConstraints {
            $0.top.equalToSuperview()
                .offset(LayoutConstants.spacing)
            $0.trailing.equalToSuperview()
                .inset(LayoutConstants.largeSpacing)
        }
        
        fromLabel.snp.makeConstraints {
            $0.top.equalTo(dateSwitch.snp.bottom)
                .offset(LayoutConstants.largeSpacing)
            $0.leading.equalToSuperview()
                .inset(LayoutConstants.largeSpacing)
        }
        
        fromDatePicker.snp.makeConstraints {
            $0.centerY.equalTo(fromLabel.snp.centerY)
            $0.trailing.equalToSuperview()
                .inset(LayoutConstants.largeSpacing)
        }
        
        toLabel.snp.makeConstraints {
            $0.top.equalTo(fromLabel.snp.bottom)
                .offset(LayoutConstants.largeSpacing)
            $0.leading.equalToSuperview()
                .inset(LayoutConstants.largeSpacing)
        }
        
        toDatePicker.snp.makeConstraints {
            $0.centerY.equalTo(toLabel.snp.centerY)
            $0.trailing.equalToSuperview()
                .inset(LayoutConstants.largeSpacing)
        }
    }
    
    private func setUpUIValue() {
        titleTextField.text = model.title
        descriptionTextView.text = model.description
        
        if let fromDate = model.fromDate, let toDate = model.toDate {
            dateSwitch.isOn = true
            fromDatePicker.isEnabled = true
            toDatePicker.isEnabled = true
            fromDatePicker.date = fromDate
            toDatePicker.date = toDate
        }
    }
    
    @objc func touchUpSaveBarButton() {
        if titleTextField.text == "" {
            alertWillAppear(AlertText.titleMessage)
            return
        }
        
        if fromDatePicker.date > toDatePicker.date {
            alertWillAppear(AlertText.dateMessage)
            return
        }
        
        if dateSwitch.isOn {
            model.setSchedule(titleTextField.text ?? "",
                              descriptionTextView.text,
                              fromDatePicker.date,
                              toDatePicker.date)
        } else {
            model.setSchedule(titleTextField.text ?? "", descriptionTextView.text)
        }
        save(model, scheduleListIndex)
        dismiss(animated: true)
        
    }
    
    @objc func touchUpCancelBarButton() {
        if dateSwitch.isOn {
            planTracker.setPlan(titleTextField.text ?? "",
                                descriptionTextView.text,
                                fromDatePicker.date,
                                toDatePicker.date)
        } else {
            planTracker.setPlan(titleTextField.text ?? "", descriptionTextView.text)
        }
        
        if planTracker.isChanged {
            let actionSheetText = fetchActionSheetText()
            actionSheetWillApear(actionSheetText.0, actionSheetText.1)
        } else {
            dismiss(animated: true)
        }
    }
    
    @objc func toggleSwitch() {
        if dateSwitch.isOn {
            fromDatePicker.backgroundColor = .white
            fromDatePicker.isEnabled = true
            toDatePicker.backgroundColor = .white
            toDatePicker.isEnabled = true
        } else {
            fromDatePicker.backgroundColor = .systemGray
            fromDatePicker.isEnabled = false
            toDatePicker.backgroundColor = .systemGray
            toDatePicker.isEnabled = false
        }
    }
}

private enum LayoutConstants {
    static let spacing: CGFloat = 8
    static let largeSpacing: CGFloat = 20
    static let stackViewCornerRadius: CGFloat = 10
    static let cornerRadius: CGFloat = 5
    static let tableViewCornerRadius: CGFloat = 10
    static let borderWidth: CGFloat = 1
    static let largeFontSize: CGFloat = 25
    static let mediumFontSize: CGFloat = 20
    static let topBottomMargin: CGFloat = 10
    static let sideMargin: CGFloat = 15
    static let stackViewHeight: CGFloat = 50
    static let schedultTitleLeading: CGFloat = 15
    static let cellHeight: CGFloat = 100
    static let descriptionTextViewHeight: CGFloat = 100
    static let dateBackgroundViewHeight: CGFloat = 170
}

private enum TextConstants {
    static let saveButtonTitle = "Save"
    static let cancelButtonTItle = "Cancel"
    static let schedule = "Schedules"
    static let from = "From"
    static let to = "To"
}
