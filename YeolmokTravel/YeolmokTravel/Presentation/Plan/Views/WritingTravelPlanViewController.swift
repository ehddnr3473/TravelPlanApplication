//
//  WritingPlanViewController.swift
//  YeolmokTravel
//
//  Created by 김동욱 on 2022/12/20.
//

import UIKit
import Combine
import CoreLocation

protocol ScheduleTransferDelegate: AnyObject {
    func create(_ schedule: YTSchedule)
    func update(at index: Int, _ schedule: YTSchedule)
}

/*
 - 여행 계획의 자세한 일정 추가 및 수정을 위한 ViewController
 - Schedules의 coordinate(좌표 - 위도(latitude) 및 경도(longitude)) 정보를 취합해서 MKMapView로 표현
 */
final class WritingTravelPlanViewController: UIViewController, Writable {
    typealias WritableModelType = YTTravelPlan
    // MARK: - Properties
    var writingStyle: WritingStyle
    weak var delegate: TravelPlanTransferDelegate?
    var planListIndex: Int?
    private let viewModel: ConcreteWritingTravelPlanViewModel
    private let mapProvider: Mappable
    
    private var subscriptions = Set<AnyCancellable>()
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.isScrollEnabled = true
        return scrollView
    }()
    
    private let scrollViewContainer = UIView()
    
    private let topView: WritingTravelPlanTopView = {
        let writingTravelPlanView = WritingTravelPlanTopView()
        writingTravelPlanView.backgroundColor = .systemBackground
        return writingTravelPlanView
    }()
    
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
    
    private let mapButtonSetView: MapButtonSetView = {
        let mapButtonSetView = MapButtonSetView()
        return mapButtonSetView
    }()
    
    init(viewModel: ConcreteWritingTravelPlanViewModel, mapProvider: Mappable, writingStyle: WritingStyle, delegate: TravelPlanTransferDelegate) {
        self.viewModel = viewModel
        self.mapProvider = mapProvider
        self.writingStyle = writingStyle
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        embedMapView()
        configure()
        configureTopViewValue()
        bindingSchedules()
    }
}

// MARK: - Configure View
private extension WritingTravelPlanViewController {
    func configureView() {
        view.backgroundColor = .systemBackground
        configureNavigationItems()
        configureHierarchy()
        configureLayoutConstraint()
        configureTapGesture()
    }
    
    func configureHierarchy() {
        [topView, scheduleTableView].forEach {
            scrollViewContainer.addSubview($0)
        }
        
        scrollView.addSubview(scrollViewContainer)
        
        [scrollView].forEach {
            view.addSubview($0)
        }
    }
    
    func configureLayoutConstraint() {
        scrollView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
                .inset(AppLayoutConstants.spacing)
            $0.leading.bottom.trailing.equalToSuperview()
                .inset(AppLayoutConstants.spacing)
        }
        
        scrollViewContainer.snp.makeConstraints {
            $0.top.equalTo(scrollView.contentLayoutGuide.snp.top)
            $0.leading.equalTo(scrollView.contentLayoutGuide.snp.leading)
            $0.bottom.equalTo(scrollView.contentLayoutGuide.snp.bottom)
            $0.trailing.equalTo(scrollView.contentLayoutGuide.snp.trailing)
            
            $0.width.equalTo(scrollView.frameLayoutGuide.snp.width)
            $0.height.equalTo(viewModel.calculatedScrollViewContainerHeight)
        }
        
        topView.snp.makeConstraints {
            $0.top.equalTo(scrollViewContainer.snp.top)
                .inset(AppLayoutConstants.spacing)
            $0.width.equalTo(scrollViewContainer.snp.width)
            $0.height.equalTo(AppLayoutConstants.writingTravelPlanViewHeight)
        }
        
        scheduleTableView.snp.makeConstraints {
            $0.top.equalTo(topView.snp.bottom)
                .offset(AppLayoutConstants.spacing)
            $0.width.equalTo(scrollViewContainer.snp.width)
            $0.height.equalTo(viewModel.schedules.value.count * Int(AppLayoutConstants.cellHeight))
        }
    }
    
    func configureNavigationItems() {
        navigationItem.title = "\(writingStyle.rawValue) \(TextConstants.plan)"
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: AppTextConstants.leftBarButtonTitle, style: .plain, target: self, action: #selector(touchUpLeftBarButton))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: AppTextConstants.rightBarButtonTitle, style: .done, target: self, action: #selector(touchUpRightBarButton))
    }
    
    func configureTopViewValue() {
        topView.titleTextField.text = viewModel.title
        topView.descriptionTextView.text = viewModel.description
    }
    
    func configureTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapView))
        tapGesture.delegate = self
        view.addGestureRecognizer(tapGesture)
    }
}

// MARK: - User Interaction
private extension WritingTravelPlanViewController {
    func configure() {
        scheduleTableView.delegate = self
        scheduleTableView.dataSource = self
        topView.titleTextField.delegate = self
        topView.titleTextField.addTarget(self, action: #selector(editingChangedTitleTextField), for: .editingChanged)
        topView.descriptionTextView.delegate = self
        topView.updateScheduleButton.addTarget(self, action: #selector(touchUpEditButton), for: .touchUpInside)
        topView.createScheduleButton.addTarget(self, action: #selector(touchUpCreateScheduleButton), for: .touchUpInside)
    }
    
    @objc func touchUpRightBarButton() {
        viewModel.setTravelPlanTracker()
        do {
            // 변경 사항이 있다면 저장
            if viewModel.travelPlanTracker.isChanged {
                save(try viewModel.createTravelPlan(), planListIndex)
            }
            navigationController?.popViewController(animated: true)
        } catch {
            guard let error = error as? WritingTravelPlanError else { return }
            alertWillAppear(error.rawValue)
        }
    }
    
    func save(_ travelPlan: YTTravelPlan, _ index: Int?) {
        switch writingStyle {
        case .create:
            Task { try await delegate?.create(travelPlan) }
        case .update:
            guard let index = index else { return }
            Task { try await delegate?.update(at: index, travelPlan) }
        }
    }
    
    @objc func touchUpLeftBarButton() {
        viewModel.setTravelPlanTracker()
        if viewModel.travelPlanTracker.isChanged {
            let actionSheetText = fetchActionSheetText()
            actionSheetWillAppear(actionSheetText.0, actionSheetText.1) { [weak self] in
                self?.navigationController?.popViewController(animated: true)
            }
        } else {
            navigationController?.popViewController(animated: true)
        }
    }
    
    @objc func touchUpCreateScheduleButton() {
        let model = YTSchedule(title: "", description: "", coordinate: CLLocationCoordinate2D())
        let viewModel = ConcreteWritingScheduleViewModel(model)
        let writingView = WritingScheduleViewController(viewModel, writingStyle: .create)
        writingView.delegate = self
        navigationController?.pushViewController(writingView, animated: true)
    }
    
    private func didSelectRow(_ index: Int) {
        let model = viewModel.schedules.value[index]
        let viewModel = ConcreteWritingScheduleViewModel(model)
        let writingView = WritingScheduleViewController(viewModel, writingStyle: .update)
        writingView.delegate = self
        writingView.scheduleListIndex = index
        navigationController?.pushViewController(writingView, animated: true)
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
            topView.updateScheduleButton.isEditingAtTintColor = scheduleTableView.isEditing
        })
    }
    
    @objc func editingChangedTitleTextField() {
        viewModel.editingChangedTitleTextField(topView.titleTextField.text ?? "")
    }
    
    @objc func tapView() {
        view.endEditing(true)
    }
}

// MARK: - Binding
private extension WritingTravelPlanViewController {
    func bindingSchedules() {
        viewModel.schedules
            .receive(on: DispatchQueue.main)
            .sink { [self] schedules in
                reload()
                schedulesDidChaged(schedules)
            }
            .store(in: &subscriptions)
    }
    
    func schedulesDidChaged(_ schedules: [YTSchedule]) {
        let coordinates = extractCoordinatesOfSchedules(schedules)
        
        if coordinates.count == .zero {
            removeMapContentsView()
            updateScrollViewContainerHeight()
        } else {
            updateMapView(coordinates)
        }
    }
    
    func extractCoordinatesOfSchedules(_ schedules: [YTSchedule]) -> [CLLocationCoordinate2D] {
        var coordinates = [CLLocationCoordinate2D]()
        
        for schedule in schedules {
            coordinates.append(schedule.coordinate)
        }
        
        return coordinates
    }
}

// MARK: - MapView
private extension WritingTravelPlanViewController {
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
        scrollViewContainer.addSubview(mapTitleLabel)
        mapTitleLabel.snp.makeConstraints {
            $0.top.equalTo(scheduleTableView.snp.bottom)
                .offset(AppLayoutConstants.largeSpacing)
            $0.leading.equalToSuperview()
                .inset(AppLayoutConstants.spacing)
        }
    }
    
    @MainActor func addMapView() {
        scrollViewContainer.addSubview(mapProvider.mapView)
        mapProvider.mapView.snp.makeConstraints {
            $0.top.equalTo(mapTitleLabel.snp.bottom)
                .offset(AppLayoutConstants.spacing)
            $0.width.equalTo(scrollViewContainer.snp.width)
            $0.height.equalTo(AppLayoutConstants.mapViewHeight)
        }
    }
    
    @MainActor func addMapButtonSet() {
        mapButtonSetView.previousButton.addTarget(self, action: #selector(touchUpPreviousButton), for: .touchUpInside)
        mapButtonSetView.centerButton.addTarget(self, action: #selector(touchUpCenterButton), for: .touchUpInside)
        mapButtonSetView.nextButton.addTarget(self, action: #selector(touchUpNextButton), for: .touchUpInside)
        scrollViewContainer.addSubview(mapButtonSetView)
        mapButtonSetView.snp.makeConstraints {
            $0.top.equalTo(mapProvider.mapView.snp.bottom)
                .offset(AppLayoutConstants.spacing)
            $0.width.equalTo(scrollViewContainer.snp.width)
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
        scrollViewContainer.subviews.contains {
            $0.tag == AppNumberConstants.mapViewTag
        }
    }
    
    func updateMapView(_ coordinates: [CLLocationCoordinate2D]) {
        // Map 관련 뷰가 없다면, ScrollView 높이를 갱신하고, Map 관련 뷰 추가
        if !mapContentsIsAdded() {
            updateScrollViewContainerHeight()
            addMapContentsViews()
        }
        mapProvider.updateMapView(coordinates)
    }
    
    @MainActor func reload() {
        updateScrollViewContainerHeight()
        updateTableViewConstraints()
        scheduleTableView.reloadData()
    }
    
    @MainActor func updateScrollViewContainerHeight() {
        scrollViewContainer.snp.updateConstraints {
            $0.height.equalTo(viewModel.calculatedScrollViewContainerHeight)
        }
    }
    
    @MainActor func updateTableViewConstraints() {
        scheduleTableView.snp.updateConstraints {
            $0.height.equalTo(viewModel.schedules.value.count * Int(AppLayoutConstants.cellHeight))
        }
    }
}

// MARK: - Schedule TableView
extension WritingTravelPlanViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: PlanCell.identifier, for: indexPath) as? PlanCell else { return UITableViewCell() }
        cell.titleLabel.text = viewModel.schedules.value[indexPath.row].title
        cell.descriptionLabel.text = viewModel.schedules.value[indexPath.row].description
        cell.dateLabel.text = viewModel.schedules.value[indexPath.row].date
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

extension WritingTravelPlanViewController: ScheduleTransferDelegate {
    func create(_ schedule: YTSchedule) {
        viewModel.createSchedule(schedule)
    }
    
    func update(at index: Int, _ schedule: YTSchedule) {
        viewModel.updateSchedule(at: index, schedule)
    }
}

extension WritingTravelPlanViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension WritingTravelPlanViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        viewModel.editingChangedDescriptionTextField(textView.text)
    }
}

extension WritingTravelPlanViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if let view = touch.view, view.isDescendant(of: scheduleTableView) {
            return false
        }
        return true
    }
}

private enum LayoutConstants {
    static let tableViewCornerRadius: CGFloat = 10
}

private enum TextConstants {
    static let plan = "Plan"
    static let map = "Map"
}
