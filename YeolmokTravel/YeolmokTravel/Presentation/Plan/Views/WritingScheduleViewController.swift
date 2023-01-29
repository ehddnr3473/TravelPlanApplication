//
//  WritingScheduleViewController.swift
//  YeolmokTravel
//
//  Created by 김동욱 on 2022/12/20.
//

import UIKit
import Combine

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
    var scheduleListIndex: Int?
    var viewModel: WritingPlanViewModel!
    private var subscriptions = Set<AnyCancellable>()
    
    deinit {
        print("deinit: WritingScheduleViewController")
    }
    
    private let topBarView: TopBarView = {
        let topBarView = TopBarView()
        return topBarView
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
        setBindings()
    }
}

private extension WritingScheduleViewController {
    func setUpUI() {
        view.backgroundColor = .black
        topBarView.barTitleLabel.text = "\(writingStyle.rawValue) \(TextConstants.schedule)"
        topBarView.saveBarButton.addTarget(self, action: #selector(touchUpSaveBarButton), for: .touchUpInside)
        topBarView.cancelBarButton.addTarget(self, action: #selector(touchUpCancelBarButton), for: .touchUpInside)
        // 수정을 위한 ViewController라면 navigationBar 사용
        if !isAdding {
            navigationItem.titleView = topBarView.barTitleLabel
            navigationItem.leftBarButtonItem = UIBarButtonItem(customView: topBarView.cancelBarButton)
            navigationItem.rightBarButtonItem = UIBarButtonItem(customView: topBarView.saveBarButton)
        }
        
        setUpUIValue()
        setUpHierachy()
        setUpLayout()
    }
    
    func setUpHierachy() {
        [dateSwitch, fromLabel, fromDatePicker, toLabel, toDatePicker].forEach {
            dateBackgroundView.addSubview($0)
        }
        // 추가를 위한 ViewController라면 커스텀 바를 사용
        if isAdding {
            view.addSubview(topBarView)
        }
        
        [titleTextField, descriptionTextView, dateBackgroundView].forEach {
            view.addSubview($0)
        }
    }
    
    func setUpLayout() {
        if isAdding {
            topBarView.snp.makeConstraints {
                $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
                $0.width.equalToSuperview()
                $0.height.greaterThanOrEqualTo(LayoutConstants.stackViewHeight)
            }
        }
        
        titleTextField.snp.makeConstraints {
            if isAdding {
                $0.top.equalTo(topBarView.snp.bottom).offset(LayoutConstants.largeSpacing)
            } else {
                $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
                    .offset(LayoutConstants.largeSpacing)
            }
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
    
    func setUpUIValue() {
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
        // title이 비어있는지 검증
        if titleTextField.text == "" {
            alertWillAppear(AlertText.titleMessage)
            return
        // 시작 날짜가 종료 날짜 이후인지 검증
        } else if fromDatePicker.date > toDatePicker.date {
            alertWillAppear(AlertText.dateMessage)
            return
        // 날짜를 설정할건지 확인
        } else if dateSwitch.isOn {
            model.setSchedule(titleTextField.text ?? "",
                              descriptionTextView.text,
                              fromDatePicker.date,
                              toDatePicker.date)
        } else {
            model.setSchedule(titleTextField.text ?? "", descriptionTextView.text)
        }
        save(model, scheduleListIndex)
        if !isAdding {
            navigationController?.popViewController(animated: true)
        } else {
            dismiss(animated: true)
        }
        
    }
    
    @objc func touchUpCancelBarButton() {
        if dateSwitch.isOn {
            planTracker.setPlan(Schedule(title: titleTextField.text ?? "",
                                         description: descriptionTextView.text,
                                         fromDate: fromDatePicker.date,
                                         toDate: toDatePicker.date))
        } else {
            planTracker.setPlan(Schedule(title: titleTextField.text ?? "", description: descriptionTextView.text))
        }
        if planTracker.isChanged {
            let actionSheetText = fetchActionSheetText()
            actionSheetWillApear(actionSheetText.0, actionSheetText.1, writingStyle)
        } else {
            if !isAdding {
                navigationController?.popViewController(animated: true)
            } else {
                dismiss(animated: true)
            }
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
    
    func setBindings() {
        let input = WritingPlanViewModel.Input(title: titleTextField.textPublisher)
        
        let output = viewModel.transform(input: input)
        
        output.buttonState
            .receive(on: RunLoop.main)
            .sink { [weak self] state in
                self?.topBarView.saveBarButton.isEnabled = state
            }
            .store(in: &subscriptions)
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
