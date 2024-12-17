//
//  AnotherCardView+Legacy.swift
//  ForaBank
//
//  Created by Mikhail on 17.06.2022.
//

import Foundation
import SwiftUI

struct AnotherCardView: UIViewControllerRepresentable {
    
    let viewModel: AnotherCardViewModel
    
    func makeUIViewController(context: Context) -> MemeDetailVC {
        
        let popView = MemeDetailVC()
        popView.anotherCardModel = viewModel
        return popView
    }
    
    func updateUIViewController(_ uiViewController: MemeDetailVC, context: Context) {}
}


struct AnotherCardViewModel {
    
    var closeAction: () -> Void
}
