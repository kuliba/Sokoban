//
//  DocumentPicker.swift
//  ForaBank
//
//  Created by Константин Савялов on 26.11.2022.
//

import UIKit
import SwiftUI
import UniformTypeIdentifiers

struct DocumentPickerViewModel {
    
    var closeAction: (_ url: URL?) -> Void
}

struct DocumentPicker: UIViewControllerRepresentable {
    
    var viewModel: DocumentPickerViewModel
    let controller = UIDocumentPickerViewController(forOpeningContentTypes: [.jpeg, .image, .pdf], asCopy: true)
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<DocumentPicker>) -> UIDocumentPickerViewController {
 
        controller.delegate = context.coordinator
        controller.allowsMultipleSelection = false
        controller.shouldShowFileExtensions = true
        return controller
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }
    
    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: UIViewControllerRepresentableContext<DocumentPicker>) {}
    
    class Coordinator: NSObject, UIDocumentPickerDelegate {
        
        let picker: DocumentPicker
        
        init(_ pickerContent: DocumentPicker) {
            picker = pickerContent
        }
        
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            
            print()
            guard let url = urls.first else { return }
            defer {
                url.stopAccessingSecurityScopedResource()
            }
            
            self.picker.viewModel.closeAction(url.absoluteURL)
            controller.navigationController?.popViewController(animated: true)
        }
        
        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            self.picker.viewModel.closeAction(nil)
            controller.navigationController?.popViewController(animated: true)
        }
        
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
            print()
        }
    }
}
