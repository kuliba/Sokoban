//
//  DocumentPicker.swift
//  ForaBank
//
//  Created by Константин Савялов on 26.11.2022.
//

import UIKit
import SwiftUI

struct DocumentPickerViewModel {
    
    let selectedAction: (_ url: URL) -> Void
    let closeAction: () -> Void
}

struct DocumentPicker: UIViewControllerRepresentable {
    
    let viewModel: DocumentPickerViewModel
    let controller = UIDocumentPickerViewController(forOpeningContentTypes: [.jpeg, .image, .pdf])
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<DocumentPicker>) -> UIDocumentPickerViewController {
        
        controller.delegate = context.coordinator
        controller.allowsMultipleSelection = false
        controller.shouldShowFileExtensions = true
        return controller
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(viewModel)
    }
    
    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: UIViewControllerRepresentableContext<DocumentPicker>) {}
    
    class Coordinator: NSObject, UIDocumentPickerDelegate {
        
        let viewModel: DocumentPickerViewModel
        
        init(_ documentPickerViewModel: DocumentPickerViewModel) {
            viewModel = documentPickerViewModel
        }
        
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            
            guard let url = urls.first else { return }
            guard url.startAccessingSecurityScopedResource() else { return }
            
            viewModel.selectedAction(url)
        }
        
        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            
            viewModel.closeAction()
        }
    }
}
