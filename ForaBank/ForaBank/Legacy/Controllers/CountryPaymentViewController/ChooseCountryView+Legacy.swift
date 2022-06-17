//
//  ChooseCountryView+Legacy.swift
//  ForaBank
//
//  Created by Mikhail on 14.06.2022.
//

import Foundation
import SwiftUI

struct ChooseCountryView: UIViewControllerRepresentable {
    
    let viewModel: ChooseCountryViewModel
    
    func makeUIViewController(context: Context) -> UINavigationController {
        
        let controller = ChooseCountryTableViewController()
        controller.viewModel = viewModel
        let navigation = UINavigationController(rootViewController: controller)
        return navigation
    }
    
    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {}
}

struct ChooseCountryViewModel {
    
    var closeAction: () -> Void
}
