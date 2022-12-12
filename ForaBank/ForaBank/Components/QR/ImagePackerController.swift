//
//  ImagePackerController.swift
//  ForaBank
//
//  Created by Константин Савялов on 12.12.2022.
//

import UIKit
import SwiftUI

struct ImagePickerControllerViewModel {
    
    let selectedAction: (_ url: UIImage) -> Void
    let closeAction: () -> Void
}

struct QRImagePickerController: UIViewControllerRepresentable {
    
    let viewModel: ImagePickerControllerViewModel
    var sourceType: UIImagePickerController.SourceType = .photoLibrary
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<QRImagePickerController>) -> UIImagePickerController {
        
        let imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = false
        imagePicker.sourceType = sourceType
        
        return imagePicker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<QRImagePickerController>) {
        
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(viewModel)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        
        let viewModel: ImagePickerControllerViewModel
        
        init(_ imagePickerViewModel: ImagePickerControllerViewModel) {
            viewModel = imagePickerViewModel
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            
            if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
                
                viewModel.selectedAction(image)
            }
            viewModel.closeAction()
        }
    }
}
