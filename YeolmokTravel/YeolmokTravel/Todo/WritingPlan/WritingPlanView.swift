//
//  WritingPlanView.swift
//  YeolmokTravel
//
//  Created by 김동욱 on 2022/12/20.
//

import UIKit

class WritingPlanView: UIViewController, Writable {
    // MARK: - Properties
    var writingStyle: WritingStyle!

    private let topBarStackView: UIStackView = {
        let stackView = UIStackView()
        
        stackView.axis = .horizontal
        stackView.distribution = .equalCentering
        stackView.backgroundColor = .darkGray
        stackView.layer.cornerRadius = LayoutConstants.stackViewCornerRadius
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = UIEdgeInsets(top: LayoutConstants.topBottomMargin,
                                               left: LayoutConstants.sideMargin,
                                               bottom: LayoutConstants.topBottomMargin,
                                               right: LayoutConstants.sideMargin)
        stackView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        return stackView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        
        label.textAlignment = .center
        label.font = .boldSystemFont(ofSize: LayoutConstants.barTitleFontSize)
        label.textColor = .white
        
        return label
    }()
    
    private lazy var saveBarButton: UIButton = {
        let button = UIButton(type: .custom)
        
        button.setTitle(StringConstants.saveButtonTitle, for: .normal)
        button.addTarget(self, action: #selector(touchUpSaveBarButton), for: .touchUpInside)
        
        return button
    }()
    
    private lazy var cancelBarButton: UIButton = {
        let button = UIButton(type: .custom)
        
        button.setTitle(StringConstants.cancelButtonTItle, for: .normal)
        button.addTarget(self, action: #selector(touchUpCancelBarButton), for: .touchUpInside)
        
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setUpUI()
    }
}

// MARK: - SetUp View
extension WritingPlanView {
    private func setUpUI() {
        setUpHierachy()
        setUpLayout()
    }
    private func setUpHierachy() {
        [cancelBarButton, titleLabel, saveBarButton].forEach {
            topBarStackView.addArrangedSubview($0)
        }
        
        [topBarStackView].forEach {
            view.addSubview($0)
        }
    }
    
    private func setUpLayout() {
        topBarStackView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            $0.width.equalToSuperview()
            $0.height.greaterThanOrEqualTo(LayoutConstants.stackViewHeight)
        }
    }
    
    @objc func touchUpSaveBarButton() {
        
    }
    
    @objc func touchUpCancelBarButton() {
        
    }
}
private enum LayoutConstants {
    static let spacing: CGFloat = 8
    static let stackViewCornerRadius: CGFloat = 10
    static let barTitleFontSize: CGFloat = 20
    static let topBottomMargin: CGFloat = 10
    static let sideMargin: CGFloat = 15
    static let stackViewHeight: CGFloat = 50
}

private enum StringConstants {
    static let saveButtonTitle = "Save"
    static let cancelButtonTItle = "Cancel"
    static let placeholder = "제목"
    static let plan = "Plan"
}

private enum AlertText {
    static let addTitle = "입력한 내용이 있습니다."
    static let editTitle = "변경된 내용이 있습니다."
    static let message = "저장하지 않고 돌아가시겠습니까?"
}
