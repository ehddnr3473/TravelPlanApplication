//
//  WritingPlanViewController.swift
//  YeolmokTravel
//
//  Created by 김동욱 on 2022/12/20.
//

import UIKit
import Combine
import CoreLocation

/// 여행 계획의 자세한 일정 추가 및 수정을 위한 ViewController
final class WritingTravelPlanViewController: UIViewController, Writable {
    typealias WritableModelType = TravelPlan
    // MARK: - Properties
    var writingStyle: WritingStyle
    var addDelegate: PlanTransfer?
    var editDelegate: PlanTransfer?
    var planListIndex: Int?
    var viewModel: WritingTravelPlanViewModel
    
    private let descriptionTextPublisher = PassthroughSubject<String, Never>()
    private var subscriptions = Set<AnyCancellable>()
    
    init(_ viewModel: WritingTravelPlanViewModel, _ writingStyle: WritingStyle) {
        self.viewModel = viewModel
        self.writingStyle = writingStyle
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
        
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        configureWritingTravelPlanViewValue()
        configureAndEmbedMapView()
        configure()
        setBindings()
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
            $0.height.equalTo(800)
        }
        
        writingTravelPlanView.snp.makeConstraints {
            $0.top.equalTo(scrollViewContainer.snp.top)
                .inset(AppLayoutConstants.spacing)
            $0.width.equalTo(scrollViewContainer.snp.width)
            $0.height.equalTo(LayoutConstants.writingTravelPlanViewHeight)
        }
        
        scheduleTableView.snp.makeConstraints {
            $0.top.equalTo(writingTravelPlanView.snp.bottom)
                .offset(AppLayoutConstants.spacing)
            $0.width.equalTo(scrollViewContainer.snp.width)
            $0.height.equalTo(viewModel.schedulesCount * Int(LayoutConstants.cellHeight))
        }
    }
    
    func configureWritingTravelPlanViewValue() {
        writingTravelPlanView.titleTextField.text = viewModel.modelTitle
        writingTravelPlanView.descriptionTextView.text = viewModel.modelDescription
        writingTravelPlanView.addScheduleButton.addTarget(self, action: #selector(touchUpAddScheduleButton), for: .touchUpInside)
        writingTravelPlanView.descriptionTextView.delegate = self
    }
    
    func configure() {
        scheduleTableView.delegate = self
        scheduleTableView.dataSource = self
        topBarView.saveBarButton.addTarget(self, action: #selector(touchUpSaveBarButton), for: .touchUpInside)
        topBarView.cancelBarButton.addTarget(self, action: #selector(touchUpCancelBarButton), for: .touchUpInside)
    }
    
    func configureAndEmbedMapView() {
        let coordinates = viewModel.coordinatesOfSchedules()
        guard coordinates.count != 0 else { return }
        
        let mapViewController = MapViewController(coordinates)
        addChild(mapViewController)
        mapViewController.didMove(toParent: self)
        
        scrollViewContainer.addSubview(mapViewController.mapView)
        mapViewController.mapView.snp.makeConstraints {
            $0.top.equalTo(scheduleTableView.snp.bottom)
                .offset(AppLayoutConstants.largeSpacing)
            $0.width.equalTo(scrollViewContainer.snp.width)
            $0.height.equalTo(500)
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
    
    func setBindings() {
        bindingText()
    }
    
    func bindingText() {
        let input = WritingTravelPlanViewModel.TextInput(
            title: writingTravelPlanView.titleTextField.textPublisher,
            description: descriptionTextPublisher)
        
        let output = viewModel.transform(input: input)
        
        output.buttonState
            .receive(on: RunLoop.main)
            .sink { [weak self] state in
                self?.topBarView.saveBarButton.isEnabled = state
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
    
    @MainActor func reload() {
        scheduleTableView.snp.updateConstraints {
            $0.height.equalTo(viewModel.schedulesCount * Int(LayoutConstants.cellHeight))
        }
        scheduleTableView.reloadData()
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
        LayoutConstants.cellHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        navigationController?.pushViewController(setUpWritingView(at: indexPath.row, .edit), animated: true)
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
    static let cellHeight: CGFloat = 100
    static let writingTravelPlanViewHeight: CGFloat = 200
}

private enum TextConstants {
    static let plan = "Plan"
}
