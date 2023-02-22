//
//  TravelPlanViewController.swift
//  YeolmokTravel
//
//  Created by 김동욱 on 2022/12/20.
//

import UIKit
import SnapKit
import Combine
import FirebasePlatform

protocol TravelPlanTransferDelegate: AnyObject {
    func create(_ travelPlan: YTTravelPlan) async throws
    func update(at index: Int, _ travelPlan: YTTravelPlan) async throws
}

/// Plans tab
final class TravelPlanViewController: UIViewController {
    // MARK: - Properties
    private let viewModel: ConcreteTravelPlanViewModel
    private var subscriptions = Set<AnyCancellable>()
    
    private let travelPlanView = TravelPlanView()
    
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
    
    init(_ viewModel: ConcreteTravelPlanViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        startIndicator()
        configureView()
        configureDelegate()
        configureAction()
        setBindings()
        fetchPlans()
    }
}

// MARK: - Configure View
private extension TravelPlanViewController {
    func configureView() {
        view.backgroundColor = .systemBackground
        configureHierarchy()
        configureLayoutConstraint()
    }
    
    func configureHierarchy() {
        [travelPlanView, planTableView].forEach {
            view.addSubview($0)
        }
    }
    
    func configureLayoutConstraint() {
        travelPlanView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            $0.leading.trailing.equalToSuperview()
                .inset(AppLayoutConstants.spacing)
            $0.height.equalTo(LayoutConstants.travelPlanViewHeight)
        }
        
        planTableView.snp.makeConstraints {
            $0.top.equalTo(travelPlanView.snp.bottom)
                .offset(LayoutConstants.planTableViewTopOffset)
            $0.leading.trailing.equalToSuperview()
                .inset(AppLayoutConstants.spacing)
            $0.height.equalTo(viewModel.model.value.count * Int(LayoutConstants.cellHeight))
        }
    }
    
    func configureDelegate() {
        planTableView.delegate = self
        planTableView.dataSource = self
    }
    
    func configureAction() {
        travelPlanView.updateTravelPlanButton.addTarget(self, action: #selector(touchUpEditButton), for: .touchUpInside)
        travelPlanView.createTravelPlanButton.addTarget(self, action: #selector(touchUpAddButton), for: .touchUpInside)
    }
}

// MARK: - User Interaction
private extension TravelPlanViewController {
    @MainActor func reload() {
        updateTableViewConstraints()
        planTableView.reloadData()
    }
    
    @MainActor func updateTableViewConstraints() {
        planTableView.snp.updateConstraints {
            $0.height.equalTo(viewModel.model.value.count * Int(LayoutConstants.cellHeight))
        }
    }
    
    @objc func touchUpEditButton() {
        UIView.animate(withDuration: 0.2, delay: 0, animations: { [self] in
            planTableView.isEditing.toggle()
        }, completion: { [self] _ in
            travelPlanView.updateTravelPlanButton.isEditingAtTintColor = planTableView.isEditing
        })
    }
    
    func setBindings() {
        viewModel.model
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in self?.reload() }
            .store(in: &subscriptions)
    }
    
    @objc func touchUpAddButton() {
        let model = YTTravelPlan(title: "", description: "", schedules: [])
        let factory = WritingTravelPlanViewControllerFactory()
        let writingTravelPlanViewController = factory.makeWritingTravelPlanViewController(
            with: model,
            writingStyle: .create,
            delegate: self,
            travelPlanListIndex: nil
        )
        navigationController?.pushViewController(writingTravelPlanViewController, animated: true)
    }
    
    func didSelectRow(_ index: Int) {
        let model = viewModel.model.value[index]
        let factory = WritingTravelPlanViewControllerFactory()
        let writingTravelPlanViewController = factory.makeWritingTravelPlanViewController(
            with: model,
            writingStyle: .update,
            delegate: self,
            travelPlanListIndex: index
        )
        navigationController?.pushViewController(writingTravelPlanViewController, animated: true)
    }
}

// MARK: - TableView
extension TravelPlanViewController: UITableViewDataSource {
    private func fetchPlans() {
        Task {
            do {
                try await viewModel.read()
            } catch {
                if let error = error as? TravelPlanRepositoryError {
                    alertWillAppear(error.rawValue)
                }
            }
            dismissIndicator()
        }
    }
    
    // DataSource
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: PlanCell.identifier, for: indexPath) as? PlanCell else { return UITableViewCell() }
        
        cell.titleLabel.text = viewModel.model.value[indexPath.row].title
        cell.dateLabel.text = viewModel.model.value[indexPath.row].date
        cell.descriptionLabel.text = viewModel.model.value[indexPath.row].description
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.model.value.count
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            guard let deletedCell = tableView.cellForRow(at: indexPath) as? PlanCell else { return }
            
            tableView.isUserInteractionEnabled = false
            deletedCell.createIndicator()
            deletedCell.startIndicator()
            
            Task {
                do {
                    try await viewModel.delete(indexPath.row)
                    
                    DispatchQueue.main.async {
                        self.updateTableViewConstraints()
                    }
                } catch {
                    guard let error = error as? TravelPlanRepositoryError else { return }
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
                try await viewModel.swapTravelPlans(at: sourceIndexPath.row, to: destinationIndexPath.row)
            } catch {
                guard let error = error as? TravelPlanRepositoryError else { return }
                alertWillAppear(error.rawValue)
            }
            sourceCell.stopAndDeallocateIndicator()
            destinationCell.stopAndDeallocateIndicator()
            tableView.isUserInteractionEnabled = true
        }
    }
}

extension TravelPlanViewController: UITableViewDelegate {
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

extension TravelPlanViewController: TravelPlanTransferDelegate {
    func create(_ travelPlan: YTTravelPlan) async throws {
        startIndicator()
        do {
            try await viewModel.create(travelPlan)
        } catch {
            guard let error = error as? TravelPlanRepositoryError else { return }
            alertWillAppear(error.rawValue)
        }
        dismissIndicator()
    }
    
    func update(at index: Int, _ travelPlan: YTTravelPlan) async throws {
        startIndicator()
        do {
            try await viewModel.update(at: index, travelPlan)
        } catch {
            guard let error = error as? TravelPlanRepositoryError else { return }
            alertWillAppear(error.rawValue)
        }
        dismissIndicator()
    }
}

// MARK: - Indicator
private extension TravelPlanViewController {
    func startIndicator() {
        planTableView.isUserInteractionEnabled = false
        DispatchQueue.main.async { [self] in
            travelPlanView.indicatorView.show(in: view)
        }
    }
    
    func dismissIndicator() {
        DispatchQueue.main.async { [self] in
            travelPlanView.indicatorView.dismiss(animated: true)
        }
        planTableView.isUserInteractionEnabled = true
    }
}

private enum LayoutConstants {
    static let travelPlanViewHeight: CGFloat = 50
    static let cornerRadius: CGFloat = 10
    static let planTableViewTopOffset: CGFloat = 20
    static let cellHeight: CGFloat = 100
}
