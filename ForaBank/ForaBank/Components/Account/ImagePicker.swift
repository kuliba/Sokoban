//
//  ImagePicker.swift
//  ForaBank
//
//  Created by Mikhail on 28.06.2022.
//

import SwiftUI
import AnyImageKit

struct ImagePickerViewModel: Identifiable {
        
    let id = UUID()
    let options: PickerOptionsInfo
    
    var closeAction: (_ image: UIImage?) -> Void
    
    internal init(closeAction: @escaping (_ image: UIImage?) -> Void) {
        
        var options = PickerOptionsInfo()
        options.selectLimit = 1
        options.selectionTapAction = .openEditor
        options.saveEditedAsset = false
        options.editorOptions = [.photo]
        options.editorPhotoOptions.toolOptions = [.crop]
        options.editorPhotoOptions.cropOptions = [.custom(w: 1, h: 1)]
        let theme = PickerTheme(style: .light)
        theme.configurationButton(for: .edit) { button in
            button.setTitle("Сбросить", for: .normal)
        }
        options.theme = theme
        self.options = options
        self.closeAction = closeAction
    }
}

struct ImagePicker: UIViewControllerRepresentable {
        
    let viewModel: ImagePickerViewModel
    
    func makeUIViewController(context: Context) -> ImagePickerController {
                
        let picker = ImagePickerController(options: viewModel.options, delegate: context.coordinator)
        return picker
    }
    
    func updateUIViewController(_ uiViewController: ImagePickerController, context: Context) { }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, ImagePickerControllerDelegate, ImageKitDataTrackDelegate {
        
        
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePicker(_ picker: ImagePickerController, didFinishPicking result: PickerResult) {
            self.parent.viewModel.closeAction(result.assets.first?.image)
            picker.navigationController?.popViewController(animated: true)
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
