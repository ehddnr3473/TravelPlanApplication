//
//  PlanViewBuilder.swift
//  YeolmokTravel
//
//  Created by 김동욱 on 2023/01/24.
//

import Foundation
import Domain

protocol PlansListViewBuilder {
    func build() -> PlansListViewController
}

struct DefaultPlansListViewBuilder: PlansListViewBuilder {
    private let useCaseProvider: PlansUseCaseProvider
    
    init(_ plansUseCaseProvider: PlansUseCaseProvider) {
        self.useCaseProvider = plansUseCaseProvider
    }
    
    private func createViewModel() -> DefaultPlansListViewModel {
        DefaultPlansListViewModel(useCaseProvider)
    }
    
    func build() -> PlansListViewController {
        let viewModel = createViewModel()
        return PlansListViewController(viewModel: viewModel)
    }
}
