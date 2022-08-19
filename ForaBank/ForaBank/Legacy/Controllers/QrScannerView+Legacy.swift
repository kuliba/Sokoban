//
//  QrView+Legacy.swift
//  ForaBank
//
//  Created by Дмитрий on 01.07.2022.
//

import Foundation
import SwiftUI
import Combine

struct QrScannerView: UIViewControllerRepresentable {
    
    let viewModel: QrViewModel
    
    func makeUIViewController(context: Context) -> UIViewController {
        guard let controller = QRViewController.storyboardInstance() else {
            return UIViewController()
        }
        
        controller.viewModel = viewModel
        controller.modalPresentationStyle = .fullScreen
                
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}

}

struct QrViewModel {

    let closeAction: (Bool) -> Void
}
