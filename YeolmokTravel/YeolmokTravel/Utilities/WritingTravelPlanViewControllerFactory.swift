//
//  WritingTravelPlanViewControllerFactory.swift
//  YeolmokTravel
//
//  Created by 김동욱 on 2023/02/21.
//

import Foundation

final class WritingTravelPlanViewControllerFactory {
    func makeWritingTravelPlanViewController(with model: YTTravelPlan,
                                               writingStyle: WritingStyle,
                                               delegate: TravelPlanTransferDelegate,
                                               travelPlanListIndex: Int?) -> WritingTravelPlanViewController {
        let writingTravelPlanView = WritingTravelPlanViewController(
            viewModel: ConcreteWritingTravelPlanViewModel(model),
            mapProvider: MapViewController(model.coordinates),
            writingStyle: writingStyle,
            delegate: delegate,
            travelPlanListIndex: travelPlanListIndex
        )
        writingTravelPlanView.hidesBottomBarWhenPushed = true
        return writingTravelPlanView
    }
}
