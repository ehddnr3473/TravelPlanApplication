//
//  WritingPlanViewController.swift
//  YeolmokTravel
//
//  Created by 김동욱 on 2022/12/20.
//

import UIKit
import SnapKit

final class WritingPlanViewController: UIViewController, Writable {
    // MARK: - Properties
    var writingStyle: WritingStyle!
    var model: WritablePlan!
    var addDelegate: PlanTransfer?
    var editDelegate: PlanTransfer?
    var planListIndex: Int?
    
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
    
    private let barTitleLabel: UILabel = {
        let label = UILabel()
        
        label.textAlignment = .center
        label.font = .boldSystemFont(ofSize: LayoutConstants.mediumFontSize)
        label.textColor = .white
        
        return label
    }()
    
    private lazy var saveBarButton: UIButton = {
        let button = UIButton(type: .custom)
        
        button.setTitle(TextConstants.saveButtonTitle, for: .normal)
        button.addTarget(self, action: #selector(touchUpSaveBarButton), for: .touchUpInside)
        
        return button
    }()
    
    private lazy var cancelBarButton: UIButton = {
        let button = UIButton(type: .custom)
        
        button.setTitle(TextConstants.cancelButtonTItle, for: .normal)
        button.addTarget(self, action: #selector(touchUpCancelBarButton), for: .touchUpInside)
        
        return button
    }()
    
    var titleTextField: UITextField = {
        let textField = UITextField()
        
        textField.textColor = .white
        textField.backgroundColor = .black
        textField.placeholder = TextConstants.placeholder
        textField.layer.cornerRadius = LayoutConstants.cornerRadius
        textField.layer.borderWidth = LayoutConstants.borderWidth
        textField.layer.borderColor = UIColor.white.cgColor
        textField.font = .boldSystemFont(ofSize: LayoutConstants.largeFontSize)
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none
        
        textField.leftView = UIView(frame: CGRect(x: .zero,
                                                  y: .zero,
                                                  width: LayoutConstants.spacing,
                                                  height: .zero))
        textField.leftViewMode = .always
        
        return textField
    }()
    
    var descriptionTextView: UITextView = {
        let textView = UITextView()
        
        textView.textColor = .white
        textView.backgroundColor = .black
        textView.layer.cornerRadius = LayoutConstants.cornerRadius
        textView.layer.borderWidth = LayoutConstants.borderWidth
        textView.layer.borderColor = UIColor.white.cgColor
        textView.font = .boldSystemFont(ofSize: LayoutConstants.mediumFontSize)
        
        return textView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setUpUI()
    }
}

// MARK: - SetUp View
extension WritingPlanViewController {
    private func setUpUI() {
        view.backgroundColor = .black
        
        switch writingStyle {
        case .add:
            barTitleLabel.text = "\(writingStyle.rawValue) \(TextConstants.plan)"
        case .edit:
            barTitleLabel.text = "\(writingStyle.rawValue) \(TextConstants.plan)"
        case .none:
            break
        }
        
        titleTextField.text = model.title
        descriptionTextView.text = model.description
        
        setUpHierachy()
        setUpLayout()
    }
    private func setUpHierachy() {
        [cancelBarButton, barTitleLabel, saveBarButton].forEach {
            topBarStackView.addArrangedSubview($0)
        }
        
        [topBarStackView, titleTextField, descriptionTextView].forEach {
            view.addSubview($0)
        }
    }
    
    private func setUpLayout() {
        topBarStackView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            $0.width.equalToSuperview()
            $0.height.greaterThanOrEqualTo(LayoutConstants.stackViewHeight)
        }
        
        titleTextField.snp.makeConstraints {
            $0.top.equalTo(topBarStackView.snp.bottom).offset(LayoutConstants.spacing)
            $0.leading.trailing.equalToSuperview()
                .inset(LayoutConstants.spacing)
        }
        
        descriptionTextView.snp.makeConstraints {
            $0.top.equalTo(titleTextField.snp.bottom)
                .offset(LayoutConstants.spacing)
            $0.leading.trailing.equalToSuperview()
                .inset(LayoutConstants.spacing)
            $0.height.equalTo(100)
        }
    }
    
    @objc func touchUpSaveBarButton() {
        model.setPlan(titleTextField.text ?? "", descriptionTextView.text)
        if model.verifyTitleText() {
            alertWillAppear()
            return
        } else {
            switch writingStyle {
            case .add:
                addDelegate?.writingHandler(model.plan, nil)
                addDelegate = nil
                dismiss(animated: true)
            case .edit:
                if let index = planListIndex {
                    editDelegate?.writingHandler(model.plan, index)
                    editDelegate = nil
                    dismiss(animated: true)
                }
            case .none:
                dismiss(animated: true)
            }
        }
    }
    
    @objc func touchUpCancelBarButton() {
        model.setPlan(titleTextField.text ?? "", descriptionTextView.text)
        if model.isChanged {
            switch writingStyle {
            case .add:
                actionSheetWillApear(AlertText.addTitle, AlertText.message)
            case .edit:
                actionSheetWillApear(AlertText.editTitle, AlertText.message)
            case .none:
                dismiss(animated: true)
            }
        } else {
            dismiss(animated: true)
        }
    }
}
private enum LayoutConstants {
    static let spacing: CGFloat = 8
    static let stackViewCornerRadius: CGFloat = 10
    static let cornerRadius: CGFloat = 5
    static let borderWidth: CGFloat = 1
    static let largeFontSize: CGFloat = 25
    static let mediumFontSize: CGFloat = 20
    static let topBottomMargin: CGFloat = 10
    static let sideMargin: CGFloat = 15
    static let stackViewHeight: CGFloat = 50
}

private enum TextConstants {
    static let saveButtonTitle = "Save"
    static let cancelButtonTItle = "Cancel"
    static let plan = "Plan"
    static let placeholder = "제목"
    static let descriptionPlaceolder = "상세"
}

private enum AlertText {
    static let addTitle = "입력한 내용이 있습니다."
    static let editTitle = "변경된 내용이 있습니다."
    static let message = "저장하지 않고 돌아가시겠습니까?"
}
