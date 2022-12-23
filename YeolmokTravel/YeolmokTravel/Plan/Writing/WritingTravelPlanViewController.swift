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
    var writableModel: WritablePlan<ModelType>!
    var model: ModelType! {
        didSet {
            writableModel = WritablePlan(model)
        }
    }
    var writingStyle: WritingStyle!
    var addDelegate: PlanTransfer?
    var editDelegate: PlanTransfer?
    var planListIndex: Int?
    
    private let topBarStackView: UIStackView = {
        let stackView = UIStackView()
        
        stackView.axis = .horizontal
        stackView.distribution = .equalCentering
        stackView.backgroundColor = .darkGray
        stackView.layer.cornerRadius = LayoutConstants.stackViewCornerRadius
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = UIEdgeInsets(top: LayoutConstants.topBottomMargin,
                                               left: LayoutConstants.sideMargin,
                                               bottom: LayoutConstants.topBottomMargin,
                                               right: LayoutConstants.sideMargin)
        stackView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        return stackView
    }()
    
    private let barTitleLabel: UILabel = {
        let label = UILabel()
        
        label.textAlignment = .center
        label.font = .boldSystemFont(ofSize: LayoutConstants.largeFontSize)
        label.textColor = .white
        
        return label
    }()
    
    private lazy var saveBarButton: UIButton = {
        let button = UIButton(type: .custom)
        
        button.setTitle(TextConstants.saveButtonTitle, for: .normal)
        button.addTarget(self, action: #selector(touchUpSaveBarButton), for: .touchUpInside)
        button.setTitleColor(AppStyles.mainColor, for: .normal)
        
        return button
    }()
    
    private lazy var cancelBarButton: UIButton = {
        let button = UIButton(type: .custom)
        
        button.setTitle(TextConstants.cancelButtonTItle, for: .normal)
        button.addTarget(self, action: #selector(touchUpCancelBarButton), for: .touchUpInside)
        
        return button
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
            barTitleLabel.text = "\(writingStyle.rawValue) \(TextConstants.plan)"
        case .edit:
            barTitleLabel.text = "\(writingStyle.rawValue) \(TextConstants.plan)"
        case .none:
            break
        }
        
        titleTextField.text = model.title
        descriptionTextView.text = model.description
        
        setUpHierachy()
        setUpLayout()
    }
    private func setUpHierachy() {
        [cancelBarButton, barTitleLabel, saveBarButton].forEach {
            topBarStackView.addArrangedSubview($0)
        }
        
        [topBarStackView, titleTextField, descriptionTextView, scheduleTitleLabel, addScheduleButton, scheduleTableView].forEach {
            view.addSubview($0)
        }
    }
    
    private func setUpLayout() {
        topBarStackView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            $0.width.equalToSuperview()
            $0.height.greaterThanOrEqualTo(LayoutConstants.stackViewHeight)
        }
        
        titleTextField.snp.makeConstraints {
            $0.top.equalTo(topBarStackView.snp.bottom).offset(LayoutConstants.largeSpacing)
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
    }
    
    @objc func touchUpSaveBarButton() {
        writableModel.setPlan(titleTextField.text ?? "", descriptionTextView.text, model.fromDate, model.toDate)
        if writableModel.titleIsEmpty {
            alertWillAppear()
            return
        } else {
            save(writableModel.plan, planListIndex)
            dismiss(animated: true)
        }
    }
    
    @objc func touchUpCancelBarButton() {
        writableModel.setPlan(titleTextField.text ?? "", descriptionTextView.text, model.fromDate, model.toDate)
        if writableModel.isChanged {
            let actionSheetText = fetchActionSheetText()
            actionSheetWillApear(actionSheetText.0, actionSheetText.1)
        } else {
            dismiss(animated: true)
        }
    }
    
    @objc func touchUpAddScheduleButton() {
        presentWritableView(setUpAddScheduleViewController())
    }
    
    // 자세한 일정을 추가하기 위해 프레젠테이션할 ViewController 반환
    private func setUpAddScheduleViewController() -> WritingScheduleViewController {
        let model = Schedule(title: "")
        let writingScheduleViewController = WritingScheduleViewController()
        writingScheduleViewController.model = model
        writingScheduleViewController.writingStyle = .add
        writingScheduleViewController.addDelegate = self
        writingScheduleViewController.modalPresentationStyle = .fullScreen
        return writingScheduleViewController
    }
    
    func writingHandler(_ plan: some Plan, _ index: Int?) {
        guard let plan = plan as? Schedule else { return }
        if let index = index {
            // edit
            writableModel.plan.schedules[index] = plan
            model.editSchedule(at: index, plan)
            reloadScheduleList()
        } else {
            // add
            writableModel.plan.schedules.append(plan)
            model.addSchedule(plan)
            reloadScheduleList()
        }
    }
    
    @MainActor private func reloadScheduleList() {
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
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        model.schedulesCount
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        LayoutConstants.cellHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        presentWritableView(setUpModifySchduleViewController(indexPath.row))
    }
    
    // 자세한 일정을 수정하기 위해 프레젠테이션할 ViewController 반환
    private func setUpModifySchduleViewController(_ index: Int) -> WritingScheduleViewController {
        let model = model.schedules[index]
        let writingScheduleViewController = WritingScheduleViewController()
        writingScheduleViewController.model = model
        writingScheduleViewController.writingStyle = .edit
        writingScheduleViewController.editDelegate = self
        writingScheduleViewController.modalPresentationStyle = .fullScreen
        writingScheduleViewController.scheduleListIndex = index
        return writingScheduleViewController
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
