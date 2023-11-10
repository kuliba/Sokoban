//
//  ActivityViewComponent.swift
//  ForaBank
//
//  Created by Mikhail on 21.06.2022.
//

import UIKit
import SwiftUI

extension ActivityView {
    
    struct ViewModel {
        
        let activityItems: [Any]
        let applicationActivities: [UIActivity]? = nil
    }
}

struct ActivityView: UIViewControllerRepresentable {
    
    let viewModel: ActivityView.ViewModel
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<ActivityView>) -> UIActivityViewController {
        
        return .init(
            activityItems: viewModel.activityItems,
            applicationActivities: viewModel.applicationActivities
        )
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: UIViewControllerRepresentableContext<ActivityView>) {}
}
