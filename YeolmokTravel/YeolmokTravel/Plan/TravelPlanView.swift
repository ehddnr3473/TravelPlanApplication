//
//  PlanView.swift
//  YeolmokTravel
//
//  Created by 김동욱 on 2022/12/20.
//

import UIKit
import SnapKit
import Combine

/// TravelPlan View
final class TravelPlanView: UIViewController {
    // MARK: - Properties
    var viewModel: TravelPlaner!
    private var subscriptions = [AnyCancellable]()
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
        
        tableView.register(PlanTableViewCell.self,
                           forCellReuseIdentifier: PlanTableViewCell.identifier)
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
        setBindings()
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
    
    private func setBindings() {
        viewModel.publisher
            .sink { self.reload() }
            .store(in: &subscriptions)
    }
    
    @objc func touchUpAddButton() {
        present(viewModel.setUpWritingView(.add), animated: true)
    }
    
    @MainActor private func reload() {
        planTableView.snp.updateConstraints {
            $0.height.equalTo(viewModel.planCount * Int(LayoutConstants.cellHeight))
        }
        planTableView.reloadData()
    }
}

// MARK: - TableView
extension TravelPlanView: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: PlanTableViewCell.identifier, for: indexPath) as? PlanTableViewCell else { return UITableViewCell() }
        cell.titleLabel.text = viewModel.title(indexPath.row)
        cell.dateLabel.text = viewModel.date(indexPath.row)
        cell.descriptionLabel.text = viewModel.description(indexPath.row)
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.planCount
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        LayoutConstants.cellHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        present(viewModel.setUpWritingView(at: indexPath.row, .edit), animated: true)
    }
}

private enum TextConstants {
    static let title = "Plans"
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
