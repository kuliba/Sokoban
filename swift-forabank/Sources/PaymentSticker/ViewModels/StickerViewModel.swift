//
//  StickerViewModel.swift
//  
//
//  Created by Дмитрий Савушкин on 10.10.2023.
//

import Foundation

public struct StickerViewModel {
    
    let header: HeaderViewModel
    let sticker: ImageData
    let options: [OptionViewModel]
    
    public init(
        header: HeaderViewModel,
        sticker: ImageData,
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
        public let icon: ImageData
        public let description: String
        public let iconColor: String
    }
}

//MARK: Helpers

extension StickerViewModel {
    
    public init(parameter: Operation.Parameter.Sticker) {
        self.header = .init(
            title: parameter.title,
            detailTitle: parameter.description
        )
        
        self.sticker = .named("StickerPreview")
        self.options = parameter.options.map {
            
            .init(
                title: $0.title,
                icon: .named("Arrow Circle"),
                description: "\($0.description.dropLast(2)) ₽",
                iconColor: ""
            )
        }
    }
}
