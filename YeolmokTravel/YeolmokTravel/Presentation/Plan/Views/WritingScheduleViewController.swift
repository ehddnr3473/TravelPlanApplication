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
/// 위도와 경도를 텍스트필드에 입력하고 버튼을 눌러서 MKMapView로 확인할 수 있음.
final class WritingScheduleViewController: UIViewController, Writable {
    // MARK: - Properties
    var writingStyle: WritingStyle
    var delegate: ScheduleTransferDelegate?
    var scheduleListIndex: Int?
    private let viewModel: WritingScheduleViewModel
    
    private let descriptionTextPublisher = PassthroughSubject<String, Never>()
    private var subscriptions = Set<AnyCancellable>()
    
    private let titleTextField: UITextField = {
        let textField = UITextField()
        textField.textColor = .white
        textField.backgroundColor = .systemBackground
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
        textView.backgroundColor = .systemBackground
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
    
    private let toDatePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.preferredDatePickerStyle = .compact
        datePicker.datePickerMode = .date
        datePicker.tintColor = AppStyles.mainColor
        datePicker.backgroundColor = .systemGray
        datePicker.isEnabled = false
        return datePicker
    }()
    
    private let coordinateView: CoordinateView = {
        let coordinateView = CoordinateView()
        coordinateView.backgroundColor = .systemBackground
        return coordinateView
    }()
    
    init(_ viewModel: WritingScheduleViewModel, writingStyle: WritingStyle) {
        self.viewModel = viewModel
        self.writingStyle = writingStyle
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        configure()
        setBindings()
    }
}

// MARK: - Configure View
private extension WritingScheduleViewController {
    func configureView() {
        view.backgroundColor = .systemBackground
        configureNavigationItems()
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
    
    func configureNavigationItems() {
        navigationItem.title = "\(writingStyle.rawValue) \(TextConstants.schedule)"
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: AppTextConstants.leftBarButtonTitle, style: .plain, target: self, action: #selector(touchUpLeftBarButton))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: AppTextConstants.rightBarButtonTitle, style: .done, target: self, action: #selector(touchUpRightBarButton))
    }
    
    func configure() {
        descriptionTextView.delegate = self
    }
    
    func configureViewValue() {
        titleTextField.text = viewModel.model.title
        descriptionTextView.text = viewModel.model.description
        coordinateView.latitudeTextField.text = String(viewModel.model.coordinate.latitude)
        coordinateView.longitudeTextField.text = String(viewModel.model.coordinate.longitude)
        
        if let fromDate = viewModel.model.fromDate, let toDate = viewModel.model.toDate {
            dateSwitch.isOn = true
            fromDatePicker.isValidAtBackgroundColor = true
            toDatePicker.isValidAtBackgroundColor = true
            fromDatePicker.date = fromDate
            toDatePicker.date = toDate
        }
    }
}

// MARK: - User Interaction
private extension WritingScheduleViewController {
    @objc func touchUpRightBarButton() {
        if isSaveEnabled() {
            save(viewModel.model, scheduleListIndex)
            navigationController?.popViewController(animated: true)
        }
    }
    
    @objc func touchUpLeftBarButton() {
        viewModel.setPlan()
        if viewModel.scheduleTracker.isChanged {
            let actionSheetText = fetchActionSheetText()
            actionSheetWillApear(actionSheetText.0, actionSheetText.1) { [weak self] in
                self?.navigationController?.popViewController(animated: true)
            }
        } else {
            navigationController?.popViewController(animated: true)
        }
    }
    
    @objc func presentMap() {
        let coordinates = [viewModel.coordinate]
        let mapView = MapViewController(coordinates)
        navigationController?.pushViewController(mapView, animated: true)
    }
    
    func isSaveEnabled() -> Bool {
        do {
            try viewModel.setSchedule()
            return true
        } catch {
            guard let error = error as? ScheduleError else {
                alertWillAppear(AlertText.undefinedError)
                return false
            }
            
            switch error {
            case .titleError:
                alertWillAppear(AlertText.titleMessage)
            case .preToDateError:
                alertWillAppear(AlertText.dateMessage)
            case .fromDateError:
                alertWillAppear(AlertText.fromDateErrorMessage)
            case .toDateError:
                alertWillAppear(AlertText.toDateErrorMessage)
            case .coordinateError:
                alertWillAppear(AlertText.coordinateErrorMessage)
            }
            return false
        }
    }
    
    func save(_ schedule: Schedule, _ index: Int?) {
        switch writingStyle {
        case .create:
            delegate?.create(schedule)
        case .update:
            guard let index = index else { return }
            delegate?.update(at: index, schedule)
        }
    }
}

// MARK: - Binding
private extension WritingScheduleViewController {
    func setBindings() {
        bindingText()
        bindingSwitch()
        bindingCoordinate()
        bindingDatePicker()
    }
    
    func bindingText() {
        let input = WritingScheduleViewModel.TextInput(titlePublisher: titleTextField.textPublisher,
                                                       descriptionPublisher: descriptionTextPublisher)
        viewModel.subscribeText(input)
    }
    
    func bindingSwitch() {
        let input = WritingScheduleViewModel.SwitchInput(switchIsOnPublisher: dateSwitch.isOnPublisher,
                                                         initialFromDate: fromDatePicker.date,
                                                         initialToDate: toDatePicker.date)
        let output = viewModel.transform(input)
        
        output.datePickerStatePublisher
            .receive(on: RunLoop.main)
            .sink { [weak self] state in
                self?.fromDatePicker.isValidAtBackgroundColor = state
                self?.toDatePicker.isValidAtBackgroundColor = state
            }
            .store(in: &subscriptions)
    }
    
    func bindingCoordinate() {
        let input = WritingScheduleViewModel.CoordinateInput(latitudePublisher: coordinateView.latitudeTextField.textPublisher,
                                                             longitudePublisher: coordinateView.longitudeTextField.textPublisher)
        let output = viewModel.transform(input)
        
        output.buttonStatePublisher
            .receive(on: RunLoop.main)
            .assign(to: \.isValidAtBackgroundColor, on: coordinateView.mapButton)
            .store(in: &subscriptions)
    }
    
    func bindingDatePicker() {
        let input = WritingScheduleViewModel.DateInput(fromDatePublisher: fromDatePicker.datePublisher,
                                                       toDatePublisher: toDatePicker.datePublisher)
        viewModel.subscribeDate(input)
    }
}

// MARK: - Coordinate
private extension WritingScheduleViewController {
    func configureCoordinateView() {
        coordinateView.mapButton.addTarget(self, action: #selector(presentMap), for: .touchUpInside)
    }
}

extension WritingScheduleViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        descriptionTextPublisher.send(textView.text)
    }
}

private extension UIDatePicker {
    var isValidAtBackgroundColor: Bool {
        get {
            backgroundColor == .white
        }
        
        set {
            backgroundColor = newValue ? .white : .systemGray
            isEnabled = newValue
        }
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
    static let schedule = "Schedule"
    static let from = "From"
    static let to = "To"
}
