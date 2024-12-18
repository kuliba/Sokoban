//
//  ClearBackgroundView.swift
//
//
//  Created by Valentin Ozerov on 11.12.2024.
//

import SwiftUI

extension BottomSheetView {
    
    struct ClearBackgroundView: UIViewControllerRepresentable {
        
        func makeUIViewController(context: Context) -> UIViewController {
            
            let controller = UIViewController(nibName: nil, bundle: nil)
            
            context.coordinator.parentObserver = controller.observe(\.parent, changeHandler: { vc, _ in
                
                vc.parent?.view.backgroundColor = .clear
            })
            
            return controller
        }
        
        func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
            
        }
        
        class Coordinator {
            
            var parentObserver: NSKeyValueObservation?
        }
        
        func makeCoordinator() -> Self.Coordinator { Coordinator() }
    }
}
