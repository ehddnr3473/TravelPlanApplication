//
//  PlansSceneDIContainer.swift
//  YeolmokTravel
//
//  Created by 김동욱 on 2023/02/24.
//

import Foundation
import Domain
import FirebasePlatform

final class PlansSceneDIContainer {
    // MARK: - Use Case Provider
    func makeTravelPlanUseCaseProvider() -> PlansUseCaseProvider {
        DefaultPlansUseCaseProvider(repository: makeTravelPlanRepository())
    }
    
    // MARK: - Repositories
    func makeTravelPlanRepository() -> PlansRepository {
        DefaultPlansRepository()
    }
    
    // MARK: - Plans List
    func makePlansListViewController() -> PlansListViewController {
        PlansListViewController(viewModel: makePlansListViewModel())
    }
    
    func makePlansListViewModel() -> PlansListViewModel {
        DefaultPlansListViewModel(makeTravelPlanUseCaseProvider())
    }
    
    // MARK: - Writing Plan
    
    // MARK: - Writing Schedule
}
