import Combine
import PhotosUI
import SwiftUI
import UIKit

enum Layer {
    static let background: String = SDKLocalizedString("Background", comment: "Name of the background layer in an image editor")
    static let image: String = SDKLocalizedString("Image layer", comment: "Name of the image layer in an image editor")
}

public class CanvasViewController: UIViewController, PHPickerViewControllerDelegate {
    
    private let canvasView = MovableViewCanvas()
    private let canvasHoleView = UIView() // UIVisualEffectView()
    private var imageViews: [UIImageView] = []
    private lazy var personSegmentationModel = PersonSegmentationModel()
    private lazy var templatesViewModel = TemplatesViewModel()

    var inputImage: UIImage? {
        didSet {
            inputImageID = UUID().uuidString
            doSegmentation()
            cutoutButton.isHidden = inputImage == nil
        }
    }

    var inputImageID = UUID().uuidString
    var onCompletion: ((UIImage) -> Void)?
    var onCancel: (() -> Void)?
    private var cancellables = Set<AnyCancellable>()

    private lazy var cancelButton: UIButton = {
        let cancelButton = UIButton(type: .system)
        var configuration = UIButton.Configuration.plain()
        configuration.title = "Cancel"
        cancelButton.configuration = configuration
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.isHidden = true // TODO remove `hidden = true
        return cancelButton
    }()

    private lazy var doneButton: UIButton = {
        let doneButton = UIButton(type: .system)
        var configuration = UIButton.Configuration.filled()
        configuration.title = "Done"
        doneButton.configuration = configuration
        doneButton.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        return doneButton
    }()

    private lazy var cutoutButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Cutout", for: .normal)
        button.setImage(UIImage(systemName: "scissors"), for: .normal)
        button.addTarget(self, action: #selector(cutoutButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private lazy var photoLibraryButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "photo"), for: .normal)
        button.addTarget(self, action: #selector(selectImageButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private lazy var selectImageButton: UIButton = {
        let button = UIButton(type: .system)
        var configuration = UIButton.Configuration.borderedProminent()
        configuration.baseBackgroundColor = .black.withAlphaComponent(0.6)
        configuration.imagePadding = 6
        configuration.image = UIImage(systemName: "photo")
        configuration.title = "Replace"

        button.configuration = configuration
        button.addTarget(self, action: #selector(selectImageButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    public init(inputImage: UIImage?, onCompletion: ((UIImage) -> Void)?, onCancel: (() -> Void)?) {
        self.inputImage = inputImage
        self.onCancel = onCancel
        self.onCompletion = onCompletion
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public var prefersStatusBarHidden: Bool { true }

    var segmentationType: SegmentationType = .foreground
    override public func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        listenForUpdates()
        doSegmentation()
    }
    
    func doSegmentation() {
        guard let inputImage else { return }
        Task {
            do {
                self.segmentationType = await personSegmentationModel.suggestedSegmentationType(for: inputImage, cacheKey: inputImageID)
                try await personSegmentationModel.runSegmentationRequestOnImage(inputImage, for: segmentationType, cacheKey: inputImageID, setAsCurrent: true)
            } catch {
                print("Error running request: \(error)")
            }
        }
    }

    func listenForUpdates() {
        personSegmentationModel.$currentSegmentationResult.sink { [weak self] segmentationResult in
            guard let self, let segmentationResult else { return }
            self.templatesViewModel.segmentationResult = segmentationResult
            if let selectedTemplate = self.templatesViewModel.selectedTemplate {
                let newTemplate = ImageTemplate(template: selectedTemplate.template, segmentationResult: segmentationResult)
                self.canvasView.removeAllSubviews()
                canvasView.addLayers(newTemplate.template, personImage: newTemplate.image)
                self.selectImageButton.isHidden = true
            }
        }
        .store(in: &cancellables)

        templatesViewModel.$selectedTemplate.sink { [weak self] selectedTemplate in
            guard let self, let selectedTemplate else { return }
            let template = selectedTemplate
            self.canvasView.removeAllSubviews()
            canvasView.addLayers(template.template, personImage: template.image)
            self.selectImageButton.isHidden = true
            let isPersonPlaceholder = template.template.personLayer?.isPlaceholder
            guard isPersonPlaceholder == true else { return }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                guard let newImage = template.image.withColorOverlay() else { return }
                self.canvasView.removeAllSubviews()
                self.canvasView.addLayers(template.template, personImage: newImage)
                if self.selectImageButton.superview != nil {
                    self.selectImageButton.isHidden = false
                }
            }
        }
        .store(in: &cancellables)
    }

    // Action for Cancel button
    @objc
    func cancelButtonTapped() {
        onCancel?()
    }

    @objc
    func selectImageButtonTapped() {
        let photoPickerViewController = makePhotosViewController()
        present(photoPickerViewController, animated: true)
    }

    func makePhotosViewController() -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.filter = .images
        config.selectionLimit = 1
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        return picker
    }

    public func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        guard
            let result = results.first,
            result.itemProvider.canLoadObject(ofClass: UIImage.self)
        else {
            self.presentedViewController?.dismiss(animated: true)
            return
        }
        Task {
            let image = await result.itemProvider.loadUIImage()
            self.inputImage = image
            self.presentedViewController?.dismiss(animated: true)
        }
    }

    @objc
    func cutoutButtonTapped() {
        guard let inputImage else { return }
        let controller = UIHostingController(
            rootView: SegmentationView(
                segmentationType: segmentationType,
                viewModel: personSegmentationModel,
                inputImage: inputImage,
                inputImageID: inputImageID,
                onDone: {
                    self.presentedViewController?.dismiss(animated: true)
                },
                onCancel: {
                    self.presentedViewController?.dismiss(animated: true)
                }
            )
        )
        present(controller, animated: true)
    }

    // Action for Done button
    @objc
    func doneButtonTapped() {
        if let image = canvasView.snapshotImage() {
            onCompletion?(image)
        }
    }

    private func setupUI() {
        cutoutButton.isHidden = inputImage == nil

        let hostingController = UIHostingController(rootView: ImageTemplatesHorizontalGrid(templatesViewModel: templatesViewModel))
        addChild(hostingController)
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        let templatesGridView = hostingController.view!

        view.addSubview(cancelButton)
        view.addSubview(doneButton)
        view.backgroundColor = .black
        // let blurEffect = UIBlurEffect(style: .systemThinMaterialDark)

        // canvasHoleView.effect = blurEffect
        canvasHoleView.backgroundColor = .black
        canvasHoleView.isUserInteractionEnabled = false
        canvasHoleView.alpha = 0.9
        view.addSubview(canvasView)
        view.addSubview(canvasHoleView)
        view.addSubview(cutoutButton)
        view.addSubview(photoLibraryButton)
        view.addSubview(templatesGridView)
        view.addSubview(selectImageButton)
        canvasHoleView.translatesAutoresizingMaskIntoConstraints = false
        canvasView.translatesAutoresizingMaskIntoConstraints = false
        canvasView.layer.borderColor = UIColor.white.cgColor
        // canvasView.layer.borderWidth = 1
        NSLayoutConstraint.activate([
            canvasHoleView.topAnchor.constraint(equalTo: view.topAnchor),
            canvasHoleView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            canvasHoleView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            canvasHoleView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            canvasView.topAnchor.constraint(equalTo: view.topAnchor, constant: 100),
            canvasView.widthAnchor.constraint(equalToConstant: 300),
            canvasView.heightAnchor.constraint(equalToConstant: 300),
            canvasView.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            // Cancel button - Left of the screen, within safe area
            cancelButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            cancelButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 16),

            // Done button - Right of the screen, within safe area
            doneButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            doneButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 16),

            cutoutButton.leadingAnchor.constraint(equalTo: canvasView.leadingAnchor),
            cutoutButton.topAnchor.constraint(equalTo: canvasView.bottomAnchor, constant: 12),

            photoLibraryButton.trailingAnchor.constraint(equalTo: canvasView.trailingAnchor),
            photoLibraryButton.topAnchor.constraint(equalTo: canvasView.bottomAnchor, constant: 12),

            // templatesGridView
            templatesGridView.leadingAnchor.constraint(equalTo: canvasHoleView.leadingAnchor),
            templatesGridView.bottomAnchor.constraint(equalTo: canvasHoleView.safeLayoutGuide.bottomAnchor, constant: -50),
            templatesGridView.trailingAnchor.constraint(equalTo: canvasHoleView.trailingAnchor),
            templatesGridView.heightAnchor.constraint(lessThanOrEqualToConstant: 200),
            
            selectImageButton.centerXAnchor.constraint(equalTo: canvasView.centerXAnchor),
            selectImageButton.centerYAnchor.constraint(equalTo: canvasView.centerYAnchor)
        ])

        canvasView.backgroundColor = UIColor.label.withAlphaComponent(0.1)

        // Add masking effect
        addCanvasHoleMask()
        view.bringSubviewToFront(doneButton)
        view.bringSubviewToFront(cancelButton)
        view.bringSubviewToFront(cutoutButton)
        view.bringSubviewToFront(templatesGridView)

        hostingController.didMove(toParent: self)
    }

    private func addCanvasHoleMask() {
        let maskLayer = CAShapeLayer()
        maskLayer.frame = view.bounds

        // Define the mask path
        let path = UIBezierPath(rect: view.bounds)
        view.layoutIfNeeded()
        let canvasHolePath = UIBezierPath(rect: canvasView.frame)
        path.append(canvasHolePath)
        path.usesEvenOddFillRule = true

        maskLayer.path = path.cgPath
        maskLayer.fillRule = .evenOdd

        canvasHoleView.layer.mask = maskLayer
    }
}
