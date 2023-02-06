//
//  WritingPlanViewController.swift
//  YeolmokTravel
//
//  Created by 김동욱 on 2022/12/20.
//

import UIKit
import Combine
import CoreLocation

/*
 - 여행 계획의 자세한 일정 추가 및 수정을 위한 ViewController
 - Schedules의 coordinate(좌표 - 위도(latitude) 및 경도(longitude)) 정보를 취합해서 MKMapView로 표현
 */
final class WritingTravelPlanViewController: UIViewController, Writable {
    typealias WritableModelType = TravelPlan
    // MARK: - Properties
    var writingStyle: WritingStyle
    var addDelegate: PlanTransfer?
    var editDelegate: PlanTransfer?
    var planListIndex: Int?
    private let viewModel: WritingTravelPlanViewModel
    private let mapProvider: Mappable
    
    private let descriptionTextPublisher: CurrentValueSubject<String, Never>
    private var subscriptions = Set<AnyCancellable>()
    
    init(_ viewModel: WritingTravelPlanViewModel, _ mapProvider: Mappable, _ writingStyle: WritingStyle) {
        self.viewModel = viewModel
        self.mapProvider = mapProvider
        self.writingStyle = writingStyle
        self.descriptionTextPublisher = CurrentValueSubject<String, Never>(viewModel.modelDescription)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) not implemented")
    }
    
    deinit {
        print("deinit: WritingTravelPlanViewController")
    }
    
    private let topBarView: TopBarView = {
        let topBarView = TopBarView()
        return topBarView
    }()
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.isScrollEnabled = true
        return scrollView
    }()
    
    private let scrollViewContainer: UIView = {
        let view = UIView()
        return view
    }()
    
    private let writingTravelPlanView: WritingTravelPlanView = {
        let writingTravelPlanView = WritingTravelPlanView()
        writingTravelPlanView.backgroundColor = .black
        return writingTravelPlanView
    }()
    
    private let scheduleTableView: UITableView = {
        let tableView = UITableView()
        tableView.register(PlanTableViewCell.self,
                           forCellReuseIdentifier: PlanTableViewCell.identifier)
        tableView.backgroundColor = .black
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        embedMapView()
        configure()
        setBindings()
        configureWritingTravelPlanViewValue()
    }
}

// MARK: - Configure View
private extension WritingTravelPlanViewController {
    func configureView() {
        view.backgroundColor = .black
        topBarView.barTitleLabel.text = "\(writingStyle.rawValue) \(TextConstants.plan)"
        configureHierarchy()
        configureLayoutConstraint()
    }
    
    func configureHierarchy() {
        [writingTravelPlanView, scheduleTableView].forEach {
            scrollViewContainer.addSubview($0)
        }
        
        scrollView.addSubview(scrollViewContainer)
        
        [topBarView, scrollView].forEach {
            view.addSubview($0)
        }
    }
    
    func configureLayoutConstraint() {
        topBarView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
                .inset(AppLayoutConstants.spacing)
            $0.leading.trailing.equalToSuperview()
                .inset(AppLayoutConstants.spacing)
            $0.height.equalTo(LayoutConstants.topBarViewHeight)
        }
        
        scrollView.snp.makeConstraints {
            $0.top.equalTo(topBarView.snp.bottom)
                .offset(AppLayoutConstants.largeSpacing)
            $0.leading.bottom.trailing.equalToSuperview()
                .inset(AppLayoutConstants.spacing)
        }
        
        scrollViewContainer.snp.makeConstraints {
            $0.top.equalTo(scrollView.contentLayoutGuide.snp.top)
            $0.leading.equalTo(scrollView.contentLayoutGuide.snp.leading)
            $0.bottom.equalTo(scrollView.contentLayoutGuide.snp.bottom)
            $0.trailing.equalTo(scrollView.contentLayoutGuide.snp.trailing)
            
            $0.width.equalTo(scrollView.frameLayoutGuide.snp.width)
            $0.height.equalTo(viewModel.scrollViewContainerheight)
        }
        
        writingTravelPlanView.snp.makeConstraints {
            $0.top.equalTo(scrollViewContainer.snp.top)
                .inset(AppLayoutConstants.spacing)
            $0.width.equalTo(scrollViewContainer.snp.width)
            $0.height.equalTo(AppLayoutConstants.writingTravelPlanViewHeight)
        }
        
        scheduleTableView.snp.makeConstraints {
            $0.top.equalTo(writingTravelPlanView.snp.bottom)
                .offset(AppLayoutConstants.spacing)
            $0.width.equalTo(scrollViewContainer.snp.width)
            $0.height.equalTo(viewModel.schedulesCount * Int(AppLayoutConstants.cellHeight))
        }
    }
    
    func configureWritingTravelPlanViewValue() {
        writingTravelPlanView.titleTextField.text = viewModel.modelTitle
        writingTravelPlanView.descriptionTextView.text = viewModel.modelDescription
        writingTravelPlanView.editScheduleButton.addTarget(self, action: #selector(touchUpEditButton), for: .touchUpInside)
        writingTravelPlanView.addScheduleButton.addTarget(self, action: #selector(touchUpAddScheduleButton), for: .touchUpInside)
        writingTravelPlanView.descriptionTextView.delegate = self
    }
    
    func configure() {
        scheduleTableView.delegate = self
        scheduleTableView.dataSource = self
        if writingStyle == .edit { topBarView.saveBarButton.isValidAtTintColor = true }
        topBarView.saveBarButton.addTarget(self, action: #selector(touchUpSaveBarButton), for: .touchUpInside)
        topBarView.cancelBarButton.addTarget(self, action: #selector(touchUpCancelBarButton), for: .touchUpInside)
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
        guard viewModel.coordinatesOfSchedules().count != .zero else { return }
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
            guard let label = $0.accessibilityLabel else { return false }
            return label == AppTextConstants.mapViewAccessibilityLabel
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
            $0.height.equalTo(viewModel.scrollViewContainerheight)
        }
    }
    
    @MainActor func updateTableViewConstraints() {
        scheduleTableView.snp.updateConstraints {
            $0.height.equalTo(viewModel.schedulesCount * Int(AppLayoutConstants.cellHeight))
        }
    }
}

// MARK: - User Interaction
private extension WritingTravelPlanViewController {
    @objc func touchUpSaveBarButton() {
        viewModel.setTravelPlan()
        save(viewModel.model, planListIndex)
        dismiss(animated: true)
    }
    
    @objc func touchUpCancelBarButton() {
        viewModel.setPlan()
        if viewModel.planTracker.isChanged {
            let actionSheetText = fetchActionSheetText()
            actionSheetWillApear(actionSheetText.0, actionSheetText.1) { [weak self] in
                self?.dismiss(animated: true)
            }
        } else {
            dismiss(animated: true)
        }
    }
    
    @objc func touchUpAddScheduleButton() {
        navigationController?.pushViewController(setUpWritingView(.add), animated: true)
    }
    
    @objc func touchUpPreviousButton() {
        // 이전 좌표로 카메라 이동
        mapProvider.decreasePointer()
    }
    
    @objc func touchUpNextButton() {
        // 다음 좌표로 카메라 이동
        mapProvider.increasePointer()
    }
    
    @objc func touchUpCenterButton() {
        // 중심으로 카메라 이동
        mapProvider.initializePointer()
    }
    
    @objc func touchUpEditButton() {
        UIView.animate(withDuration: 0.2, delay: 0, animations: { [self] in
            scheduleTableView.isEditing.toggle()
        }, completion: { [self] _ in
            writingTravelPlanView.editScheduleButton.isEditingAtTintColor = scheduleTableView.isEditing
        })
    }
    
    func setBindings() {
        bindingText()
        bindingMapView()
    }
    
    func bindingText() {
        let input = WritingTravelPlanViewModel.TextInput(
            title: writingTravelPlanView.titleTextField.textPublisher,
            description: descriptionTextPublisher
        )
        
        let output = viewModel.transform(input: input)
        
        output.buttonState
            .receive(on: RunLoop.main)
            .assign(to: \.isValidAtTintColor, on: topBarView.saveBarButton)
            .store(in: &subscriptions)
    }
    
    func bindingMapView() {
        viewModel.coordinatesPublisher
            .receive(on: RunLoop.main)
            .sink { [weak self] coordinates in
                if coordinates.count == .zero {
                    self?.removeMapContentsView()
                    self?.updateScrollViewContainerHeight()
                } else {
                    self?.updateMapView(coordinates)
                }
            }
            .store(in: &subscriptions)
    }
    
    func setUpWritingView(at index: Int? = nil, _ writingStyle: WritingStyle) -> WritingScheduleViewController {
        switch writingStyle {
        case .add:
            let model = Schedule(title: "", description: "", coordinate: CLLocationCoordinate2D())
            let viewModel = WritingScheduleViewModel(model)
            let writingView = WritingScheduleViewController(viewModel, writingStyle: writingStyle)
            writingView.addDelegate = self
            writingView.modalPresentationStyle = .fullScreen
            return writingView
        case .edit:
            let model = viewModel.schedules[index!]
            let viewModel = WritingScheduleViewModel(model)
            let writingView = WritingScheduleViewController(viewModel, writingStyle: writingStyle)
            writingView.editDelegate = self
            writingView.scheduleListIndex = index
            writingView.modalPresentationStyle = .fullScreen
            return writingView
        }
    }
}

// MARK: - Schedule TableView
extension WritingTravelPlanViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: PlanTableViewCell.identifier, for: indexPath) as? PlanTableViewCell else { return UITableViewCell() }
        cell.titleLabel.text = viewModel.schedules[indexPath.row].title
        cell.descriptionLabel.text = viewModel.schedules[indexPath.row].description
        cell.dateLabel.text = viewModel.schedules[indexPath.row].date
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.schedulesCount
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        AppLayoutConstants.cellHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        navigationController?.pushViewController(setUpWritingView(at: indexPath.row, .edit), animated: true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            removeSchedule(at: indexPath.row)
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
    
    private func removeSchedule(at index: Int) {
        viewModel.removeSchedule(at: index)
    }
}

extension WritingTravelPlanViewController: PlanTransfer {
    func writingHandler(_ plan: some Plan, _ index: Int?) {
        guard let plan = plan as? Schedule else { return }
        if let index = index {
            // edit
            viewModel.editSchedule(at: index, plan)
            reload()
        } else {
            // add
            viewModel.addSchedule(plan)
            reload()
        }
    }
}

extension WritingTravelPlanViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        descriptionTextPublisher.send(textView.text)
    }
}

private enum LayoutConstants {
    static let tableViewCornerRadius: CGFloat = 10
    static let topBarViewHeight: CGFloat = 50
}

private enum TextConstants {
    static let plan = "Plan"
    static let map = "Map"
}
