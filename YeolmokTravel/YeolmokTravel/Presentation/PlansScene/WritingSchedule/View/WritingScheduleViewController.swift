//
//  WritingScheduleViewController.swift
//  YeolmokTravel
//
//  Created by 김동욱 on 2022/12/20.
//

import UIKit
import Combine
import CoreLocation
import NetworkPlatform

/// 여행 계획 추가 및 수정을 위한 ViewController
/// 위도와 경도를 텍스트필드에 입력하고 버튼을 눌러서 MKMapView로 확인할 수 있음.
final class WritingScheduleViewController: UIViewController, Writable {
    // MARK: - Properties
    private let viewModel: WritingScheduleViewModel
    let writingStyle: WritingStyle
    private weak var delegate: ScheduleTransferDelegate?
    private let schedulesListIndex: Int?
    
    private let ownView = WritingScheduleView()
    
    // MARK: - Init
    init(viewModel: WritingScheduleViewModel,
         writingStyle: WritingStyle,
         delegate: ScheduleTransferDelegate,
         schedulesListIndex: Int?) {
        self.viewModel = viewModel
        self.writingStyle = writingStyle
        self.delegate = delegate
        self.schedulesListIndex = schedulesListIndex
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        configureDelegate()
        configureAction()
        configureViewValue()
        configureGesture()
    }
}

// MARK: - Configure view
private extension WritingScheduleViewController {
    func configureView() {
        view.backgroundColor = .systemBackground
        configureNavigationItems()
        configureHierarchy()
        configureLayoutConstraint()
    }
    
    func configureHierarchy() {
        view.addSubview(ownView)
    }
    
    func configureLayoutConstraint() {
        ownView.snp.makeConstraints {
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
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: AppTextConstants.leftBarButtonTitle, style: .plain, target: self, action: #selector(touchUpCancelButton))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: AppTextConstants.rightBarButtonTitle, style: .done, target: self, action: #selector(touchUpSaveButton))
    }
    
    func configureViewValue() {
        ownView.titleTextField.tag = AppNumberConstants.scheduleTitleTextFieldTag
        ownView.titleTextField.text = viewModel.title.value
        ownView.descriptionTextView.text = viewModel.description.value
        ownView.latitudeTextField.text = String(viewModel.coordinate.value.latitude)
        ownView.longitudeTextField.text = String(viewModel.coordinate.value.longitude)
        
        if let fromDate = viewModel.fromDate.value, let toDate = viewModel.toDate.value {
            ownView.dateSwitch.isOn = true
            ownView.fromDatePicker.isValidAtBackgroundColor = true
            ownView.toDatePicker.isValidAtBackgroundColor = true
            ownView.fromDatePicker.date = fromDate
            ownView.toDatePicker.date = toDate
        }
    }
    
    func configureGesture() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapView))
        view.addGestureRecognizer(tapGestureRecognizer)
        
        let swipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(touchUpCancelButton))
        swipeGestureRecognizer.direction = .right
        view.addGestureRecognizer(swipeGestureRecognizer)
    }
    
    func configureDelegate() {
        ownView.titleTextField.delegate = self
        ownView.descriptionTextView.delegate = self
        ownView.coordinateSearchTextField.delegate = self
        ownView.latitudeTextField.delegate = self
        ownView.longitudeTextField.delegate = self
    }
    
    func configureAction() {
        ownView.titleTextField.addTarget(self, action: #selector(editingChangedTitleTextField), for: .editingChanged)
        ownView.dateSwitch.addTarget(self, action: #selector(toggledDateSwitch), for: .valueChanged)
        ownView.fromDatePicker.addTarget(self, action: #selector(valueChangedFromDatePicker), for: .valueChanged)
        ownView.toDatePicker.addTarget(self, action: #selector(valueChangedtoDatePicker), for: .valueChanged)
        ownView.latitudeTextField.addTarget(self, action: #selector(editingChangedCoordinateTextField), for: .editingChanged)
        ownView.longitudeTextField.addTarget(self, action: #selector(editingChangedCoordinateTextField), for: .editingChanged)
        ownView.mapButton.addTarget(self, action: #selector(touchUpMapButton), for: .touchUpInside)
    }
}

// MARK: - User Interaction
private extension WritingScheduleViewController {
    @objc func touchUpSaveButton() {
        do {
            try viewModel.validate(
                /*
                 좌푯값 입력이 유효하지 않아서 적용이 되지 않았다면,
                 가장 최근에 유효했던 값이 들어가 있기 때문에 데이터의 일관성을 보장받을 수 없으므로,
                 한 번 더 검사
                 */
                ownView.latitudeTextField.text ?? "",
                ownView.longitudeTextField.text ?? ""
            )
            
            switch writingStyle {
            case .create:
                delegate?.create(viewModel.getSchedule())
            case .update:
                guard let index = schedulesListIndex else { return }
                delegate?.update(at: index, viewModel.getSchedule())
            }
            
            navigationController?.popViewController(animated: true)
        } catch {
            guard let error = error as? ScheduleError else {
                alertWillAppear(AlertText.undefinedError)
                return
            }
            alertWillAppear(error.rawValue)
        }
    }
    
    @objc func touchUpCancelButton() {
        viewModel.didTouchUpCancelButton()
        if viewModel.isChanged {
            actionSheetWillAppear(isChangedText.0, isChangedText.1) { [weak self] in
                self?.navigationController?.popViewController(animated: true)
            }
        } else {
            navigationController?.popViewController(animated: true)
        }
    }
    
    @objc func touchUpMapButton() {
        let mapView = MapViewController([viewModel.coordinate.value])
        navigationController?.pushViewController(mapView, animated: true)
    }
    
    @objc func editingChangedTitleTextField() {
        viewModel.title.value = ownView.titleTextField.text ?? ""
    }
    
    @objc func editingChangedCoordinateTextField() {
        ownView.mapButton.isValidAtBackgroundColor = viewModel.editingChangedCoordinateTextField(
            ownView.latitudeTextField.text ?? "",
            ownView.longitudeTextField.text ?? ""
        )
    }
    
    @objc func toggledDateSwitch() {
        viewModel.toggledSwitch(ownView.dateSwitch.isOn,
                                ownView.fromDatePicker.date,
                                ownView.toDatePicker.date)
        ownView.fromDatePicker.isValidAtBackgroundColor = ownView.dateSwitch.isOn
        ownView.toDatePicker.isValidAtBackgroundColor = ownView.dateSwitch.isOn
    }
    
    @objc func valueChangedFromDatePicker() {
        viewModel.fromDate.value = ownView.fromDatePicker.date
    }
    
    @objc func valueChangedtoDatePicker() {
        viewModel.toDate.value = ownView.toDatePicker.date
    }
    
    @objc func tapView() {
        view.endEditing(true)
    }
}

// MARK: - UITextFieldDelegate
extension WritingScheduleViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == ownView.coordinateSearchTextField {
            // search
            if let text = textField.text, !text.isEmpty {
                Task { await performCoordinateSearch(with: text) }
                textField.text = ""
            }
        }
        
        textField.resignFirstResponder()
        return true
    }
    
    private func performCoordinateSearch(with query: String) async {
        Task {
            startIndicator()
            
            do {
                let coordinate = try await viewModel.perfomeCoordinateSearch(with: query)
                DispatchQueue.main.async { [self] in
                    ownView.latitudeTextField.text = coordinate.latitude
                    ownView.longitudeTextField.text = coordinate.longitude
                }
            } catch {
                if let error = error as? CoordinateRepositoryError {
                    alertWillAppear(error.rawValue)
                } else if let error = error as? CoordinateResponseError {
                    alertWillAppear(error.rawValue)
                } else {
                    alertWillAppear(AlertText.undefinedError)
                }
            }
            
            dismissIndicator()
        }
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
                    ownView.contentView.frame.origin.y = -LayoutConstants.yWhenKeyboardAppear
                }
            }
        }
    }
    
    private func keyboardWillDisappear() {
        if let screenHeight = view.window?.windowScene?.screen.bounds.height, screenHeight <= DisplayConstants.smallScreenHeight {
            DispatchQueue.main.async {
                UIView.animate(withDuration: AnimationConstants.duration) { [self] in
                    ownView.contentView.frame.origin.y = 0
                }
            }
        }
    }
}

// MARK:  - UITextViewDelegate
extension WritingScheduleViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        viewModel.description.value = textView.text
    }
}

// MARK: - Indicator
private extension WritingScheduleViewController {
    func startIndicator() {
        DispatchQueue.main.async { [self] in
            ownView.indicatorView.show(in: view)
        }
    }
    
    func dismissIndicator() {
        DispatchQueue.main.async { [self] in
            ownView.indicatorView.dismiss(animated: true)
        }
    }
}

// MARK: - Magic number/string
private extension WritingScheduleViewController {
    @frozen enum LayoutConstants {
        static let yWhenKeyboardAppear: CGFloat = 150
    }
    
    @frozen enum AnimationConstants {
        static let duration: TimeInterval = 0.3
    }
    
    @frozen enum TextConstants {
        static let schedule = "Schedule"
    }
    
    /*
     디스플레이 세로 길이
     iPhone SE(2nd, 3rd generation): 667
     iPhone 14 Pro Max: 932
     */
    @frozen enum DisplayConstants {
        static let smallScreenHeight: CGFloat = 667
    }
}

// MARK: - UIDatePicker private extension
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
