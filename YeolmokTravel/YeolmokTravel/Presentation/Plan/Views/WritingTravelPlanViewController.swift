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
    var planTracker: PlanTracker<ModelType>!
    var model: ModelType! {
        didSet {
            planTracker = PlanTracker(model)
        }
    }
    var writingStyle: WritingStyle!
    var addDelegate: PlanTransfer?
    var editDelegate: PlanTransfer?
    var planListIndex: Int?
    var viewModel: WritingPlanViewModel!
    private var subscriptions = Set<AnyCancellable>()
    
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
        setUpUI()
        configureWritingTravelPlanViewValue()
        configure()
        setBindings()
    }
}

// MARK: - SetUp View
private extension WritingTravelPlanViewController {
    func setUpUI() {
        view.backgroundColor = .black
        
        switch writingStyle {
        case .add:
            topBarView.barTitleLabel.text = "\(writingStyle.rawValue) \(TextConstants.plan)"
        case .edit:
            topBarView.barTitleLabel.text = "\(writingStyle.rawValue) \(TextConstants.plan)"
        case .none:
            break
        }
        
        setUpHierarchy()
        setUpLayout()
    }
    
    func configureWritingTravelPlanViewValue() {
        writingTravelPlanView.titleTextField.text = model.title
        writingTravelPlanView.descriptionTextView.text = model.description
        writingTravelPlanView.addScheduleButton.addTarget(self, action: #selector(touchUpAddScheduleButton), for: .touchUpInside)
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
        }
        
        writingTravelPlanView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.trailing.equalToSuperview()
                .inset(AppLayoutConstants.spacing)
            $0.height.equalTo(300)
        }
        
        scheduleTableView.snp.makeConstraints {
            $0.top.equalTo(writingTravelPlanView.snp.bottom)
                .offset(AppLayoutConstants.spacing)
            $0.leading.trailing.equalToSuperview()
                .inset(AppLayoutConstants.spacing)
            $0.height.equalTo(model.schedulesCount * Int(LayoutConstants.cellHeight))
        }
    }
    
    func configure() {
        scheduleTableView.delegate = self
        scheduleTableView.dataSource = self
        topBarView.saveBarButton.addTarget(self, action: #selector(touchUpSaveBarButton), for: .touchUpInside)
        topBarView.cancelBarButton.addTarget(self, action: #selector(touchUpCancelBarButton), for: .touchUpInside)
    }
    
    @objc func touchUpSaveBarButton() {
        if writingTravelPlanView.titleTextField.text == "" {
            alertWillAppear(AlertText.titleMessage)
            return
        } else {
            model.setTravelPlan(writingTravelPlanView.titleTextField.text ?? "", writingTravelPlanView.descriptionTextView.text)
            save(model, planListIndex)
            dismiss(animated: true)
        }
    }
    
    @objc func touchUpCancelBarButton() {
        planTracker.setPlan(TravelPlan(title: writingTravelPlanView.titleTextField.text ?? "",
                                       description: writingTravelPlanView.descriptionTextView.text,
                                       schedules: model.schedules))
        if planTracker.isChanged {
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
        let input = WritingPlanViewModel.Input(title: writingTravelPlanView.titleTextField.textPublisher)
        
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
            let model = model.schedules[index!]
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
            $0.height.equalTo(model.schedulesCount * Int(LayoutConstants.cellHeight))
        }
        scheduleTableView.reloadData()
    }
}

extension WritingTravelPlanViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: PlanTableViewCell.identifier, for: indexPath) as? PlanTableViewCell else { return UITableViewCell() }
        cell.titleLabel.text = model.schedules[indexPath.row].title
        cell.descriptionLabel.text = model.schedules[indexPath.row].description
        cell.dateLabel.text = model.schedules[indexPath.row].date
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        model.schedulesCount
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
            model.editSchedule(at: index, plan)
            reload()
        } else {
            // add
            model.addSchedule(plan)
            reload()
        }
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
