//
//  WritingPlanViewController.swift
//  YeolmokTravel
//
//  Created by 김동욱 on 2022/12/20.
//

import UIKit

/// 여행 계획의 자세한 일정 추가 및 수정을 위한 ViewController
final class WritingTravelPlanViewController: UIViewController, Writable, PlanTransfer {
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
    
    private let topBarView: TopBarView = {
        let topBarView = TopBarView()
        return topBarView
    }()
    
    private let titleTextField: UITextField = {
        let textField = UITextField()
        
        textField.textColor = .white
        textField.backgroundColor = .black
        textField.layer.cornerRadius = LayoutConstants.cornerRadius
        textField.layer.borderWidth = LayoutConstants.borderWidth
        textField.layer.borderColor = UIColor.white.cgColor
        textField.font = .boldSystemFont(ofSize: LayoutConstants.largeFontSize)
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none
        
        textField.leftView = UIView(frame: CGRect(x: .zero,
                                                  y: .zero,
                                                  width: LayoutConstants.spacing,
                                                  height: .zero))
        textField.leftViewMode = .always
        
        return textField
    }()
    
    private let descriptionTextView: UITextView = {
        let textView = UITextView()
        
        textView.textColor = .white
        textView.backgroundColor = .black
        textView.layer.cornerRadius = LayoutConstants.cornerRadius
        textView.layer.borderWidth = LayoutConstants.borderWidth
        textView.layer.borderColor = UIColor.white.cgColor
        textView.font = .boldSystemFont(ofSize: LayoutConstants.mediumFontSize)
        
        return textView
    }()
    
    private let scheduleTitleLabel: UILabel = {
        let label = UILabel()
        
        label.text = TextConstants.schedule
        label.textAlignment = .center
        label.textColor = .white
        label.font = .boldSystemFont(ofSize: LayoutConstants.largeFontSize)
        
        return label
    }()
    
    private lazy var addScheduleButton: UIButton = {
        let button = UIButton(type: .custom)
        
        button.setImage(UIImage(systemName: TextConstants.plusIcon), for: .normal)
        button.addTarget(self, action: #selector(touchUpAddScheduleButton), for: .touchUpInside)
        button.tintColor = AppStyles.mainColor
        
        return button
    }()
    
    private let scheduleTableView: UITableView = {
        let tableView = UITableView()
        
        tableView.register(PlanTableViewCell.self,
                           forCellReuseIdentifier: PlanTableViewCell.identifier)
        tableView.backgroundColor = .black
        tableView.layer.cornerRadius = LayoutConstants.tableViewCornerRadius
        tableView.layer.borderWidth = LayoutConstants.borderWidth
        tableView.layer.borderColor = UIColor.white.cgColor
        
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
        configure()
    }
}

// MARK: - SetUp View
extension WritingTravelPlanViewController {
    private func setUpUI() {
        view.backgroundColor = .black
        
        switch writingStyle {
        case .add:
            topBarView.barTitleLabel.text = "\(writingStyle.rawValue) \(TextConstants.plan)"
        case .edit:
            topBarView.barTitleLabel.text = "\(writingStyle.rawValue) \(TextConstants.plan)"
        case .none:
            break
        }
        
        titleTextField.text = model.title
        descriptionTextView.text = model.description
        
        setUpHierachy()
        setUpLayout()
    }
    
    private func setUpHierachy() {
        [topBarView, titleTextField, descriptionTextView, scheduleTitleLabel, addScheduleButton, scheduleTableView].forEach {
            view.addSubview($0)
        }
    }
    
    private func setUpLayout() {
        topBarView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            $0.width.equalToSuperview()
            $0.height.greaterThanOrEqualTo(LayoutConstants.stackViewHeight)
        }
        
        titleTextField.snp.makeConstraints {
            $0.top.equalTo(topBarView.snp.bottom).offset(LayoutConstants.largeSpacing)
            $0.leading.trailing.equalToSuperview()
                .inset(LayoutConstants.spacing)
        }
        
        descriptionTextView.snp.makeConstraints {
            $0.top.equalTo(titleTextField.snp.bottom)
                .offset(LayoutConstants.spacing)
            $0.leading.trailing.equalToSuperview()
                .inset(LayoutConstants.spacing)
            $0.height.equalTo(LayoutConstants.cellHeight)
        }
        
        scheduleTitleLabel.snp.makeConstraints {
            $0.top.equalTo(descriptionTextView.snp.bottom)
                .offset(LayoutConstants.largeSpacing)
            $0.leading.equalToSuperview()
                .inset(LayoutConstants.schedultTitleLeading)
        }
        
        addScheduleButton.snp.makeConstraints {
            $0.centerY.equalTo(scheduleTitleLabel)
            $0.trailing.equalToSuperview()
                .inset(LayoutConstants.largeSpacing)
        }
        
        scheduleTableView.snp.makeConstraints {
            $0.top.equalTo(scheduleTitleLabel.snp.bottom)
                .offset(LayoutConstants.spacing)
            $0.leading.trailing.equalToSuperview()
                .inset(LayoutConstants.spacing)
            $0.height.equalTo(model.schedulesCount * Int(LayoutConstants.cellHeight))
        }
    }
    
    private func configure() {
        scheduleTableView.delegate = self
        scheduleTableView.dataSource = self
        topBarView.saveBarButton.addTarget(self, action: #selector(touchUpSaveBarButton), for: .touchUpInside)
        topBarView.cancelBarButton.addTarget(self, action: #selector(touchUpCancelBarButton), for: .touchUpInside)
    }
    
    @objc func touchUpSaveBarButton() {
        if titleTextField.text == "" {
            alertWillAppear(AlertText.titleMessage)
            return
        } else {
            model.setTravelPlan(titleTextField.text ?? "", descriptionTextView.text)
            save(model, planListIndex)
            dismiss(animated: true)
        }
    }
    
    @objc func touchUpCancelBarButton() {
        planTracker.setPlan(TravelPlan(title: titleTextField.text ?? "",
                                       description: descriptionTextView.text,
                                       schedules: model.schedules))
        if planTracker.isChanged {
            let actionSheetText = fetchActionSheetText()
            actionSheetWillApear(actionSheetText.0, actionSheetText.1)
        } else {
            dismiss(animated: true)
        }
    }
    
    @objc func touchUpAddScheduleButton() {
        present(setUpWritingView(.add), animated: true)
    }
    
    private func setUpWritingView(at index: Int? = nil, _ writingStyle: WritingStyle) -> WritingScheduleViewController {
        let writingScheduleViewController = WritingScheduleViewController()
        switch writingStyle {
        case .add:
            let model = Schedule(title: "", description: "")
            writingScheduleViewController.model = model
            writingScheduleViewController.addDelegate = self
        case .edit:
            let model = model.schedules[index!]
            writingScheduleViewController.model = model
            writingScheduleViewController.editDelegate = self
            writingScheduleViewController.scheduleListIndex = index
        }
        writingScheduleViewController.writingStyle = writingStyle
        writingScheduleViewController.modalPresentationStyle = .fullScreen
        return writingScheduleViewController
    }
    
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
    
    @MainActor private func reload() {
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

private enum LayoutConstants {
    static let spacing: CGFloat = 8
    static let largeSpacing: CGFloat = 20
    static let stackViewCornerRadius: CGFloat = 10
    static let cornerRadius: CGFloat = 5
    static let tableViewCornerRadius: CGFloat = 10
    static let borderWidth: CGFloat = 1
    static let largeFontSize: CGFloat = 25
    static let mediumFontSize: CGFloat = 20
    static let topBottomMargin: CGFloat = 10
    static let sideMargin: CGFloat = 15
    static let stackViewHeight: CGFloat = 50
    static let schedultTitleLeading: CGFloat = 15
    static let cellHeight: CGFloat = 100
}

private enum TextConstants {
    static let saveButtonTitle = "Save"
    static let cancelButtonTItle = "Cancel"
    static let plan = "Plan"
    static let descriptionPlaceolder = "상세"
    static let schedule = "Schedule"
    static let plusIcon = "plus"
}
