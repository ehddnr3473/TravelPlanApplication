//
//  PlansListView.swift
//  YeolmokTravel
//
//  Created by 김동욱 on 2023/02/22.
//

import UIKit

import JGProgressHUD

final class PlansListView: UIView {
    // MARK: - Magic number/string
    @frozen private enum LayoutConstants {
        static let cornerRadius: CGFloat = 10
        static let buttonSize = CGSize(width: 44.44, height: 44.44)
    }
    
    @frozen private enum TextConstants {
        static let title = "Plans"
    }
    
    @frozen private enum IndicatorConstants {
        static let titleText = "Loading.."
        static let detailText = "Please wait"
    }
    
    // MARK: - Properties
    private var titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = AppStyles.getAccentColor()
        label.text = TextConstants.title
        label.font = .boldSystemFont(ofSize: AppLayoutConstants.titleFontSize)
        return label
    }()
    
    let createPlanButton: UIButton = {
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
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}

// MARK: - Configure view
private extension PlansListView {
    func configureView() {
        configureHierarchy()
        configureLayoutConstraint()
    }
    
    func configureHierarchy() {
        [titleLabel, createPlanButton].forEach {
            addSubview($0)
        }
    }
    
    func configureLayoutConstraint() {
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide.snp.top)
            $0.leading.equalToSuperview()
        }
        
        createPlanButton.snp.makeConstraints {
            $0.centerY.equalTo(titleLabel.snp.centerY)
            $0.trailing.equalToSuperview()
            $0.size.equalTo(LayoutConstants.buttonSize)
        }
    }
}
