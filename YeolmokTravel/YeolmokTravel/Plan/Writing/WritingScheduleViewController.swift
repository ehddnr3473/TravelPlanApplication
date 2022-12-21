//
//  WritingScheduleViewController.swift
//  YeolmokTravel
//
//  Created by 김동욱 on 2022/12/20.
//

import UIKit

/// 여행 계획 추가 및 수정을 위한 ViewController
class WritingScheduleViewController: UIViewController, Writable {
    typealias ModelType = Schedule
    // MARK: - Properties
    var model: WritablePlan<ModelType>!
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
    
    private let datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        
        datePicker.preferredDatePickerStyle = .inline
        datePicker.backgroundColor = .systemGray
        datePicker.tintColor = .systemGreen
        
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
        setUpHierachy()
        setUpLayout()
    }
    
    private func setUpHierachy() {
        [cancelBarButton, barTitleLabel, saveBarButton].forEach {
            topBarStackView.addArrangedSubview($0)
        }
        
        [topBarStackView, titleTextField, descriptionTextView, datePicker].forEach {
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
        
        datePicker.snp.makeConstraints {
            $0.top.equalTo(descriptionTextView.snp.bottom)
                .offset(LayoutConstants.spacing)
            $0.centerX.equalToSuperview()
        }
    }
    
    @objc func touchUpSaveBarButton() {
        model.setPlan(titleTextField.text ?? "", descriptionTextView.text)
        if model.titleIsEmpty() {
            alertWillAppear()
            return
        } else {
            save(model.plan, scheduleListIndex)
            dismiss(animated: true)
        }
    }
    
    @objc func touchUpCancelBarButton() {
        model.setPlan(titleTextField.text ?? "", descriptionTextView.text)
        if model.isChanged {
            let actionSheetText = fetchActionSheetText()
            actionSheetWillApear(actionSheetText.0, actionSheetText.1)
        } else {
            dismiss(animated: true)
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
}

private enum TextConstants {
    static let saveButtonTitle = "Save"
    static let cancelButtonTItle = "Cancel"
    static let plan = "Plan"
    static let descriptionPlaceolder = "상세"
    static let schedule = "Schedule"
    static let plusIcon = "plus"
}
