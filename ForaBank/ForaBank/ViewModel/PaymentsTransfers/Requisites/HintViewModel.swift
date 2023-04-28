//
//  HintViewModel.swift
//  ForaBank
//
//  Created by Дмитрий Савушкин on 14.12.2022.
//

import Foundation
import SwiftUI

struct HintViewModel {
    
    let header: HeaderViewModel
    let content: [ContentViewModel]
    
    struct HeaderViewModel {
        
        let icon: Image
        let title: String
        let subtitle: String
    }
    
    struct ContentViewModel: Identifiable {
        
        let id = UUID()
        let title: String
        let description: String
    }
    
    init(header: HeaderViewModel, content: [ContentViewModel]) {
        
        self.header = header
        self.content = content
    }
    
    init(hintData: Payments.ParameterInput.Hint) {

        self.header = .init(icon: hintData.icon.image ?? .ic24Info, title: hintData.title, subtitle: hintData.subtitle)
        self.content = hintData.hints.map(ContentViewModel.init(content:))
    }
}

private extension HintViewModel.ContentViewModel {
    
    init(content: Payments.ParameterInput.Hint.Content) {
        
        self.init(title: content.title, description: content.description)
    }
}

