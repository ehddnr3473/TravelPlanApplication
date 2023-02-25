//
//  WritingPlanViewControllerFactory.swift
//  YeolmokTravel
//
//  Created by 김동욱 on 2023/02/21.
//

import Foundation
import CoreLocation
import Domain

final class WritingPlanViewControllerFactory {
    func makeWritingTravelPlanViewController(with plan: Plan,
                                               writingStyle: WritingStyle,
                                               delegate: PlanTransferDelegate,
                                               plansListIndex: Int?) -> WritingPlanViewController {
        let writingTravelPlanView = WritingPlanViewController(
            viewModel: DefaultWritingPlanViewModel(plan),
            mapProvider: MapViewController(getCoordinates(plan)),
            writingStyle: writingStyle,
            delegate: delegate,
            plansListIndex: plansListIndex
        )
        writingTravelPlanView.hidesBottomBarWhenPushed = true
        return writingTravelPlanView
    }
    
    private func getCoordinates(_ plan: Plan) -> [CLLocationCoordinate2D] {
        var coordinates = [CLLocationCoordinate2D]()
        for schedule in plan.schedules {
            coordinates.append(schedule.coordinate)
        }
        return coordinates
    }
}
