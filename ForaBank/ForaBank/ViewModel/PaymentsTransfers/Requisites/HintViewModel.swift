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
        
        if let image = UIImage(data: hintData.icon) {
            
            self.header = .init(icon: Image.init(uiImage: image), title: hintData.title, subtitle: hintData.subtitle)
        } else {
            
            self.header = .init(icon: .ic24Info, title: hintData.title, subtitle: hintData.subtitle)
        }
        
        self.content = hintData.hints.map({ContentViewModel.init(title: $0.title, description: $0.description)})
    }
}
