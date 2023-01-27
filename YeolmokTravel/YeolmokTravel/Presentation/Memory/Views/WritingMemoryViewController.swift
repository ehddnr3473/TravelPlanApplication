//
//  WritingMemoryViewController.swift
//  YeolmokTravel
//
//  Created by 김동욱 on 2022/12/24.
//

import UIKit
import PhotosUI
import Combine

final class WritingMemoryViewController: UIViewController {
    // MARK: - Properties
    var addDelegate: MemoryTransfer?
    var memoryIndex: Int!
    var viewModel: WritingMemoryViewModel!
    private let imageIsExist = CurrentValueSubject<Bool, Never>(false)
    private var subscriptions = Set<AnyCancellable>()
    
    deinit {
        print("deinit: WritingMemoryViewController")
    }
    
    private let topBarView: TopBarView = {
        let topBarView = TopBarView()
        return topBarView
    }()
    
    private let titleTextField: UITextField = {
        let textField = UITextField()
        textField.textColor = .white
        textField.backgroundColor = .black
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
    
    private let phPicker: PHPickerViewController = {
        var configuration = PHPickerConfiguration()
        configuration.filter = .images
        let phPicker = PHPickerViewController(configuration: configuration)
        return phPicker
    }()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.borderWidth = LayoutConstants.borderWidth
        imageView.layer.borderColor = UIColor.white.cgColor
        return imageView
    }()
    
    private lazy var addButton: UIButton = {
        let button = UIButton(type: .custom)
        button.addTarget(self, action: #selector(touchUpAddButton), for: .touchUpInside)
        button.setTitle(TextConstants.phPickerButtonTitle, for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.backgroundColor = AppStyles.mainColor
        button.layer.borderColor = UIColor.black.cgColor
        button.layer.borderWidth = LayoutConstants.borderWidth
        return button
    }()
    
    private lazy var deleteButton: UIButton = {
        let button = UIButton(type: .custom)
        button.addTarget(self, action: #selector(touchUpDeleteButton), for: .touchUpInside)
        button.setTitle(TextConstants.deleteButtonTitle, for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.backgroundColor = .systemGray
        button.layer.borderColor = UIColor.black.cgColor
        button.layer.borderWidth = LayoutConstants.borderWidth
        return button
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
        configure()
        setBindings()
    }
}

// MARK: - SetUp View
extension WritingMemoryViewController {
    private func setUpUI() {
        view.backgroundColor = .black
        setUpHierachy()
        setUpLayout()
    }
    
    private func setUpHierachy() {
        [topBarView, titleTextField, imageView, addButton, deleteButton].forEach {
            view.addSubview($0)
        }
    }
    
    private func setUpLayout() {
        topBarView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            $0.width.equalToSuperview()
            $0.height.greaterThanOrEqualTo(LayoutConstants.topBarViewHeight)
        }
        
        titleTextField.snp.makeConstraints {
            $0.top.equalTo(topBarView.snp.bottom)
                .offset(LayoutConstants.largeSpacing)
            $0.leading.trailing.equalToSuperview()
                .inset(LayoutConstants.spacing)
        }
        
        imageView.snp.makeConstraints {
            $0.top.equalTo(titleTextField.snp.bottom)
                .offset(LayoutConstants.largeSpacing)
            $0.centerX.equalToSuperview()
            $0.width.equalToSuperview()
                .multipliedBy(LayoutConstants.imageViewWidthMultiplier)
            $0.height.equalTo(imageView.snp.width)
        }
        
        deleteButton.snp.makeConstraints {
            $0.top.equalTo(imageView.snp.bottom)
                .offset(LayoutConstants.spacing)
            $0.width.equalTo(LayoutConstants.buttonWidth)
            $0.trailing.equalTo(view.snp.centerX)
                .offset(-LayoutConstants.spacing)
        }
        
        addButton.snp.makeConstraints {
            $0.top.equalTo(imageView.snp.bottom)
                .offset(LayoutConstants.spacing)
            $0.width.equalTo(LayoutConstants.buttonWidth)
            $0.leading.equalTo(view.snp.centerX)
                .offset(LayoutConstants.spacing)
        }
    }
    
    private func configure() {
        topBarView.barTitleLabel.text = TextConstants.title
        topBarView.saveBarButton.addTarget(self, action: #selector(touchUpSaveBarButton), for: .touchUpInside)
        topBarView.cancelBarButton.addTarget(self, action: #selector(touchUpCancelBarButton), for: .touchUpInside)
        phPicker.delegate = self
    }
    
    @objc func touchUpSaveBarButton() {
        if titleTextField.text == "" {
            alertWillAppear(AlertText.titleMessage)
            return
        } else if imageView.image == nil {
            alertWillAppear(AlertText.nilImageMessage)
            return
        } else if let addDelegate = addDelegate, let image = imageView.image, let index = memoryIndex {
            let memory = Memory(title: titleTextField.text ?? "", index: index, uploadDate: Date())
            addDelegate.writingHandler(memory)
            viewModel.upload(index, image, memory)
            dismiss(animated: true)
        }
    }
    
    @objc func touchUpCancelBarButton() {
        dismiss(animated: true)
    }
    
    @objc func touchUpAddButton() {
        present(phPicker, animated: true)
    }
    
    @objc func touchUpDeleteButton() {
        imageView.image = nil
        self.imageIsExist.value = false
    }
    
    private func setBindings() {
        let input = WritingMemoryViewModel.Input(
            title: titleTextField.textPublisher.eraseToAnyPublisher(),
            image: imageIsExist.eraseToAnyPublisher()
        )
        
        let output = viewModel.transform(input: input)
        
        output.buttonState
            .receive(on: RunLoop.main)
            .sink{ [weak self] state in
                self?.topBarView.saveBarButton.isEnabled = state
            }
            .store(in: &subscriptions)
    }
}

// MARK: - PHPicker
extension WritingMemoryViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        
        guard let itemProvider = results.first?.itemProvider,
              itemProvider.canLoadObject(ofClass: UIImage.self) else { return }
        
        itemProvider.loadObject(ofClass: UIImage.self) { image, _ in
            DispatchQueue.main.async {
                self.imageView.image = image as? UIImage
            }
            self.imageIsExist.value = true
        }
    }
}

private enum LayoutConstants {
    static let cornerRadius: CGFloat = 5
    static let largeFontSize: CGFloat = 25
    static let spacing: CGFloat = 8
    static let largeSpacing: CGFloat = 20
    static let topBarViewHeight: CGFloat = 50
    static let borderWidth: CGFloat = 1
    static let imageViewWidthMultiplier: CGFloat = 0.8
    static let buttonWidth: CGFloat = 100
}

private enum TextConstants {
    static let title = "New memory"
    static let phPickerButtonTitle = "Load"
    static let deleteButtonTitle = "Delete"
}
