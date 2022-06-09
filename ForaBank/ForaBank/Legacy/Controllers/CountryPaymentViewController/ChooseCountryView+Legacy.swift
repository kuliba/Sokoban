//
//  ChooseCountryView.swift
//  ForaBank
//
//  Created by Mikhail on 09.06.2022.
//

import Foundation
import SwiftUI

struct ChooseCountryView: UIViewControllerRepresentable {
    
    func makeUIViewController(context: Context) -> ChooseCountryTableViewController {
        
        let controller = ChooseCountryTableViewController()
        
        return controller
    }
    
    func updateUIViewController(_ uiViewController: ChooseCountryTableViewController, context: Context) {}
}
