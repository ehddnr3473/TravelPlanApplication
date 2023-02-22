//
//  TravelPlanView.swift
//  YeolmokTravel
//
//  Created by 김동욱 on 2023/02/22.
//

import Foundation
import UIKit
import JGProgressHUD

final class TravelPlanView: UIView {
    enum TextConstants {
        static let title = "Plans"
    }
    
    enum LayoutConstants {
        static let cornerRadius: CGFloat = 10
        static let buttonSize = CGSize(width: 44.44, height: 44.44)
    }
    
    enum IndicatorConstants {
        static let titleText = "Loading.."
        static let detailText = "Please wait"
    }
    
    // MARK: - Properties
    private var titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .white
        label.text = TextConstants.title
        label.font = .boldSystemFont(ofSize: AppLayoutConstants.titleFontSize)
        return label
    }()
    
    let editTravelPlanButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setBackgroundImage(UIImage(systemName: AppTextConstants.editIcon), for: .normal)
        button.tintColor = AppStyles.mainColor
        return button
    }()
    
    let addTravelPlanButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setBackgroundImage(UIImage(systemName: AppTextConstants.plusIcon), for: .normal)
        button.tintColor = AppStyles.mainColor
        return button
    }()
    
    let indicatorView: JGProgressHUD = {
        let headUpDisplay = JGProgressHUD()
        headUpDisplay.textLabel.text = IndicatorConstants.titleText
        headUpDisplay.detailTextLabel.text = IndicatorConstants.detailText
        return headUpDisplay
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}

private extension TravelPlanView {
    func configureView() {
        configureHierarchy()
        configureLayoutConstraint()
    }
    
    func configureHierarchy() {
        [titleLabel, editTravelPlanButton, addTravelPlanButton].forEach {
            addSubview($0)
        }
    }
    
    func configureLayoutConstraint() {
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide.snp.top)
            $0.leading.equalToSuperview()
        }
        
        addTravelPlanButton.snp.makeConstraints {
            $0.centerY.equalTo(titleLabel.snp.centerY)
            $0.trailing.equalToSuperview()
            $0.size.equalTo(LayoutConstants.buttonSize)
        }
        
        editTravelPlanButton.snp.makeConstraints {
            $0.centerY.equalTo(titleLabel.snp.centerY)
            $0.trailing.equalTo(addTravelPlanButton.snp.leading)
                .offset(-AppLayoutConstants.spacing)
            $0.size.equalTo(LayoutConstants.buttonSize)
        }
    }
}
