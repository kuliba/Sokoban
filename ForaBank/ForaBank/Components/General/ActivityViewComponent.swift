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
        
        var activityItems: [Any]
        var applicationActivities: [UIActivity]? = nil
    }
}

struct ActivityView: UIViewControllerRepresentable {
    
    var viewModel: ActivityView.ViewModel
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<ActivityView>) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: viewModel.activityItems, applicationActivities: viewModel.applicationActivities)
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: UIViewControllerRepresentableContext<ActivityView>) {}
    
}
