//
//  TravelPlanViewController.swift
//  YeolmokTravel
//
//  Created by 김동욱 on 2022/12/20.
//

import UIKit
import SnapKit
import Combine
import JGProgressHUD

protocol TravelPlanTransferDelegate: AnyObject {
    func create(_ travelPlan: TravelPlan) async throws
    func update(at index: Int, _ travelPlan: TravelPlan) async throws
}

/// Plans tab
final class TravelPlanViewController: UIViewController {
    // MARK: - Properties
    private let viewModel: ConcreteTravelPlanViewModel
    private var subscriptions = Set<AnyCancellable>()
    
    private var titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .white
        label.text = TextConstants.title
        label.font = .boldSystemFont(ofSize: AppLayoutConstants.titleFontSize)
        return label
    }()
    
    private lazy var editTravelPlanButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setBackgroundImage(UIImage(systemName: AppTextConstants.editIcon), for: .normal)
        button.tintColor = AppStyles.mainColor
        button.addTarget(self, action: #selector(touchUpEditButton), for: .touchUpInside)
        return button
    }()
    
    private lazy var addTravelPlanButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setBackgroundImage(UIImage(systemName: AppTextConstants.plusIcon), for: .normal)
        button.tintColor = AppStyles.mainColor
        button.addTarget(self, action: #selector(touchUpAddButton), for: .touchUpInside)
        return button
    }()
    
    private var planTableView: UITableView = {
        let tableView = UITableView()
        tableView.register(TravelPlanTableViewCell.self,
                           forCellReuseIdentifier: TravelPlanTableViewCell.identifier)
        tableView.backgroundColor = .systemBackground
        tableView.layer.cornerRadius = LayoutConstants.cornerRadius
        tableView.layer.borderWidth = AppLayoutConstants.borderWidth
        tableView.layer.borderColor = UIColor.white.cgColor
        tableView.isScrollEnabled = false
        return tableView
    }()
    
    private var indicatorView: JGProgressHUD? = {
        let headUpDisplay = JGProgressHUD()
        headUpDisplay.textLabel.text = IndicatorConstants.titleText
        headUpDisplay.detailTextLabel.text = IndicatorConstants.detailText
        return headUpDisplay
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
        
        Task {
            do {
                try await viewModel.read()
            } catch {
                if let error = error as? TravelPlanRepositoryError {
                    alertWillAppear(error.rawValue)
                }
            }
        }
        
        configureView()
        configure()
        setBindings()
        dismissIndicator()
        deallocate()
    }
}

// MARK: - Configure View
private extension TravelPlanViewController {
    private func configureView() {
        view.backgroundColor = .systemBackground
        configureHierarchy()
        configureLayoutConstraint()
    }
    
    func configureHierarchy() {
        [titleLabel, editTravelPlanButton, addTravelPlanButton, planTableView].forEach {
            view.addSubview($0)
        }
    }
    
    func configureLayoutConstraint() {
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            $0.leading.equalToSuperview()
                .inset(AppLayoutConstants.spacing)
        }
        
        addTravelPlanButton.snp.makeConstraints {
            $0.centerY.equalTo(titleLabel.snp.centerY)
            $0.trailing.equalToSuperview()
                .inset(AppLayoutConstants.spacing)
            $0.size.equalTo(LayoutConstants.buttonSize)
        }
        
        editTravelPlanButton.snp.makeConstraints {
            $0.centerY.equalTo(titleLabel.snp.centerY)
            $0.trailing.equalTo(addTravelPlanButton.snp.leading)
                .offset(-AppLayoutConstants.spacing)
            $0.size.equalTo(LayoutConstants.buttonSize)
        }
        
        planTableView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom)
                .offset(LayoutConstants.planTableViewTopOffset)
            $0.leading.trailing.equalToSuperview()
                .inset(AppLayoutConstants.spacing)
            $0.height.equalTo(viewModel.model.value.count * Int(LayoutConstants.cellHeight))
        }
    }
    
    func configure() {
        planTableView.delegate = self
        planTableView.dataSource = self
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
            editTravelPlanButton.isEditingAtTintColor = planTableView.isEditing
        })
    }
    
    func setBindings() {
        viewModel.model
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in self?.reload() }
            .store(in: &subscriptions)
    }
    
    @objc func touchUpAddButton() {
        let model = TravelPlan(title: "", description: "", schedules: [])
        let coordinates = model.coordinates
        let mapViewController = MapViewController(coordinates)
        let writingView = WritingTravelPlanViewController(
            viewModel: ConcreteWritingTravelPlanViewModel(model),
            mapProvider: mapViewController,
            writingStyle: .create,
            delegate: self
        )
        writingView.delegate = self
        writingView.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(writingView, animated: true)
    }
    
    func didSelectRow(_ index: Int) {
        let model = viewModel.model.value[index]
        let coordinates = model.coordinates
        let mapViewController = MapViewController(coordinates)
        let writingView = WritingTravelPlanViewController(
            viewModel: ConcreteWritingTravelPlanViewModel(model),
            mapProvider: mapViewController,
            writingStyle: .update,
            delegate: self
        )
        writingView.delegate = self
        writingView.planListIndex = index
        writingView.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(writingView, animated: true)
    }
}

// MARK: - TableView
extension TravelPlanViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TravelPlanTableViewCell.identifier, for: indexPath) as? TravelPlanTableViewCell else { return UITableViewCell() }
        
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
            Task {
                do {
                    try await viewModel.delete(indexPath.row)
                } catch {
                    guard let error = error as? TravelPlanRepositoryError else { return }
                    alertWillAppear(error.rawValue)
                }
            }
            tableView.deleteRows(at: [indexPath], with: .automatic)
            updateTableViewConstraints()
        }
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        .delete
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        Task {
            do {
                try await viewModel.swapTravelPlans(at: sourceIndexPath.row, to: destinationIndexPath.row)
            } catch {
                guard let error = error as? TravelPlanRepositoryError else { return }
                alertWillAppear(error.rawValue)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        LayoutConstants.cellHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        didSelectRow(indexPath.row)
    }
}

extension TravelPlanViewController: TravelPlanTransferDelegate {
    func create(_ travelPlan: TravelPlan) async throws {
        do {
            try await viewModel.create(travelPlan)
        } catch {
            guard let error = error as? TravelPlanRepositoryError else { return }
            alertWillAppear(error.rawValue)
        }
    }
    
    func update(at index: Int, _ travelPlan: TravelPlan) async throws {
        do {
            try await viewModel.update(at: index, travelPlan)
        } catch {
            guard let error = error as? TravelPlanRepositoryError else { return }
            alertWillAppear(error.rawValue)
        }
    }
}

// MARK: - Indicator
private extension TravelPlanViewController {
    func startIndicator() {
        guard let indicatorView = indicatorView else { return }
        indicatorView.show(in: view)
    }
    
    func dismissIndicator() {
        guard let indicatorView = indicatorView else { return }
        indicatorView.dismiss(afterDelay: IndicatorConstants.delay)
    }
    
    func deallocate() {
        indicatorView = nil
    }
}

private enum TextConstants {
    static let title = "Plans"
}

private enum LayoutConstants {
    static let buttonSize = CGSize(width: 44.44, height: 44.44)
    static let planTableViewTopOffset: CGFloat = 20
    static let cornerRadius: CGFloat = 10
    static let cellHeight: CGFloat = 100
}

private enum IndicatorConstants {
    static let titleText = "Loading.."
    static let detailText = "Please wait"
    static let delay: TimeInterval = 1
}
