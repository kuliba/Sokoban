//
//  StickerViewModel.swift
//  
//
//  Created by Дмитрий Савушкин on 10.10.2023.
//

import Foundation
import SwiftUI

struct StickerViewModel {
    
    let header: HeaderViewModel
    let options: [OptionViewModel]
}

extension StickerViewModel {
    
    struct HeaderViewModel {
        
        let title: String
        let detailTitle: String
    }
    
    // MARK: - Option
    
    struct OptionViewModel: Identifiable {

        public var id: String { title }
        let title: String
        let icon: Image
        let description: String
        let iconColor: Color
    }
}
