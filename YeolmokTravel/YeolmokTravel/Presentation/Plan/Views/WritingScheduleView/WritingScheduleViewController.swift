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
    private let viewModel: ConcreteWritingScheduleViewModel
    let writingStyle: WritingStyle
    private weak var delegate: ScheduleTransferDelegate?
    private let scheduleListIndex: Int?

    private let writingScheduleView = WritingScheduleView()
    
    init(viewModel: ConcreteWritingScheduleViewModel,
         writingStyle: WritingStyle,
         delegate: ScheduleTransferDelegate,
         scheduleListIndex: Int?) {
        self.viewModel = viewModel
        self.writingStyle = writingStyle
        self.delegate = delegate
        self.scheduleListIndex = scheduleListIndex
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        configureDelegate()
        configureAction()
        configureNavigationItems()
        configureViewValue()
        configureTapGesture()
    }
}

// MARK: - Configure View
private extension WritingScheduleViewController {
    func configureView() {
        view.backgroundColor = .systemBackground
        configureHierarchy()
        configureLayoutConstraint()
    }
    
    func configureHierarchy() {
        view.addSubview(writingScheduleView)
    }
    
    func configureLayoutConstraint() {
        writingScheduleView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
                .inset(AppLayoutConstants.spacing)
            $0.leading.equalTo(view.safeAreaLayoutGuide.snp.leading)
                .inset(AppLayoutConstants.spacing)
            $0.trailing.equalTo(view.safeAreaLayoutGuide.snp.trailing)
                .inset(AppLayoutConstants.spacing)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
                .inset(AppLayoutConstants.spacing)
        }
    }
    
    func configureNavigationItems() {
        navigationItem.title = "\(writingStyle.rawValue) \(TextConstants.schedule)"
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: AppTextConstants.leftBarButtonTitle, style: .plain, target: self, action: #selector(touchUpLeftBarButton))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: AppTextConstants.rightBarButtonTitle, style: .done, target: self, action: #selector(touchUpRightBarButton))
    }
    
    func configureViewValue() {
        writingScheduleView.titleTextField.tag = AppNumberConstants.scheduleTitleTextFieldTag
        writingScheduleView.titleTextField.text = viewModel.model.title
        writingScheduleView.descriptionTextView.text = viewModel.model.description
        writingScheduleView.latitudeTextField.text = String(viewModel.model.coordinate.latitude)
        writingScheduleView.longitudeTextField.text = String(viewModel.model.coordinate.longitude)
        
        if let fromDate = viewModel.model.fromDate, let toDate = viewModel.model.toDate {
            writingScheduleView.dateSwitch.isOn = true
            writingScheduleView.fromDatePicker.isValidAtBackgroundColor = true
            writingScheduleView.toDatePicker.isValidAtBackgroundColor = true
            writingScheduleView.fromDatePicker.date = fromDate
            writingScheduleView.toDatePicker.date = toDate
        }
    }
    
    func configureTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapView))
        view.addGestureRecognizer(tapGesture)
    }
    
    func configureDelegate() {
        writingScheduleView.titleTextField.delegate = self
        writingScheduleView.descriptionTextView.delegate = self
        writingScheduleView.latitudeTextField.delegate = self
        writingScheduleView.longitudeTextField.delegate = self
        
    }
    func configureAction() {
        writingScheduleView.titleTextField.addTarget(self, action: #selector(editingChangedTitleTextField), for: .editingChanged)
        writingScheduleView.latitudeTextField.addTarget(self, action: #selector(editingChangedCoordinateTextField), for: .editingChanged)
        writingScheduleView.longitudeTextField.addTarget(self, action: #selector(editingChangedCoordinateTextField), for: .editingChanged)
        writingScheduleView.mapButton.addTarget(self, action: #selector(touchUpMapButton), for: .touchUpInside)
        writingScheduleView.dateSwitch.addTarget(self, action: #selector(toggledDateSwitch), for: .valueChanged)
        writingScheduleView.fromDatePicker.addTarget(self, action: #selector(valueChangedFromDatePicker), for: .valueChanged)
        writingScheduleView.toDatePicker.addTarget(self, action: #selector(valueChangedtoDatePicker), for: .valueChanged)
    }
}

// MARK: - User Interaction
private extension WritingScheduleViewController {
    @objc func touchUpRightBarButton() {
        do {
            try viewModel.isValidSave(
                /*
                 좌푯값 입력이 유효하지 않아서 적용이 되지 않았다면,
                 가장 최근에 유효했던 값이 들어가 있기 때문에 데이터의 일관성을 보장받을 수 없으므로,
                 한 번 더 검사
                 */
                writingScheduleView.latitudeTextField.text ?? "",
                writingScheduleView.longitudeTextField.text ?? ""
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
        viewModel.editingChangedTitleTextField(writingScheduleView.titleTextField.text ?? "")
    }
    
    @objc func editingChangedCoordinateTextField() {
        writingScheduleView.mapButton.isValidAtBackgroundColor = viewModel.editingChangedCoordinateTextField(
            writingScheduleView.latitudeTextField.text ?? "",
            writingScheduleView.longitudeTextField.text ?? ""
        )
    }
    
    @objc func toggledDateSwitch() {
        viewModel.toggledSwitch(writingScheduleView.dateSwitch.isOn,
                                writingScheduleView.fromDatePicker.date,
                                writingScheduleView.toDatePicker.date)
        writingScheduleView.fromDatePicker.isValidAtBackgroundColor = writingScheduleView.dateSwitch.isOn
        writingScheduleView.toDatePicker.isValidAtBackgroundColor = writingScheduleView.dateSwitch.isOn
    }
    
    @objc func valueChangedFromDatePicker() {
        viewModel.valueChangedFromDatePicker(writingScheduleView.fromDatePicker.date)
    }
    
    @objc func valueChangedtoDatePicker() {
        viewModel.valueChangedToDatePicker(writingScheduleView.toDatePicker.date)
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
        if textField.tag != AppNumberConstants.scheduleTitleTextFieldTag {
            keyboardWillAppear()
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.tag != AppNumberConstants.scheduleTitleTextFieldTag {
            keyboardWillDisappear()
        }
    }
    
    // 스크린의 높이가 클 때는 조작할 필요 없음.
    private func keyboardWillAppear() {
        if let screenHeight = view.window?.windowScene?.screen.bounds.height, screenHeight <= DisplayConstants.smallScreenHeight {
            DispatchQueue.main.async {
                UIView.animate(withDuration: AnimationConstants.duration) { [self] in
                    writingScheduleView.contentView.frame.origin.y = -LayoutConstants.yWhenKeyboardAppear
                }
            }
        }
    }
    
    private func keyboardWillDisappear() {
        if let screenHeight = view.window?.windowScene?.screen.bounds.height, screenHeight <= DisplayConstants.smallScreenHeight {
            DispatchQueue.main.async {
                UIView.animate(withDuration: AnimationConstants.duration) { [self] in
                    writingScheduleView.contentView.frame.origin.y = 0
                }
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

private enum TextConstants {
    static let schedule = "Schedule"
}

private enum LayoutConstants {
    static let yWhenKeyboardAppear: CGFloat = 150
}

private enum AnimationConstants {
    static let duration: TimeInterval = 0.3
}

/*
 디스플레이 세로 길이
 iPhone SE(2nd, 3rd generation): 667
 iPhone 14 Pro Max: 932
 */
private enum DisplayConstants {
    static let smallScreenHeight: CGFloat = 667
}
