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
    weak var delegate: ScheduleTransferDelegate?
    var scheduleListIndex: Int?
    private let viewModel: ConcreteWritingScheduleViewModel
    
    private let titleTextField: UITextField = {
        let textField = UITextField()
        textField.textColor = .white
        textField.backgroundColor = .systemBackground
        textField.layer.cornerRadius = LayoutConstants.cornerRadius
        textField.layer.borderWidth = AppLayoutConstants.borderWidth
        textField.layer.borderColor = UIColor.white.cgColor
        textField.font = .boldSystemFont(ofSize: AppLayoutConstants.largeFontSize)
        textField.placeholder = AppTextConstants.titlePlaceholder
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none
        textField.returnKeyType = .done
        textField.leftView = UIView(frame: CGRect(x: .zero,
                                                  y: .zero,
                                                  width: AppLayoutConstants.spacing,
                                                  height: .zero))
        textField.leftViewMode = .always
        textField.tag = AppNumberConstants.titleTextFieldTag
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
        textView.autocorrectionType = .no
        textView.autocapitalizationType = .none
        return textView
    }()
    
    private let dateBackgroundView: UIView = {
        let view = UIView()
        view.layer.borderWidth = AppLayoutConstants.borderWidth
        view.layer.borderColor = UIColor.white.cgColor
        view.backgroundColor = .darkGray
        return view
    }()
    
    private let dateSwitch: UISwitch = {
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
    
    init(_ viewModel: ConcreteWritingScheduleViewModel, writingStyle: WritingStyle) {
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
    }
}

// MARK: - Configure View
private extension WritingScheduleViewController {
    func configureView() {
        view.backgroundColor = .systemBackground
        configureNavigationItems()
        configureHierarchy()
        configureLayoutConstraint()
        configureViewValue()
        configureTapGesture()
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
    
    func configureTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapView))
        view.addGestureRecognizer(tapGesture)
    }
}

// MARK: - User Interaction
private extension WritingScheduleViewController {
    func configure() {
        titleTextField.addTarget(self, action: #selector(editingChangedTitleTextField), for: .editingChanged)
        titleTextField.delegate = self
        descriptionTextView.delegate = self
        coordinateView.latitudeTextField.addTarget(self, action: #selector(editingChangedCoordinateTextField), for: .editingChanged)
        coordinateView.latitudeTextField.delegate = self
        coordinateView.longitudeTextField.addTarget(self, action: #selector(editingChangedCoordinateTextField), for: .editingChanged)
        coordinateView.longitudeTextField.delegate = self
        coordinateView.mapButton.addTarget(self, action: #selector(touchUpMapButton), for: .touchUpInside)
        dateSwitch.addTarget(self, action: #selector(toggledDateSwitch), for: .valueChanged)
        fromDatePicker.addTarget(self, action: #selector(valueChangedFromDatePicker), for: .valueChanged)
        toDatePicker.addTarget(self, action: #selector(valueChangedtoDatePicker), for: .valueChanged)
    }
    
    @objc func touchUpRightBarButton() {
        do {
            try viewModel.isValidSave(
                /*
                 좌푯값 입력이 유효하지 않아서 적용이 되지 않았다면,
                 가장 최근에 유효했던 값이 들어가 있기 때문에 데이터의 일관성을 보장받을 수 없으므로,
                 한 번 더 검사
                 */
                coordinateView.latitudeTextField.text ?? "",
                coordinateView.longitudeTextField.text ?? ""
            )
            save(viewModel.model, scheduleListIndex)
            navigationController?.popViewController(animated: true)
        } catch {
            guard let error = error as? ScheduleError else {
                alertWillAppear(AlertText.undefinedError)
                return
            }
            alertWillAppear(error.rawValue)
        }
    }
    
    @objc func touchUpLeftBarButton() {
        viewModel.setScheduleTracker()
        if viewModel.scheduleTracker.isChanged {
            let actionSheetText = fetchActionSheetText()
            actionSheetWillAppear(actionSheetText.0, actionSheetText.1) { [weak self] in
                self?.navigationController?.popViewController(animated: true)
            }
        } else {
            navigationController?.popViewController(animated: true)
        }
    }
    
    @objc func touchUpMapButton() {
        let mapView = MapViewController([viewModel.model.coordinate])
        navigationController?.pushViewController(mapView, animated: true)
    }
    
    func save(_ schedule: YTSchedule, _ index: Int?) {
        switch writingStyle {
        case .create:
            delegate?.create(schedule)
        case .update:
            guard let index = index else { return }
            delegate?.update(at: index, schedule)
        }
    }
    
    @objc func editingChangedTitleTextField() {
        viewModel.editingChangedTitleTextField(titleTextField.text ?? "")
    }
    
    @objc func editingChangedCoordinateTextField() {
        coordinateView.mapButton.isValidAtBackgroundColor = viewModel.editingChangedCoordinateTextField(
            coordinateView.latitudeTextField.text ?? "",
            coordinateView.longitudeTextField.text ?? ""
        )
    }
    
    @objc func toggledDateSwitch() {
        viewModel.toggledSwitch(dateSwitch.isOn, fromDatePicker.date, toDatePicker.date)
        fromDatePicker.isValidAtBackgroundColor = dateSwitch.isOn
        toDatePicker.isValidAtBackgroundColor = dateSwitch.isOn
    }
    
    @objc func valueChangedFromDatePicker() {
        viewModel.valueChangedFromDatePicker(fromDatePicker.date)
    }
    
    @objc func valueChangedtoDatePicker() {
        viewModel.valueChangedToDatePicker(toDatePicker.date)
    }
    
    @objc func tapView() {
        view.endEditing(true)
    }
}

extension WritingScheduleViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // 키보드가 나타날 때, view를 위로 이동시킴.
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField.tag != AppNumberConstants.titleTextFieldTag {
            keyboardWillAppear()
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.tag != AppNumberConstants.titleTextFieldTag {
            keyboardWillDisappear()
        }
    }
    
    private func keyboardWillAppear() {
        DispatchQueue.main.async {
            UIView.animate(withDuration: AnimationConstants.duration) { [self] in
                view.frame.origin.y = -LayoutConstants.yWhenKeyboardAppear
            }
        }
    }
    
    private func keyboardWillDisappear() {
        DispatchQueue.main.async {
            UIView.animate(withDuration: AnimationConstants.duration) { [self] in
                view.frame.origin.y = 0
            }
        }
    }
}

extension WritingScheduleViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        viewModel.didChangeDescriptionTextView(textView.text)
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
    static let yWhenKeyboardAppear: CGFloat = 150
}

private enum TextConstants {
    static let schedule = "Schedule"
    static let from = "From"
    static let to = "To"
}

private enum AnimationConstants {
    static let duration: TimeInterval = 0.3
}
