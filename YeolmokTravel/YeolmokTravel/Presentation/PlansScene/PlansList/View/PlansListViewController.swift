//
//  PlansListViewController.swift
//  YeolmokTravel
//
//  Created by 김동욱 on 2022/12/20.
//

import UIKit
import SnapKit
import Combine
import FirebasePlatform
import Domain

protocol PlanTransferDelegate: AnyObject {
    func create(_ plan: Plan) async throws
    func update(at index: Int, _ plan: Plan) async throws
}

final class PlansListViewController: UIViewController {
    // MARK: - Properties
    private let viewModel: PlansListViewModel
    private weak var coordinator: PlansWriteFlowCoordinator?
    private var subscriptions = Set<AnyCancellable>()
    
    private let plansListView = PlansListView()
    
    private var planTableView: UITableView = {
        let tableView = UITableView()
        tableView.register(PlanCell.self,
                           forCellReuseIdentifier: PlanCell.identifier)
        tableView.backgroundColor = .systemBackground
        tableView.layer.cornerRadius = LayoutConstants.cornerRadius
        tableView.layer.borderWidth = AppLayoutConstants.borderWidth
        tableView.layer.borderColor = UIColor.white.cgColor
        tableView.isScrollEnabled = false
        return tableView
    }()
    
    // MARK: - Init
    init(viewModel: PlansListViewModel, coordinator: PlansWriteFlowCoordinator) {
        self.viewModel = viewModel
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        configureDelegate()
        configureAction()
        bind()
        fetchPlans()
    }
    
    // MARK: - Private
    private func fetchPlans() {
        Task {
            startIndicator()
            do {
                try await viewModel.read()
            } catch {
                if let error = error as? PlansRepositoryError {
                    alertWillAppear(error.rawValue)
                }
            }
            dismissIndicator()
        }
    }
    
    private func bind() {
        viewModel.plans
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in self?.reload() }
            .store(in: &subscriptions)
    }
}

// MARK: - Configure view
private extension PlansListViewController {
    func configureView() {
        view.backgroundColor = .systemBackground
        configureHierarchy()
        configureLayoutConstraint()
    }
    
    func configureHierarchy() {
        [plansListView, planTableView].forEach {
            view.addSubview($0)
        }
    }
    
    func configureLayoutConstraint() {
        plansListView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            $0.leading.trailing.equalToSuperview()
                .inset(AppLayoutConstants.spacing)
            $0.height.equalTo(LayoutConstants.planViewHeight)
        }
        
        planTableView.snp.makeConstraints {
            $0.top.equalTo(plansListView.snp.bottom)
                .offset(LayoutConstants.planTableViewTopOffset)
            $0.leading.trailing.equalToSuperview()
                .inset(AppLayoutConstants.spacing)
            $0.height.equalTo(viewModel.plans.value.count * Int(LayoutConstants.cellHeight))
        }
    }
    
    func configureDelegate() {
        planTableView.delegate = self
        planTableView.dataSource = self
    }
    
    func configureAction() {
        plansListView.editPlanButton.addTarget(self, action: #selector(touchUpEditButton), for: .touchUpInside)
        plansListView.createPlanButton.addTarget(self, action: #selector(touchUpCreateButton), for: .touchUpInside)
    }
}

// MARK: - User Interaction
private extension PlansListViewController {
    @MainActor func reload() {
        updateTableViewConstraints()
        planTableView.reloadData()
    }
    
    @MainActor func updateTableViewConstraints() {
        planTableView.snp.updateConstraints {
            $0.height.equalTo(viewModel.plans.value.count * Int(LayoutConstants.cellHeight))
        }
    }
    
    @objc func touchUpEditButton() {
        UIView.animate(withDuration: 0.2, delay: 0, animations: { [self] in
            planTableView.isEditing.toggle()
        }, completion: { [self] _ in
            plansListView.editPlanButton.isEditingAtTintColor = planTableView.isEditing
        })
    }
    
    @objc func touchUpCreateButton() {
        guard let coordinator = coordinator else { return }
        coordinator.toWritePlan(
            .init(
                plan: Plan(title: "", description: "", schedules: []),
                coordinator: coordinator,
                writingStyle: .create,
                delegate: self,
                plansListIndex: nil,
                coordinates: []
            )
        )
    }
    
    func didSelectRow(_ index: Int) {
        guard let coordinator = coordinator else { return }
        coordinator.toWritePlan(
            .init(
                plan: viewModel.plans.value[index],
                coordinator: coordinator,
                writingStyle: .update,
                delegate: self,
                plansListIndex: index,
                coordinates: viewModel.getCoordinates(at: index)
            )
        )
    }
}

// MARK: - UITableViewDataSource
extension PlansListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: PlanCell.identifier, for: indexPath) as? PlanCell else { return UITableViewCell() }
        
        cell.titleLabel.text = viewModel.plans.value[indexPath.row].title
        cell.dateLabel.text = viewModel.getDateString(at: indexPath.row)
        cell.descriptionLabel.text = viewModel.plans.value[indexPath.row].description
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.plans.value.count
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            guard let deletedCell = tableView.cellForRow(at: indexPath) as? PlanCell else { return }
            
            tableView.isUserInteractionEnabled = false
            deletedCell.createIndicator()
            deletedCell.startIndicator()
            
            Task {
                do {
                    try await viewModel.delete(at: indexPath.row)
                    
                    DispatchQueue.main.async {
                        self.updateTableViewConstraints()
                    }
                } catch {
                    guard let error = error as? PlansRepositoryError else { return }
                    alertWillAppear(error.rawValue)
                }
                deletedCell.stopAndDeallocateIndicator()
                tableView.isUserInteractionEnabled = true
            }
        }
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        guard let sourceCell = tableView.cellForRow(at: sourceIndexPath) as? PlanCell else { return }
        guard let destinationCell = tableView.cellForRow(at: destinationIndexPath) as? PlanCell else { return }
        
        tableView.isUserInteractionEnabled = false
        sourceCell.createIndicator()
        destinationCell.createIndicator()
        sourceCell.startIndicator()
        destinationCell.startIndicator()
        
        Task {
            do {
                try await viewModel.swapPlans(at: sourceIndexPath.row, to: destinationIndexPath.row)
            } catch {
                guard let error = error as? PlansRepositoryError else { return }
                alertWillAppear(error.rawValue)
            }
            sourceCell.stopAndDeallocateIndicator()
            destinationCell.stopAndDeallocateIndicator()
            tableView.isUserInteractionEnabled = true
        }
    }
}

// MARK: - UITableViewDelegate
extension PlansListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        .delete
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        LayoutConstants.cellHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        didSelectRow(indexPath.row)
    }
}

// MARK: - PlanTransferDelegate
extension PlansListViewController: PlanTransferDelegate {
    func create(_ plan: Plan) async throws {
        startIndicator()
        do {
            try await viewModel.create(plan)
        } catch {
            guard let error = error as? PlansRepositoryError else { return }
            alertWillAppear(error.rawValue)
        }
        dismissIndicator()
    }
    
    func update(at index: Int, _ plan: Plan) async throws {
        startIndicator()
        do {
            try await viewModel.update(at: index, plan)
        } catch {
            guard let error = error as? PlansRepositoryError else { return }
            alertWillAppear(error.rawValue)
        }
        dismissIndicator()
    }
}

// MARK: - Indicator
private extension PlansListViewController {
    func startIndicator() {
        planTableView.isUserInteractionEnabled = false
        DispatchQueue.main.async { [self] in
            plansListView.indicatorView.show(in: view)
        }
    }
    
    func dismissIndicator() {
        DispatchQueue.main.async { [self] in
            plansListView.indicatorView.dismiss(animated: true)
        }
        planTableView.isUserInteractionEnabled = true
    }
}

// MARK: - Magic number
private extension PlansListViewController {
    @frozen enum LayoutConstants {
        static let planViewHeight: CGFloat = 50
        static let cornerRadius: CGFloat = 10
        static let planTableViewTopOffset: CGFloat = 20
        static let cellHeight: CGFloat = 100
    }
}
