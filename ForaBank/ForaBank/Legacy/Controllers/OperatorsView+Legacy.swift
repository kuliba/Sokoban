//
//  OperatorsView.swift
//  ForaBank
//
//  Created by Константин Савялов on 20.06.2022.
//

import Foundation
import SwiftUI

struct OperatorsView: UIViewControllerRepresentable {
    
    let viewModel: OperatorsViewModel
 
    func makeUIViewController(context: Context) -> InternetTVMainController {
        
        let vc = InternetTVMainController.storyboardInstance()!
        return vc
    }
    
    func updateUIViewController(_ uiViewController: InternetTVMainController, context: Context) {}
}

struct OperatorsViewModel {

    var closeAction: () -> Void
}
