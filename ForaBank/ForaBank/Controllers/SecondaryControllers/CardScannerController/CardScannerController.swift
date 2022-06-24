//
//  CardScannerController.swift
//  CardScannerController
//
//  Created by Mikhail on 03.06.2021.
//

import AVFoundation
import CoreImage
import UIKit
import Vision

@available(iOS 13.0, *)
public class CardScannerController: UIViewController {
    // MARK: - Private Properties

    private let captureSession = AVCaptureSession()
    private lazy var previewLayer: AVCaptureVideoPreviewLayer = {
        let preview = AVCaptureVideoPreviewLayer(session: self.captureSession)
        preview.videoGravity = .resizeAspect
        return preview
    }()
    
    private let device = AVCaptureDevice.default(for: .video)

    private var viewGuide: PartialTransparentView!

    private var creditCardNumber: String?

    private let videoOutput = AVCaptureVideoDataOutput()

    // MARK: - Public Properties

    public var labelCardNumber: UILabel?
    public var labelCardDate: UILabel?
    public var labelCardCVV: UILabel?
    public var labelHintBottom: UILabel?
    public var labelHintTop: UILabel?
    public var buttonComplete: UIButton?

    public var hintTopText = "Поместите вашу карту в центре, пока номер не будет распознан"
    public var hintBottomText = "Нажмите на номер для удаления и попробуйте еще раз"
    public var buttonConfirmTitle = "Подтвердить"
    public var buttonConfirmBackgroundColor: UIColor = .red
    public var viewTitle = "Сканер карты"

    // MARK: - Instance dependencies

    private var resultsHandler: (_ number: String?) -> Void?


    // MARK: - Initializers

    init(resultsHandler: @escaping (_ number: String?) -> Void) {
        self.resultsHandler = resultsHandler
        super.init(nibName: nil, bundle: nil)
    }

    public class func getScanner(resultsHandler: @escaping (_ number: String?) -> Void) -> UINavigationController {
        let viewScanner = CardScannerController(resultsHandler: resultsHandler)
        let navigation = UINavigationController(rootViewController: viewScanner)
        return navigation
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func loadView() {
        view = UIView()
    }

    deinit {
        stop()
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        setupCaptureSession()
        captureSession.startRunning()
        title = viewTitle
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        let buttomItem = UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: #selector(scanCompleted))
        buttomItem.tintColor = .white
        navigationItem.leftBarButtonItem = buttomItem
    }

    override public func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer.frame = view.bounds
    }

    // MARK: - Add Views

    private func setupCaptureSession() {
        addCameraInput()
        addPreviewLayer()
        addVideoOutput()
        addGuideView()
    }

    private func addCameraInput() {
        guard let device = device else { return }
        let cameraInput = try! AVCaptureDeviceInput(device: device)
        captureSession.addInput(cameraInput)
    }

    private func addPreviewLayer() {
        view.layer.addSublayer(previewLayer)
    }

    private func addVideoOutput() {
        videoOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as NSString: NSNumber(value: kCVPixelFormatType_32BGRA)] as [String: Any]
        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "my.image.handling.queue"))
        captureSession.addOutput(videoOutput)
        guard let connection = videoOutput.connection(with: AVMediaType.video),
            connection.isVideoOrientationSupported else {
            return
        }
        connection.videoOrientation = .portrait
    }

    private func addGuideView() {
        let widht = UIScreen.main.bounds.width - (UIScreen.main.bounds.width * 0.2)
        let height = widht - (widht * 0.45)
        let viewX = (UIScreen.main.bounds.width / 2) - (widht / 2)
        let viewY = (UIScreen.main.bounds.height / 2) - (height / 2) - 100

        viewGuide = PartialTransparentView(rectsArray: [CGRect(x: viewX, y: viewY, width: widht, height: height)])

        view.addSubview(viewGuide)
        viewGuide.fillSuperview()
        
        view.bringSubviewToFront(viewGuide)

        let bottomY = (UIScreen.main.bounds.height / 2) + (height / 2) - 100

        let labelCardNumberX = viewX + 20
        let labelCardNumberY = bottomY - 50
        labelCardNumber = UILabel(frame: CGRect(x: labelCardNumberX, y: labelCardNumberY, width: 100, height: 30))
        view.addSubview(labelCardNumber!)
        labelCardNumber?.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        labelCardNumber?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(clearCardNumber)))
        labelCardNumber?.isUserInteractionEnabled = true
        labelCardNumber?.textColor = .white
        labelCardNumber?.anchor(top: view.topAnchor, left: view.leftAnchor,
                                paddingTop: labelCardNumberY, paddingLeft: labelCardNumberX)
        

        let labelCardCVVX = viewX + 200
        let labelCardCVVY = bottomY - 90
        
        let labelHintTopY = viewY - 40
        labelHintTop = UILabel(frame: CGRect(x: labelCardCVVX, y: labelCardCVVY, width: widht, height: 30))
        view.addSubview(labelHintTop!)
        labelHintTop?.translatesAutoresizingMaskIntoConstraints = false
        labelHintTop?.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
        labelHintTop?.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        labelHintTop?.topAnchor.constraint(equalTo: view.topAnchor, constant: labelHintTopY).isActive = true
        labelHintTop?.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        labelHintTop?.text = hintTopText
        labelHintTop?.numberOfLines = 0
        labelHintTop?.textAlignment = .center
        labelHintTop?.textColor = .white

        let labelHintBottomY = bottomY + 30
        labelHintBottom = UILabel(frame: CGRect(x: labelCardCVVX, y: labelCardCVVY, width: widht, height: 30))
        view.addSubview(labelHintBottom!)
        labelHintBottom?.translatesAutoresizingMaskIntoConstraints = false
        labelHintBottom?.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
        labelHintBottom?.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        labelHintBottom?.topAnchor.constraint(equalTo: view.topAnchor, constant: labelHintBottomY).isActive = true
        labelHintBottom?.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        labelHintBottom?.text = hintBottomText
        labelHintBottom?.numberOfLines = 0
        labelHintBottom?.textAlignment = .center
        labelHintBottom?.textColor = .white
        
        let buttonCompleteX = viewX
        let buttonCompleteY = UIScreen.main.bounds.height - 90
        buttonComplete = UIButton(frame: CGRect(x: buttonCompleteX, y: buttonCompleteY, width: 100, height: 50))
        buttonComplete?.setTitle(buttonConfirmTitle, for: .normal)
        buttonComplete?.backgroundColor = buttonConfirmBackgroundColor
        buttonComplete?.layer.cornerRadius = 10
        buttonComplete?.layer.masksToBounds = true
        buttonComplete?.addTarget(self, action: #selector(scanCompleted), for: .touchUpInside)
        
        view.addSubview(buttonComplete!)
        buttonComplete?.anchor(left: view.leftAnchor, bottom: view.bottomAnchor , right: view.rightAnchor,
                               paddingLeft: viewX, paddingBottom: 90, paddingRight: viewX, height: 50)
        
//        buttonComplete?.leftAnchor.constraint(equalTo: view.leftAnchor, constant: viewX).isActive = true
//        buttonComplete?.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: viewX * -1).isActive = true
//        buttonComplete?.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -90).isActive = true
//        buttonComplete?.heightAnchor.constraint(equalToConstant: 50).isActive = true
        

        view.backgroundColor = .black
    }

    // MARK: - Clear on touch

    @objc func clearCardNumber() {
        labelCardNumber?.text = ""
        creditCardNumber = nil
    }

    // MARK: - Completed process

    @objc func scanCompleted() {
        resultsHandler(creditCardNumber)
        stop()
        dismiss(animated: true, completion: nil)
    }

    private func stop() {
        captureSession.stopRunning()
    }

    // MARK: - Payment detection

    private func handleObservedPaymentCard(in frame: CVImageBuffer) {
        DispatchQueue.global(qos: .userInitiated).async {
            self.extractPaymentCardData(frame: frame)
        }
    }

    private func extractPaymentCardData(frame: CVImageBuffer) {
        let ciImage = CIImage(cvImageBuffer: frame)
        let widht = UIScreen.main.bounds.width - (UIScreen.main.bounds.width * 0.2)
        let height = widht - (widht * 0.45)
        let viewX = (UIScreen.main.bounds.width / 2) - (widht / 2)
        let viewY = (UIScreen.main.bounds.height / 2) - (height / 2) - 100 + height

        let resizeFilter = CIFilter(name: "CILanczosScaleTransform")!

        // Desired output size
        let targetSize = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)

        // Compute scale and corrective aspect ratio
        let scale = targetSize.height / ciImage.extent.height
        let aspectRatio = targetSize.width / (ciImage.extent.width * scale)

        // Apply resizing
        resizeFilter.setValue(ciImage, forKey: kCIInputImageKey)
        resizeFilter.setValue(scale, forKey: kCIInputScaleKey)
        resizeFilter.setValue(aspectRatio, forKey: kCIInputAspectRatioKey)
        let outputImage = resizeFilter.outputImage

        let croppedImage = outputImage!.cropped(to: CGRect(x: viewX, y: viewY, width: widht, height: height))

        let request = VNRecognizeTextRequest()
        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = false

        let stillImageRequestHandler = VNImageRequestHandler(ciImage: croppedImage, options: [:])
        try? stillImageRequestHandler.perform([request])

        guard let texts = request.results as? [VNRecognizedTextObservation], texts.count > 0 else {
            // no text detected
            return
        }

        let arrayLines = texts.flatMap({ $0.topCandidates(20).map({ $0.string }) })

        for line in arrayLines {
//            print("Trying to parse: \(line)")

            let trimmed = line.replacingOccurrences(of: " ", with: "")

            if creditCardNumber == nil &&
                trimmed.count >= 15 &&
                trimmed.count <= 16 &&
                trimmed.isOnlyNumbers {
                creditCardNumber = line
                DispatchQueue.main.async {
                    self.labelCardNumber?.text = line
                    self.tapticFeedback()
                }
                continue
            }

        }
    }

    private func tapticFeedback() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }
}

// MARK: - AVCaptureVideoDataOutputSampleBufferDelegate

extension CardScannerController: AVCaptureVideoDataOutputSampleBufferDelegate {
    public func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let frame = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            debugPrint("unable to get image from sample buffer")
            return
        }

        handleObservedPaymentCard(in: frame)
    }
}

// MARK: - Extensions

private extension String {
    var isOnlyAlpha: Bool {
        return !isEmpty && range(of: "[^a-zA-Z]", options: .regularExpression) == nil
    }

    var isOnlyNumbers: Bool {
        return !isEmpty && range(of: "[^0-9]", options: .regularExpression) == nil
    }

    
}

