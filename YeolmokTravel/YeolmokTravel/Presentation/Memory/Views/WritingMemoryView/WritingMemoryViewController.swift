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
    
    private let writingMemoryView = WritingMemoryView()
    
    private let phPicker: PHPickerViewController = {
        var configuration = PHPickerConfiguration()
        configuration.filter = .images
        let phPicker = PHPickerViewController(configuration: configuration)
        return phPicker
    }()
    
    init(_ viewModel: ConcreteWritingMemoryViewModel, _ memoryIndex: Int, delegate: MemoryTransferDelegate) {
        self.viewModel = viewModel
        self.memoryIndex = memoryIndex
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        configureDelegate()
        configureAction()
        configureTapGesture()
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
        view.addSubview(writingMemoryView)
    }
    
    func configureLayoutConstraint() {
        writingMemoryView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            $0.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    func configureDelegate() {
        writingMemoryView.titleTextField.delegate = self
        phPicker.delegate = self
    }
    
    func configureAction() {
        writingMemoryView.saveBarButton.addTarget(self, action: #selector(touchUpRightBarButton), for: .touchUpInside)
        writingMemoryView.cancelBarButton.addTarget(self, action: #selector(touchUpLeftBarButton), for: .touchUpInside)
        writingMemoryView.imageLoadButton.addTarget(self, action: #selector(touchUpImageLoadButton), for: .touchUpInside)
        writingMemoryView.imageDeleteButton.addTarget(self, action: #selector(touchUpImageDeleteButton), for: .touchUpInside)
        writingMemoryView.titleTextField.addTarget(self, action: #selector(editingChangedTitleTextField), for: .editingChanged)
    }
}

// MARK: - User Interaction & Binding
private extension WritingMemoryViewController {
    @objc func touchUpRightBarButton() {
        if writingMemoryView.titleTextField.text == "" {
            alertWillAppear(MemoryCreatingError.titleError.rawValue)
            return
        } else if writingMemoryView.imageView.image == nil {
            alertWillAppear(MemoryCreatingError.nilImageError.rawValue)
            return
        }
        Task { await createMemory() }
    }
    
    func createMemory() async {
        writingMemoryView.indicatorView.show(in: view)
        guard let image = writingMemoryView.imageView.image else { return }
        let memory = YTMemory(title: writingMemoryView.titleTextField.text ?? "", index: memoryIndex, uploadDate: Date())
        do {
            try await viewModel.upload(memoryIndex, image, memory)
            delegate?.create(memory)
            writingMemoryView.indicatorView.dismiss(animated: true)
            dismiss(animated: true)
        } catch {
            if let error = error as? MemoryRepositoryError {
                alertWillAppear(error.rawValue)
            } else if let error = error as? MemoryImageRepositoryError {
                alertWillAppear(error.rawValue)
            }
            writingMemoryView.indicatorView.dismiss(animated: true)
        }
    }
    
    @objc func touchUpLeftBarButton() {
        dismiss(animated: true)
    }
    
    @objc func touchUpImageLoadButton() {
        DispatchQueue.main.async { [self] in
            present(phPicker, animated: true)
        }
    }
    
    @objc func touchUpImageDeleteButton() {
        writingMemoryView.imageView.image = nil
        self.imageIsExistPublisher.value = false
    }
    
    @objc func editingChangedTitleTextField() {
        titlePublisher.send(writingMemoryView.titleTextField.text ?? "")
    }
    
    @objc func tapView() {
        view.endEditing(true)
    }
    
    func configureTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapView))
        view.addGestureRecognizer(tapGesture)
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
                self?.writingMemoryView.saveBarButton.isEnabled = state
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
                guard let width = self?.writingMemoryView.imageView.frame.width,
                      let height = self?.writingMemoryView.imageView.frame.height,
                      let image = self?.compressImage(image, CGSize(width: width, height: height)) else {
                    self?.alertWillAppear(PHPickerError.imageLoadFailed.rawValue)
                    return
                }
                self?.writingMemoryView.imageView.image = image
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

extension WritingMemoryViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

private enum ImageConstants {
    static let compressionScale: CGFloat = 1.0
}
