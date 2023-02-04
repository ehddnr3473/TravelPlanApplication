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
    typealias ModelType = TravelPlan
    // MARK: - Properties
    var writingStyle: WritingStyle!
    var addDelegate: PlanTransfer?
    var editDelegate: PlanTransfer?
    var planListIndex: Int?
    var viewModel: WritingTravelPlanViewModel!
    
    private let descriptionTextPublisher = PassthroughSubject<String, Never>()
    private var subscriptions = Set<AnyCancellable>()
    
//    init(_ viewModel: WritingTravelPlanViewModel, _ writingStyle: WritingStyle) {
//        self.viewModel = viewModel
//        self.writingStyle = writingStyle
//        super.init(nibName: nil, bundle: nil)
//    }
//
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) not implemented")
//    }
    
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
        return scrollView
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
        configureAndEmbedMapView()
        setUpUI()
        configureWritingTravelPlanViewValue()
        configure()
        setBindings()
    }
}

// MARK: - View
private extension WritingTravelPlanViewController {
    func setUpUI() {
        view.backgroundColor = .black
        
        switch writingStyle {
        case .add:
            topBarView.barTitleLabel.text = "\(writingStyle.rawValue) \(TextConstants.plan)"
        case .edit:
            topBarView.barTitleLabel.text = "\(writingStyle.rawValue) \(TextConstants.plan)"
        case .none:
            fatalError("WritingStyle injection is required.")
        }
        
        setUpHierarchy()
        setUpLayout()
    }
    
    func setUpHierarchy() {
        [writingTravelPlanView, scheduleTableView].forEach {
            scrollView.addSubview($0)
        }
        
        [topBarView, scrollView].forEach {
            view.addSubview($0)
        }
    }
    
    func setUpLayout() {
        topBarView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            $0.width.equalToSuperview()
            $0.height.greaterThanOrEqualTo(LayoutConstants.stackViewHeight)
        }
        
        scrollView.snp.makeConstraints {
            $0.top.equalTo(topBarView.snp.bottom)
                .offset(AppLayoutConstants.largeSpacing)
            $0.leading.bottom.trailing.equalToSuperview()
                .inset(AppLayoutConstants.spacing)
        }
        
        writingTravelPlanView.snp.makeConstraints {
            $0.top.equalTo(scrollView.contentLayoutGuide.snp.top)
            $0.width.equalTo(scrollView.frameLayoutGuide.snp.width)
            $0.height.equalTo(300)
        }
        
        scheduleTableView.snp.makeConstraints {
            $0.top.equalTo(writingTravelPlanView.snp.bottom)
                .offset(AppLayoutConstants.spacing)
            $0.width.equalTo(scrollView.frameLayoutGuide.snp.width)
            $0.height.equalTo(viewModel.schedulesCount * Int(LayoutConstants.cellHeight))
        }
        // mapViewController.view
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
        let mapViewController = MapViewController([.init(coordinate: CLLocationCoordinate2D(), title: "")])
        addChild(mapViewController)
        mapViewController.didMove(toParent: self)
    }
    
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
        let writingScheduleViewController = WritingScheduleViewController()
        switch writingStyle {
        case .add:
            let model = Schedule(title: "", description: "", coordinate: CLLocationCoordinate2D())
            writingScheduleViewController.model = model
            writingScheduleViewController.addDelegate = self
        case .edit:
            let model = viewModel.schedules[index!]
            writingScheduleViewController.model = model
            writingScheduleViewController.editDelegate = self
            writingScheduleViewController.scheduleListIndex = index
        }
        let viewModel = WritingScheduleViewModel()
        writingScheduleViewController.viewModel = viewModel
        writingScheduleViewController.writingStyle = writingStyle
        writingScheduleViewController.modalPresentationStyle = .fullScreen
        return writingScheduleViewController
    }
    
    @MainActor func reload() {
        scheduleTableView.snp.updateConstraints {
            $0.height.equalTo(viewModel.schedulesCount * Int(LayoutConstants.cellHeight))
        }
        scheduleTableView.reloadData()
    }
}

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
    static let stackViewHeight: CGFloat = 50
    static let cellHeight: CGFloat = 100
}

private enum TextConstants {
    static let plan = "Plan"
}
