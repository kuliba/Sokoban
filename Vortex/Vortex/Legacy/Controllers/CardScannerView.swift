//
//  CardScannerView.swift
//  ForaBank
//
//  Created by Mikhail on 22.06.2022.
//

import Foundation
import SwiftUI

struct CardScannerView: UIViewControllerRepresentable {
    
    let viewModel: CardScannerViewModel
    
    func makeUIViewController(context: Context) -> UINavigationController {
        let controller = CardScannerController.getScanner(resultsHandler: viewModel.closeAction)
        controller.modalPresentationStyle = .fullScreen
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {}
    
}

struct CardScannerViewModel: Identifiable {
    
    let id = UUID()
        
    var closeAction: (_ number: String?) -> Void
    
    internal init(closeAction: @escaping (_ number: String?) -> Void) {
        self.closeAction = closeAction
    }
}


