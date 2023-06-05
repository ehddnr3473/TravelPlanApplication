//
//  WritingMemoryViewController.swift
//  YeolmokTravel
//
//  Created by 김동욱 on 2022/12/24.
//

import UIKit
import PhotosUI
import Combine
import FirebasePlatform
import Domain

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
    
    private let memoriesListIndex: Int
    private let viewModel: DefaultWritingMemoryViewModel
    private weak var delegate: MemoryTransferDelegate?
    
    private let ownView = WritingMemoryView()
    
    private let phPicker: PHPickerViewController = {
        var configuration = PHPickerConfiguration()
        configuration.filter = .images
        let phPicker = PHPickerViewController(configuration: configuration)
        return phPicker
    }()
    
    // MARK: - Init
    init(viewModel: DefaultWritingMemoryViewModel,
         memoriesListIndex: Int,
         delegate: MemoryTransferDelegate) {
        self.viewModel = viewModel
        self.memoriesListIndex = memoriesListIndex
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        configureDelegate()
        configureAction()
        configureTapGesture()
        bind()
    }
    
    // MARK: - Binding
    private func bind() {
        let input = DefaultWritingMemoryViewModel.Input(
            title: titlePublisher.eraseToAnyPublisher(),
            image: imageIsExistPublisher.eraseToAnyPublisher()
        )
        
        let output = viewModel.transform(input: input)
        
        output.buttonState
            .receive(on: DispatchQueue.main)
            .sink{ [weak self] state in
                self?.ownView.saveBarButton.isEnabled = state
            }
            .store(in: &subscriptions)
    }
}

// MARK: - Configure view
extension WritingMemoryViewController {
    func configureView() {
        view.backgroundColor = .systemBackground
        configureHierarchy()
        configureLayoutConstraint()
    }
    
    func configureHierarchy() {
        view.addSubview(ownView)
    }
    
    func configureLayoutConstraint() {
        ownView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            $0.leading.equalTo(view.safeAreaLayoutGuide.snp.leading)
            $0.trailing.equalTo(view.safeAreaLayoutGuide.snp.trailing)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
    }
    
    func configureDelegate() {
        ownView.titleTextField.delegate = self
        phPicker.delegate = self
    }
    
    func configureAction() {
        ownView.saveBarButton.addTarget(self, action: #selector(touchUpSaveButton), for: .touchUpInside)
        ownView.cancelBarButton.addTarget(self, action: #selector(touchUpCancelButton), for: .touchUpInside)
        ownView.imageLoadButton.addTarget(self, action: #selector(touchUpImageLoadButton), for: .touchUpInside)
        ownView.imageDeleteButton.addTarget(self, action: #selector(touchUpImageDeleteButton), for: .touchUpInside)
        ownView.titleTextField.addTarget(self, action: #selector(editingChangedTitleTextField), for: .editingChanged)
    }
}

// MARK: - User Interaction
private extension WritingMemoryViewController {
    @objc func touchUpSaveButton() {
        if ownView.titleTextField.text == "" {
            alertWillAppear(MemoryCreatingError.titleError.rawValue)
            return
        } else if ownView.imageView.image == nil {
            alertWillAppear(MemoryCreatingError.nilImageError.rawValue)
            return
        }
        Task { await createMemory() }
    }
    
    func createMemory() async {
        ownView.indicatorView.show(in: view)
        guard let image = ownView.imageView.image else { return }
        let memory = Memory(id: memoriesListIndex, title: ownView.titleTextField.text ?? "", uploadDate: Date())
        do {
            try await viewModel.upload(memory, image)
            delegate?.create(memory)
            ownView.indicatorView.dismiss(animated: true)
            dismiss(animated: true)
        } catch {
            if let error = error as? MemoriesRepositoryError {
                alertWillAppear(error.rawValue)
            } else if let error = error as? ImagesRepositoryError {
                alertWillAppear(error.rawValue)
            }
            ownView.indicatorView.dismiss(animated: true)
        }
    }
    
    @objc func touchUpCancelButton() {
        dismiss(animated: true)
    }
    
    @objc func touchUpImageLoadButton() {
        DispatchQueue.main.async { [self] in
            present(phPicker, animated: true)
        }
    }
    
    @objc func touchUpImageDeleteButton() {
        ownView.imageView.image = nil
        self.imageIsExistPublisher.value = false
    }
    
    @objc func editingChangedTitleTextField() {
        titlePublisher.send(ownView.titleTextField.text ?? "")
    }
    
    @objc func tapView() {
        view.endEditing(true)
    }
    
    func configureTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapView))
        view.addGestureRecognizer(tapGesture)
    }
}

// MARK: - PHPickerContollerDelegate
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
                guard let width = self?.ownView.imageView.frame.width,
                      let height = self?.ownView.imageView.frame.height,
                      let image = self?.compressImage(image, CGSize(width: width, height: height)) else {
                    self?.alertWillAppear(PHPickerError.imageLoadFailed.rawValue)
                    return
                }
                self?.ownView.imageView.image = image
            }
            
            self?.imageIsExistPublisher.value = true
        }
    }
    
    private func compressImage(_ image: NSItemProviderReading?, _ compressionSize: CGSize) -> UIImage? {
        guard let image = image as? UIImage else { return nil }
        UIGraphicsBeginImageContextWithOptions(compressionSize, false, ImageConstants.compressionScale)
        image.draw(in: CGRect(origin: .zero, size: compressionSize))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
}

// MARK: - UITextFieldDelegate
extension WritingMemoryViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

// MARK: - Magic number
private extension WritingMemoryViewController {
    @frozen enum ImageConstants {
        static let compressionScale: CGFloat = 1.0
    }
}
