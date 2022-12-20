//
//  PlanView.swift
//  YeolmokTravel
//
//  Created by 김동욱 on 2022/12/20.
//

import UIKit
import SnapKit

/// Plan View
final class TravelPlanView: UIViewController {
    // MARK: - Properties
    var viewModel: TravelPlaner!
    private var titleLabel: UILabel = {
        let label = UILabel()
        
        label.textAlignment = .center
        label.textColor = .white
        label.text = TextConstants.title
        label.font = .boldSystemFont(ofSize: AppStyles.titleFontSize)
        
        return label
    }()
    
    private lazy var addButton: UIButton = {
        let button = UIButton(type: .custom)
        
        button.setBackgroundImage(UIImage(systemName: TextConstants.plusIconName), for: .normal)
        button.tintColor = AppStyles.mainColor
        button.addTarget(self, action: #selector(touchUpAddButton), for: .touchUpInside)
        
        return button
    }()
    
    private var planTableView: UITableView = {
        let tableView = UITableView()
        
        tableView.register(TravelPlanTableViewCell.self, forCellReuseIdentifier: TravelPlanTableViewCell.identifier)
        tableView.backgroundColor = .black
        tableView.layer.cornerRadius = LayoutConstants.cornerRadius
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
extension TravelPlanView {
    private func setUpUI() {
        view.backgroundColor = .black
        setUpHierachy()
        setUpLayout()
    }
    
    private func setUpHierachy() {
        [titleLabel, addButton, planTableView].forEach {
            view.addSubview($0)
        }
    }
    
    private func setUpLayout() {
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            $0.leading.equalToSuperview()
                .inset(LayoutConstants.spacing)
        }
        
        addButton.snp.makeConstraints {
            $0.centerY.equalTo(titleLabel.snp.centerY)
            $0.trailing.equalToSuperview()
                .inset(LayoutConstants.spacing)
            $0.size.equalTo(LayoutConstants.buttonSize)
        }
        
        planTableView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom)
                .offset(LayoutConstants.planTableViewTopOffset)
            $0.leading.trailing.equalToSuperview()
                .inset(LayoutConstants.spacing)
            $0.height.equalTo(viewModel.planCount * Int(LayoutConstants.cellHeight))
        }
    }
    
    private func configure() {
        planTableView.delegate = self
        planTableView.dataSource = self
    }
    
    @objc func touchUpAddButton() {
        presentWritableView(viewModel.setUpAddPlanView())
    }
    
    @MainActor func presentWritableView(_ writableView: Writable) {
        guard let writableView = writableView as? WritingPlanViewController else { return }
        present(writableView, animated: true)
    }
    
    @MainActor private func reloadTodoList() {
        planTableView.snp.updateConstraints {
            $0.height.equalTo(viewModel.planCount * Int(LayoutConstants.cellHeight))
        }
        planTableView.reloadData()
    }
}

// MARK: - TableView
extension TravelPlanView: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TravelPlanTableViewCell.identifier, for: indexPath) as? TravelPlanTableViewCell else { return UITableViewCell() }
        cell.titleLabel.text = viewModel.title(indexPath.row)
        cell.dateLabel.text = viewModel.date(indexPath.row)
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        LayoutConstants.cellHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        presentWritableView(viewModel.setUpModifyPlanView(at: indexPath.row))
    }
}

private enum TextConstants {
    static let title = "Plan"
    static let plusIconName = "plus"
}

private enum LayoutConstants {
    static let spacing: CGFloat = 8
    static let buttonSize = CGSize(width: 44.44, height: 44.44)
    static let planTableViewTopOffset: CGFloat = 20
    static let borderWidth: CGFloat = 1
    static let cornerRadius: CGFloat = 10
    static let cellHeight: CGFloat = 100
}