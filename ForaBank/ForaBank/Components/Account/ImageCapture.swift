//
//  ImageCapture.swift
//  ForaBank
//
//  Created by Mikhail on 28.06.2022.
//

import SwiftUI
import AnyImageKit

struct ImageCaptureViewModel: Identifiable {
        
    let id = UUID()
    let options: CaptureOptionsInfo
    
    var closeAction: (_ image: UIImage?) -> Void
    
    internal init(closeAction: @escaping (_ image: UIImage?) -> Void) {
        var options = CaptureOptionsInfo()
        options.mediaOptions = [.photo]
        options.preferredPresets = CapturePreset.createPresets(enableHighResolution: false, enableHighFrameRate: false)
        options.photoAspectRatio = .ratio1x1
        options.preferredPositions = [.front, .back]
        options.flashMode = .auto
        options.videoMaximumDuration = 10
        options.editorPhotoOptions.toolOptions = [.crop]
        options.editorPhotoOptions.cropOptions = [.custom(w: 1, h: 1)]
        let theme = CaptureTheme()
        theme.configurationButton(for: .cancel) { button in
            button.setTitle("Отмена", for: .normal)
        }
        options.theme = theme
        self.options = options
        self.closeAction = closeAction
    }
}


struct ImageCapture: UIViewControllerRepresentable {
        
    let viewModel: ImageCaptureViewModel
    
    func makeUIViewController(context: Context) -> ImageCaptureController {
                
        let picker = ImageCaptureController(options: viewModel.options, delegate: context.coordinator)
        return picker
    }
    
    func updateUIViewController(_ uiViewController: ImageCaptureController, context: Context) { }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, ImageCaptureControllerDelegate, ImageKitDataTrackDelegate {
        
        
        let parent: ImageCapture
        
        init(_ parent: ImageCapture) {
            self.parent = parent
        }
        
        func imageCapture(_ capture: ImageCaptureController, didFinishCapturing result: CaptureResult) {
            switch result.type {
            case .photo:
                
                capture.dismiss(animated: true, completion: { [weak self] in
                    guard let self = self else { return }
                    guard let data = try? Data(contentsOf: result.mediaURL) else { return }
                    let image = UIImage(data: data)
                    self.parent.viewModel.closeAction(image)
                })
            default: break
            }
        }
        
        func dataTrack(page: AnyImagePage, state: AnyImagePageState) {
            switch state {
            case .enter:
                print("[Data Track] ENTER Page: \(page.rawValue)")
            case .leave:
                print("[Data Track] LEAVE Page: \(page.rawValue)")
            }
        }
        
        func dataTrack(event: AnyImageEvent, userInfo: [AnyImageEventUserInfoKey: Any]) {
            print("[Data Track] EVENT: \(event.rawValue), userInfo: \(userInfo)")
        }
    }
}
