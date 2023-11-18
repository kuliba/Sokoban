//
//  StickerViewModel.swift
//  
//
//  Created by Дмитрий Савушкин on 10.10.2023.
//

import Foundation
import SwiftUI

public struct StickerViewModel {
    
    let header: HeaderViewModel
    let sticker: Image
    let options: [OptionViewModel]
    
    public init(
        header: HeaderViewModel,
        sticker: Image,
        options: [OptionViewModel]
    ) {
        self.header = header
        self.sticker = sticker
        self.options = options
    }
}

extension StickerViewModel {
    
    public struct HeaderViewModel {
        
        let title: String
        let detailTitle: String
    }
    
    // MARK: - Option
    
    public struct OptionViewModel: Identifiable {

        public var id: String { title }
        public let title: String
        let icon: Image
        let description: String
        let iconColor: Color
    }
}
