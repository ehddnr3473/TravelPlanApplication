//
//  WritingPlanViewController.swift
//  YeolmokTravel
//
//  Created by 김동욱 on 2022/12/20.
//

import UIKit
import Combine
import CoreLocation
import Domain

protocol ScheduleTransferDelegate: AnyObject {
    func create(_ schedule: Schedule)
    func update(at index: Int, _ schedule: Schedule)
}

/*
 - 여행 계획(Plan)의 자세한 일정(Schedule) 추가 및 수정을 위한 ViewController
 - Schedules의 coordinate(좌표 - 위도(latitude) 및 경도(longitude)) 정보를 취합해서 MKMapView로 표현
 */
final class WritingPlanViewController: UIViewController, Writable {
    // MARK: - Properties
    private let viewModel: WritingPlanViewModel
    private weak var coordinator: PlansWriteFlowCoordinator?
    private let mapProvider: Mappable
    let writingStyle: WritingStyle
    private weak var delegate: PlanTransferDelegate?
    private let plansListIndex: Int?
    private var subscriptions = Set<AnyCancellable>()
    
    private lazy var ownView = WritingPlanView(
        frame: .zero,
        scrollViewContainerHeight: viewModel.calculatedContentViewHeight
    )
    
    private let scheduleTableView: UITableView = {
        let tableView = UITableView()
        tableView.register(PlanCell.self,
                           forCellReuseIdentifier: PlanCell.identifier)
        tableView.backgroundColor = .systemBackground
        tableView.layer.cornerRadius = LayoutConstants.tableViewCornerRadius
        tableView.layer.borderWidth = AppLayoutConstants.borderWidth
        tableView.layer.borderColor = UIColor.white.cgColor
        tableView.isScrollEnabled = false
        return tableView
    }()
    
    private lazy var mapTitleLabel: UILabel = {
        let label = UILabel()
        label.text = TextConstants.map
        label.textAlignment = .center
        label.textColor = .white
        label.font = .boldSystemFont(ofSize: AppLayoutConstants.largeFontSize)
        return label
    }()
    
    private let mapButtonSetView = MapButtonSetView()
    
    // MARK: - Init
    init(viewModel: WritingPlanViewModel,
         coordinator: PlansWriteFlowCoordinator,
         mapProvider: Mappable,
         writingStyle: WritingStyle,
         delegate: PlanTransferDelegate,
         plansListIndex: Int?) {
        self.viewModel = viewModel
        self.coordinator = coordinator
        self.mapProvider = mapProvider
        self.writingStyle = writingStyle
        self.delegate = delegate
        self.plansListIndex = plansListIndex
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        embedMapView()
        configureDelegate()
        configureAction()
        configureTapGesture()
        configureViewValue()
        bind()
    }
}

// MARK: - Configure view
private extension WritingPlanViewController {
    func configureView() {
        view.backgroundColor = .systemBackground
        configureNavigationItems()
        configureHierarchy()
        configureLayoutConstraint()
    }
    
    func configureHierarchy() {
        view.addSubview(ownView)
        ownView.contentView.addSubview(scheduleTableView)
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
        
        scheduleTableView.snp.makeConstraints {
            $0.top.equalTo(ownView.createScheduleButton.snp.bottom)
                .offset(AppLayoutConstants.spacing)
            $0.leading.trailing.equalToSuperview()
                .inset(AppLayoutConstants.spacing)
            $0.height.equalTo(viewModel.schedules.value.count * Int(AppLayoutConstants.cellHeight))
        }
    }
    
    func configureNavigationItems() {
        navigationItem.title = "\(writingStyle.rawValue) \(TextConstants.plan)"
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: AppTextConstants.leftBarButtonTitle, style: .plain, target: self, action: #selector(touchUpCancelButton))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: AppTextConstants.rightBarButtonTitle, style: .done, target: self, action: #selector(touchUpSaveButton))
    }
    
    func configureDelegate() {
        scheduleTableView.delegate = self
        scheduleTableView.dataSource = self
        ownView.titleTextField.delegate = self
        ownView.descriptionTextView.delegate = self
    }
    
    func configureAction() {
        ownView.titleTextField.addTarget(self, action: #selector(editingChangedTitleTextField), for: .editingChanged)
        ownView.editScheduleButton.addTarget(self, action: #selector(touchUpEditButton), for: .touchUpInside)
        ownView.createScheduleButton.addTarget(self, action: #selector(touchUpCreateButton), for: .touchUpInside)
    }
    
    func configureTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapView))
        tapGesture.delegate = self
        view.addGestureRecognizer(tapGesture)
    }
    
    func configureViewValue() {
        ownView.titleTextField.text = viewModel.title.value
        ownView.descriptionTextView.text = viewModel.description.value
    }
}

// MARK: - User Interaction
private extension WritingPlanViewController {
    @objc func touchUpSaveButton() {
        viewModel.didTouchUpAnyButton()
        do {
            // 변경 사항이 있다면 저장
            if viewModel.isChanged {
                let plan = try viewModel.validateAndGetPlan()
                
                switch writingStyle {
                case .create:
                    Task { try await delegate?.create(plan) }
                case .update:
                    guard let index = plansListIndex else { return }
                    Task { try await delegate?.update(at: index, plan) }
                }
            }
            navigationController?.popViewController(animated: true)
        } catch {
            guard let error = error as? WritingPlanError else { return }
            alertWillAppear(error.rawValue)
        }
    }
    
    @objc func touchUpCancelButton() {
        viewModel.didTouchUpAnyButton()
        if viewModel.isChanged {
            actionSheetWillAppear(isChangedText.0, isChangedText.1) { [weak self] in
                self?.navigationController?.popViewController(animated: true)
            }
        } else {
            navigationController?.popViewController(animated: true)
        }
    }
    
    @objc func touchUpCreateButton() {
        coordinator?.toWriteSchedule(
            .init(
                schedule: Schedule(
                    title: "",
                    description: "",
                    coordinate: CLLocationCoordinate2D(),
                    fromDate: nil,
                    toDate: nil
                ),
                writingStyle: .create,
                delegate: self,
                schedulesListIndex: nil)
        )
    }
    
    private func didSelectRow(_ index: Int) {
        coordinator?.toWriteSchedule(
            .init(
                schedule: viewModel.schedules.value[index],
                writingStyle: .update,
                delegate: self,
                schedulesListIndex: index)
        )
    }
    
    // 이전 좌표로 카메라 이동
    @objc func touchUpPreviousButton() {
        mapProvider.animateCameraToPreviousPoint()
    }
    
    // 중심으로 카메라 이동
    @objc func touchUpCenterButton() {
        mapProvider.animateCameraToCenterPoint()
    }
    
    // 다음 좌표로 카메라 이동
    @objc func touchUpNextButton() {
        mapProvider.animateCameraToNextPoint()
    }
    
    @objc func touchUpEditButton() {
        UIView.animate(withDuration: 0.2, delay: 0, animations: { [self] in
            scheduleTableView.isEditing.toggle()
        }, completion: { [self] _ in
            ownView.editScheduleButton.isEditingAtTintColor = scheduleTableView.isEditing
        })
    }
    
    @objc func editingChangedTitleTextField() {
        viewModel.title.send(ownView.titleTextField.text ?? "")
    }
    
    @objc func tapView() {
        view.endEditing(true)
    }
}

// MARK: - Binding
private extension WritingPlanViewController {
    func bind() {
        viewModel.schedules
            .receive(on: DispatchQueue.main)
            .sink { [self] schedules in
                reload()
                schedulesDidChaged(schedules)
            }
            .store(in: &subscriptions)
    }
    
    func schedulesDidChaged(_ schedules: [Schedule]) {
        let coordinates = extractCoordinatesOfSchedules(schedules)
        
        if coordinates.count == .zero {
            removeMapContentsView()
            updateContentViewHeight()
        } else {
            updateMapView(coordinates)
        }
    }
    
    func extractCoordinatesOfSchedules(_ schedules: [Schedule]) -> [CLLocationCoordinate2D] {
        var coordinates = [CLLocationCoordinate2D]()
        
        for schedule in schedules {
            coordinates.append(schedule.coordinate)
        }
        
        return coordinates
    }
}

// MARK: - MapView
private extension WritingPlanViewController {
    func embedMapView() {
        mapProvider.configureMapView()
        addChild(mapProvider as! UIViewController)
        (mapProvider as! UIViewController).didMove(toParent: self)
        /*
         좌표 값이 없다면(새로운 TavelPlan 추가를 위한 초기 상태인 경우 or Schedule 추가를 안한 경우)
         불필요한 뷰 추가 없이, 임베드만 하고 종료
         */
        guard viewModel.schedules.value.count != .zero else { return }
        addMapContentsViews()
    }
    
    func addMapContentsViews() {
        addMapTitleLabel()
        addMapView()
        addMapButtonSet()
    }
    
    @MainActor func removeMapContentsView() {
        removeMapView()
        removeMapTitleLabel()
        removeMapButtonSet()
    }
    
    @MainActor func addMapTitleLabel() {
        ownView.contentView.addSubview(mapTitleLabel)
        mapTitleLabel.snp.makeConstraints {
            $0.top.equalTo(scheduleTableView.snp.bottom)
                .offset(AppLayoutConstants.largeSpacing)
            $0.leading.equalToSuperview()
                .inset(AppLayoutConstants.spacing)
        }
    }
    
    @MainActor func addMapView() {
        ownView.contentView.addSubview(mapProvider.mapView)
        mapProvider.mapView.snp.makeConstraints {
            $0.top.equalTo(mapTitleLabel.snp.bottom)
                .offset(AppLayoutConstants.spacing)
            $0.leading.trailing.equalToSuperview()
                .inset(AppLayoutConstants.spacing)
            $0.height.equalTo(AppLayoutConstants.mapViewHeight)
        }
    }
    
    @MainActor func addMapButtonSet() {
        mapButtonSetView.previousButton.addTarget(self, action: #selector(touchUpPreviousButton), for: .touchUpInside)
        mapButtonSetView.centerButton.addTarget(self, action: #selector(touchUpCenterButton), for: .touchUpInside)
        mapButtonSetView.nextButton.addTarget(self, action: #selector(touchUpNextButton), for: .touchUpInside)
        
        ownView.contentView.addSubview(mapButtonSetView)
        mapButtonSetView.snp.makeConstraints {
            $0.top.equalTo(mapProvider.mapView.snp.bottom)
                .offset(AppLayoutConstants.spacing)
            $0.leading.trailing.equalToSuperview()
                .inset(AppLayoutConstants.spacing)
            $0.height.equalTo(AppLayoutConstants.buttonHeight)
        }
    }
    
    func removeMapView() {
        mapProvider.mapView.snp.removeConstraints()
        mapProvider.mapView.removeFromSuperview()
    }
    
    func removeMapTitleLabel() {
        mapTitleLabel.snp.removeConstraints()
        mapTitleLabel.removeFromSuperview()
    }
    
    func removeMapButtonSet() {
        mapButtonSetView.previousButton.removeTarget(self, action: #selector(touchUpPreviousButton), for: .touchUpInside)
        mapButtonSetView.centerButton.removeTarget(self, action: #selector(touchUpCenterButton), for: .touchUpInside)
        mapButtonSetView.nextButton.removeTarget(self, action: #selector(touchUpNextButton), for: .touchUpInside)
        mapButtonSetView.snp.removeConstraints()
        mapButtonSetView.removeFromSuperview()
    }
    
    // Map 관련 뷰가 subview에 있는지(+ 레이아웃 제약이 설정되어 있는지) 확인하는 메서드
    func mapContentsIsAdded() -> Bool {
        ownView.contentView.subviews.contains {
            $0.tag == AppNumberConstants.mapViewTag
        }
    }
    
    func updateMapView(_ coordinates: [CLLocationCoordinate2D]) {
        // Map 관련 뷰가 없다면, ScrollView 높이를 갱신하고, Map 관련 뷰 추가
        if !mapContentsIsAdded() {
            updateContentViewHeight()
            addMapContentsViews()
        }
        mapProvider.updateMapView(coordinates)
    }
    
    @MainActor func reload() {
        updateContentViewHeight()
        updateTableViewConstraints()
        scheduleTableView.reloadData()
    }
    
    @MainActor func updateContentViewHeight() {
        ownView.contentView.snp.updateConstraints {
            $0.height.equalTo(viewModel.calculatedContentViewHeight)
        }
    }
    
    @MainActor func updateTableViewConstraints() {
        scheduleTableView.snp.updateConstraints {
            $0.height.equalTo(viewModel.schedules.value.count * Int(AppLayoutConstants.cellHeight))
        }
    }
}

// MARK: - Schedule TableView
extension WritingPlanViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: PlanCell.identifier, for: indexPath) as? PlanCell else { return UITableViewCell() }
        cell.titleLabel.text = viewModel.schedules.value[indexPath.row].title
        cell.descriptionLabel.text = viewModel.schedules.value[indexPath.row].description
        cell.dateLabel.text = viewModel.getDateString(at: indexPath.row)
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.schedules.value.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        AppLayoutConstants.cellHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        didSelectRow(indexPath.row)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            viewModel.deleteSchedule(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            updateTableViewConstraints()
        }
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        .delete
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        viewModel.swapSchedules(at: sourceIndexPath.row, to: destinationIndexPath.row)
    }
}

// MARK: - ScheduleTransferDelegate
extension WritingPlanViewController: ScheduleTransferDelegate {
    func create(_ schedule: Schedule) {
        viewModel.didEndCreating(schedule)
    }
    
    func update(at index: Int, _ schedule: Schedule) {
        viewModel.didEndUpdating(at: index, schedule)
    }
}

// MARK: - UITextFieldDelegate
extension WritingPlanViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

// MARK: - UITextViewDelegate
extension WritingPlanViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        viewModel.description.send(textView.text)
    }
}

// MARK: - UIGestureRecognizerDelegate
extension WritingPlanViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if let view = touch.view, view.isDescendant(of: scheduleTableView) {
            return false
        }
        return true
    }
}

// MARK: - Magic number/string
private extension WritingPlanViewController {
    @frozen enum LayoutConstants {
        static let tableViewCornerRadius: CGFloat = 10
    }
    
    @frozen enum TextConstants {
        static let plan = "Plan"
        static let map = "Map"
    }
}
