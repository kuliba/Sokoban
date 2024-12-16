//
//  ActivityViewComponent.swift
//  Vortex
//
//  Created by Mikhail on 21.06.2022.
//

import UIKit
import SwiftUI

extension ActivityView {
    
    struct ViewModel {
        
        let activityItems: [Any]
        let applicationActivities: [UIActivity]? = nil
        var completion: (() -> Void)?
    }
}

struct ActivityView: UIViewControllerRepresentable {
    
    let viewModel: ActivityView.ViewModel
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<ActivityView>) -> UIActivityViewController {
        
        let controller = UIActivityViewController(
            activityItems: viewModel.activityItems,
            applicationActivities: viewModel.applicationActivities
        )
        controller.modalPresentationStyle = .pageSheet
        
        controller.completionWithItemsHandler = { (_, completed, _, _) in
            
            if completed {
                controller.dismiss(animated: true) {
                    
                    DispatchQueue.main.async {
                        viewModel.completion?()
                    }
                }
            }
        }
        
        return controller
    }
    
    func updateUIViewController(
        _ uiViewController: UIActivityViewController,
        context: UIViewControllerRepresentableContext<ActivityView>
    ) {}
}
