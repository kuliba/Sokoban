//
//  ChooseCountryView+Legacy.swift
//  ForaBank
//
//  Created by Mikhail on 14.06.2022.
//

import Foundation
import SwiftUI

struct ChooseCountryView: UIViewControllerRepresentable {
    
    let viewModel: OperatorsViewModel
    
    func makeUIViewController(context: Context) -> UINavigationController {
        
        let controller = ChooseCountryTableViewController()
        controller.viewModel = viewModel
        
        context.coordinator.parentObserver = controller.observe(\.parent, changeHandler: { vc, _ in
            
            vc.navigationItem.searchController = vc.navigationItem.searchController
            vc.parent?.navigationItem.hidesSearchBarWhenScrolling = vc.navigationItem.hidesSearchBarWhenScrolling
            vc.parent?.navigationItem.leftBarButtonItem = vc.navigationItem.leftBarButtonItem
            vc.parent?.navigationItem.rightBarButtonItems = vc.navigationItem.rightBarButtonItems
        })
        
        let navVc = UINavigationController(rootViewController: controller)
        return navVc
    }
    
    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {}
    
    class Coordinator {
        
        var parentObserver: NSKeyValueObservation?
    }
    
    func makeCoordinator() -> Self.Coordinator { Coordinator() }
}
