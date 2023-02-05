//
//  WritingScheduleViewController.swift
//  YeolmokTravel
//
//  Created by 김동욱 on 2022/12/20.
//

import UIKit
import Combine
import CoreLocation

/// 여행 계획 추가 및 수정을 위한 ViewController
final class WritingScheduleViewController: UIViewController, Writable {
    typealias WritableModelType = Schedule
    // MARK: - Properties
    var writingStyle: WritingStyle
    var addDelegate: PlanTransfer?
    var editDelegate: PlanTransfer?
    var scheduleListIndex: Int?
    var viewModel: WritingScheduleViewModel
    
    private let descriptionTextPublisher = PassthroughSubject<String, Never>()
    private var subscriptions = Set<AnyCancellable>()
    
    init(_ viewModel: WritingScheduleViewModel, writingStyle: WritingStyle) {
        self.viewModel = viewModel
        self.writingStyle = writingStyle
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) not implemented")
    }
    
    deinit {
        print("deinit: WritingScheduleViewController")
    }
    
    private lazy var topBarView: TopBarView = {
        let topBarView = TopBarView()
        return topBarView
    }()
    
    private let titleTextField: UITextField = {
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
    
    private let descriptionTextView: UITextView = {
        let textView = UITextView()
        
        textView.textColor = .white
        textView.backgroundColor = .black
        textView.layer.cornerRadius = LayoutConstants.cornerRadius
        textView.layer.borderWidth = AppLayoutConstants.borderWidth
        textView.layer.borderColor = UIColor.white.cgColor
        textView.font = .boldSystemFont(ofSize: LayoutConstants.mediumFontSize)
        
        return textView
    }()
    
    private let dateBackgroundView: UIView = {
        let view = UIView()
        
        view.layer.borderWidth = AppLayoutConstants.borderWidth
        view.layer.borderColor = UIColor.white.cgColor
        view.backgroundColor = .darkGray
        
        return view
    }()
    
    private lazy var dateSwitch: UISwitch = {
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
    
    private let coordinateView: CoordinateView = {
        let coordinateView = CoordinateView()
        coordinateView.backgroundColor = .black
        return coordinateView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        configure()
        setBindings()
    }
}

// MARK: - View
private extension WritingScheduleViewController {
    func configureView() {
        view.backgroundColor = .black
        topBarView.barTitleLabel.text = "\(writingStyle.rawValue) \(TextConstants.schedule)"
        topBarView.saveBarButton.addTarget(self, action: #selector(touchUpSaveBarButton), for: .touchUpInside)
        topBarView.cancelBarButton.addTarget(self, action: #selector(touchUpCancelBarButton), for: .touchUpInside)
        navigationItem.titleView = topBarView.barTitleLabel
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: topBarView.cancelBarButton)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: topBarView.saveBarButton)
        
        configureViewValue()
        configureHierarchy()
        configureLayoutConstraint()
        configureCoordinateView()
    }
    
    func configureHierarchy() {
        [dateSwitch, fromLabel, fromDatePicker, toLabel, toDatePicker].forEach {
            dateBackgroundView.addSubview($0)
        }
        
        [titleTextField, descriptionTextView, dateBackgroundView, coordinateView].forEach {
            view.addSubview($0)
        }
    }
    
    func configureLayoutConstraint() {
        titleTextField.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
                .inset(AppLayoutConstants.largeSpacing)
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
        
        coordinateView.snp.makeConstraints {
            $0.top.equalTo(dateBackgroundView.snp.bottom)
                .offset(AppLayoutConstants.largeSpacing)
            $0.leading.trailing.equalToSuperview()
                .inset(AppLayoutConstants.spacing)
            $0.height.equalTo(LayoutConstants.coordinateViewHeight)
        }
    }
    
    func configure() {
        descriptionTextView.delegate = self
    }
    
    func configureViewValue() {
        titleTextField.text = viewModel.modelTitle
        descriptionTextView.text = viewModel.modelDescription
        coordinateView.latitudeTextField.text = String(viewModel.coordinate.latitude)
        coordinateView.longitudeTextField.text = String(viewModel.coordinate.longitude)
        
        if let fromDate = viewModel.modelFromDate, let toDate = viewModel.modelToDate {
            dateSwitch.isOn = true
            fromDatePicker.isEnabled = true
            toDatePicker.isEnabled = true
            fromDatePicker.date = fromDate
            toDatePicker.date = toDate
        }
    }
}

// MARK: - User Interaction
private extension WritingScheduleViewController {
    @objc func touchUpSaveBarButton() {
        if fromDatePicker.date > toDatePicker.date {
            alertWillAppear(AlertText.dateMessage)
            return
        }
        
        do {
            try viewModel.setSchedule()
        } catch {
            alertWillAppear(AlertText.titleMessage)
            return
        }
        
        save(viewModel.model, scheduleListIndex)
        navigationController?.popViewController(animated: true)
    }
    
    @objc func touchUpCancelBarButton() {
        viewModel.setPlan()
        if viewModel.planTracker.isChanged {
            let actionSheetText = fetchActionSheetText()
            actionSheetWillApear(actionSheetText.0, actionSheetText.1) { [weak self] in
                self?.navigationController?.popViewController(animated: true)
            }
        } else {
            navigationController?.popViewController(animated: true)
        }
    }
    
    func setBindings() {
        bindingText()
        bindingSwitch()
        bindingCoordinate()
        bindingDatePicker()
    }
    
    func bindingText() {
        let input = WritingScheduleViewModel.TextInput(title: titleTextField.textPublisher,
                                                       description: descriptionTextPublisher)
        viewModel.subscribeText(input)
    }
    
    func bindingSwitch() {
        let input = WritingScheduleViewModel.SwitchInput(statePublisher: dateSwitch.isOnPublisher)
        let output = viewModel.transform(input)
        
        output.datePickerStatePublisher
            .receive(on: RunLoop.main)
            .assign(to: \.isEnabled, on: fromDatePicker)
            .store(in: &subscriptions)
        
        output.backgroundColorPublisher
            .receive(on: RunLoop.main)
            .sink { [weak self] color in
                self?.fromDatePicker.backgroundColor = color
                self?.toDatePicker.backgroundColor = color
            }
            .store(in: &subscriptions)
    }
    
    func bindingCoordinate() {
        let input = WritingScheduleViewModel.CoordinateInput(latitude: coordinateView.latitudeTextField.textPublisher,
                                                             longitude: coordinateView.longitudeTextField.textPublisher)
        let output = viewModel.transform(input)
        
        output.buttonState
            .receive(on: RunLoop.main)
            .assign(to: \.isValid, on: coordinateView.mapButton)
            .store(in: &subscriptions)
    }
    
    func bindingDatePicker() {
        let input = WritingScheduleViewModel.DateInput(fromDatePublisher: fromDatePicker.datePublisher,
                                                       toDatePublisher: toDatePicker.datePublisher)
        viewModel.subscribeDate(input)
    }
    
    @objc func presentMap() {
        let annotatedCoordinate = [AnnotatedCoordinate(coordinate: viewModel.coordinate, title: titleTextField.text ?? "")]
        let mapView = MapViewController(annotatedCoordinate)
        navigationController?.pushViewController(mapView, animated: true)
    }
}

// MARK: - Coordinate
private extension WritingScheduleViewController {
    func configureCoordinateView() {
        coordinateView.mapButton.addTarget(self, action: #selector(presentMap), for: .touchUpInside)
    }
    
    enum ConvertCoordinateError: Error {
        case convertError
    }
}

extension WritingScheduleViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        descriptionTextPublisher.send(textView.text)
    }
}

private enum LayoutConstants {
    static let cornerRadius: CGFloat = 5
    static let mediumFontSize: CGFloat = 20
    static let descriptionTextViewHeight: CGFloat = 100
    static let dateBackgroundViewHeight: CGFloat = 170
    static let coordinateViewHeight: CGFloat = 150
}

private enum TextConstants {
    static let schedule = "Schedules"
    static let from = "From"
    static let to = "To"
}

private extension UIButton {
    var isValid: Bool {
        get {
            backgroundColor == .systemGreen
        }
        
        set {
            isEnabled = newValue
            backgroundColor = newValue ? .systemGreen : .systemGray
        }
    }
}
