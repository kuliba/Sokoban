//
//  DocumentPicker.swift
//  ForaBank
//
//  Created by Константин Савялов on 26.11.2022.
//

import UIKit
import SwiftUI

struct DocumentPickerViewModel {
    
    var closeAction: (_ url: URL?) -> Void
}

struct DocumentPicker: UIViewControllerRepresentable {
    
    var viewModel: DocumentPickerViewModel
    let controller = UIDocumentPickerViewController(forOpeningContentTypes: [.jpeg, .image, .pdf])
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<DocumentPicker>) -> UIDocumentPickerViewController {
        
        controller.delegate = context.coordinator
        controller.allowsMultipleSelection = false
        controller.shouldShowFileExtensions = true
        return controller
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(DocumentPickerViewModel(closeAction: {_ in }))
    }
    
    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: UIViewControllerRepresentableContext<DocumentPicker>) {}
    
    class Coordinator: NSObject, UIDocumentPickerDelegate {
        
        let viewModel: DocumentPickerViewModel
        
        init(_ documentPickerViewModel: DocumentPickerViewModel) {
            viewModel = documentPickerViewModel
        }
        
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            
            print()
            guard let url = urls.first else { return }
            
            viewModel.closeAction(url.absoluteURL)
            controller.navigationController?.popViewController(animated: true)
        }
        
        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            viewModel.closeAction(nil)
            controller.navigationController?.popViewController(animated: true)
        }
        
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
            print()
        }
    }
}
