//
//  C2BDetailsViewController+Legacy.swift
//  ForaBank
//
//  Created by Дмитрий on 27.07.2022.
//

import Foundation
import SwiftUI
import Combine

struct C2BDetailsView: UIViewControllerRepresentable {
    
    func makeUIViewController(context: Context) -> UIViewController {
        guard let controller = C2BDetailsViewController.storyboardInstance() else {
            return UIViewController()
        }
        
        controller.modalPresentationStyle = .fullScreen
                
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}

}
