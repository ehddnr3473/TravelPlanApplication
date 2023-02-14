//
//  WritingMemoryViewController.swift
//  YeolmokTravel
//
//  Created by 김동욱 on 2022/12/24.
//

import UIKit
import PhotosUI
import Combine

enum PHPickerError: String, Error {
    case imageLoadFailed = "이미지 불러오기를 실패했습니다."
}

enum MemoryCreatingError: String, Error {
    case titleError = "제목을 입력해주세요."
    case nilImageError = "사진을 선택해주세요."
}

final class WritingMemoryViewController: UIViewController {
    // MARK: - Properties
    private let titlePublisher = CurrentValueSubject<String, Never>("")
    private let imageIsExistPublisher = CurrentValueSubject<Bool, Never>(false)
    private var subscriptions = Set<AnyCancellable>()
    
    private let memoryIndex: Int
    private let viewModel: ConcreteWritingMemoryViewModel
    weak var delegate: MemoryTransferDelegate?
    
    private let topBarView: TopBarView = {
        let topBarView = TopBarView()
        return topBarView
    }()
    
    private let titleTextField: UITextField = {
        let textField = UITextField()
        textField.textColor = .white
        textField.backgroundColor = .systemBackground
        textField.layer.cornerRadius = LayoutConstants.cornerRadius
        textField.layer.borderWidth = AppLayoutConstants.borderWidth
        textField.layer.borderColor = UIColor.white.cgColor
        textField.font = .boldSystemFont(ofSize: AppLayoutConstants.largeFontSize)
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none
        textField.leftView = UIView(frame: CGRect(x: .zero,
                                                  y: .zero,
                                                  width: AppLayoutConstants.spacing,
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
        imageView.layer.borderWidth = AppLayoutConstants.borderWidth
        imageView.layer.borderColor = UIColor.white.cgColor
        return imageView
    }()
    
    private lazy var addButton: UIButton = {
        let button = UIButton(type: .custom)
        button.addTarget(self, action: #selector(touchUpAddButton), for: .touchUpInside)
        button.setTitle(TextConstants.phPickerButtonTitle, for: .normal)
        button.setTitleColor(.systemBackground, for: .normal)
        button.backgroundColor = AppStyles.mainColor
        button.layer.borderColor = UIColor.systemBackground.cgColor
        button.layer.borderWidth = AppLayoutConstants.borderWidth
        return button
    }()
    
    private lazy var deleteButton: UIButton = {
        let button = UIButton(type: .custom)
        button.addTarget(self, action: #selector(touchUpDeleteButton), for: .touchUpInside)
        button.setTitle(TextConstants.deleteButtonTitle, for: .normal)
        button.setTitleColor(.systemBackground, for: .normal)
        button.backgroundColor = .systemGray
        button.layer.borderColor = UIColor.systemBackground.cgColor
        button.layer.borderWidth = AppLayoutConstants.borderWidth
        return button
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        return label
    }()
    
    // MARK: - Init
    init(_ viewModel: ConcreteWritingMemoryViewModel, _ memoryIndex: Int, delegate: MemoryTransferDelegate) {
        self.viewModel = viewModel
        self.memoryIndex = memoryIndex
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("deinit: WritingMemoryViewController")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        configure()
        setBindings()
    }
}

// MARK: - Configure View
extension WritingMemoryViewController {
    func configureView() {
        view.backgroundColor = .systemBackground
        configureHierarchy()
        configureLayoutConstraint()
    }
    
    func configureHierarchy() {
        [topBarView, titleTextField, imageView, addButton, deleteButton].forEach {
            view.addSubview($0)
        }
    }
    
    func configureLayoutConstraint() {
        topBarView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            $0.width.equalToSuperview()
            $0.height.equalTo(LayoutConstants.topBarViewHeight)
        }
        
        titleTextField.snp.makeConstraints {
            $0.top.equalTo(topBarView.snp.bottom)
                .offset(AppLayoutConstants.largeSpacing)
            $0.leading.trailing.equalToSuperview()
                .inset(AppLayoutConstants.spacing)
        }
        
        imageView.snp.makeConstraints {
            $0.top.equalTo(titleTextField.snp.bottom)
                .offset(AppLayoutConstants.largeSpacing)
            $0.centerX.equalToSuperview()
            $0.width.equalToSuperview()
                .multipliedBy(LayoutConstants.imageViewWidthMultiplier)
            $0.height.equalTo(imageView.snp.width)
        }
        
        deleteButton.snp.makeConstraints {
            $0.top.equalTo(imageView.snp.bottom)
                .offset(AppLayoutConstants.spacing)
            $0.width.equalTo(LayoutConstants.buttonWidth)
            $0.trailing.equalTo(view.snp.centerX)
                .offset(-AppLayoutConstants.spacing)
        }
        
        addButton.snp.makeConstraints {
            $0.top.equalTo(imageView.snp.bottom)
                .offset(AppLayoutConstants.spacing)
            $0.width.equalTo(LayoutConstants.buttonWidth)
            $0.leading.equalTo(view.snp.centerX)
                .offset(AppLayoutConstants.spacing)
        }
    }
    
    func configure() {
        topBarView.barTitleLabel.text = TextConstants.title
        topBarView.saveBarButton.addTarget(self, action: #selector(touchUpRightBarButton), for: .touchUpInside)
        topBarView.cancelBarButton.addTarget(self, action: #selector(touchUpLeftBarButton), for: .touchUpInside)
        titleTextField.addTarget(self, action: #selector(editingChangedTitleTextField), for: .editingChanged)
        phPicker.delegate = self
    }
}

// MARK: - User Interaction
private extension WritingMemoryViewController {
    @objc func touchUpRightBarButton() {
        if titleTextField.text == "" {
            alertWillAppear(MemoryCreatingError.titleError.rawValue)
            return
        } else if imageView.image == nil {
            alertWillAppear(MemoryCreatingError.nilImageError.rawValue)
            return
        }
        
        Task { await createMemory() }
    }
    
    func createMemory() async {
        guard let image = imageView.image else { return }
        let memory = Memory(title: titleTextField.text ?? "", index: memoryIndex, uploadDate: Date())
        do {
            try await viewModel.upload(memoryIndex, image, memory)
            delegate?.create(memory)
            dismiss(animated: true)
        } catch {
            if let error = error as? MemoryRepositoryError {
                alertWillAppear(error.rawValue)
            } else if let error = error as? MemoryImageRepositoryError {
                alertWillAppear(error.rawValue)
            }
        }
    }
    
    @objc func touchUpLeftBarButton() {
        dismiss(animated: true)
    }
    
    @objc func touchUpAddButton() {
        DispatchQueue.main.async { [self] in
            present(phPicker, animated: true)
        }
    }
    
    @objc func touchUpDeleteButton() {
        imageView.image = nil
        self.imageIsExistPublisher.value = false
    }
    
    @objc func editingChangedTitleTextField() {
        titlePublisher.send(titleTextField.text ?? "")
    }
    
    func setBindings() {
        let input = ConcreteWritingMemoryViewModel.Input(
            title: titlePublisher.eraseToAnyPublisher(),
            image: imageIsExistPublisher.eraseToAnyPublisher()
        )
        
        let output = viewModel.transform(input: input)
        
        output.buttonState
            .receive(on: DispatchQueue.main)
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
        
        // '취소'
        guard let result = results.first else { return }
        
        guard result.itemProvider.canLoadObject(ofClass: UIImage.self) else {
            alertWillAppear(PHPickerError.imageLoadFailed.rawValue)
            return
        }

        result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] image, error in
            guard error == nil else {
                self?.alertWillAppear(PHPickerError.imageLoadFailed.rawValue)
                return
            }
            
            DispatchQueue.main.async {
                self?.imageView.image = image as? UIImage
            }
            
            self?.imageIsExistPublisher.value = true
        }
    }
}

private enum LayoutConstants {
    static let cornerRadius: CGFloat = 5
    static let imageViewWidthMultiplier: CGFloat = 0.8
    static let buttonWidth: CGFloat = 100
    static let topBarViewHeight: CGFloat = 50
}

private enum TextConstants {
    static let title = "New memory"
    static let phPickerButtonTitle = "Load"
    static let deleteButtonTitle = "Delete"
}
