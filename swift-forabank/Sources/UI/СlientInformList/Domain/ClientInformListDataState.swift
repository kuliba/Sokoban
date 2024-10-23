//
//  ClientInformListDataState.swift
//  ForaBank
//
//  Created by Nikolay Pochekuev on 10.10.2024.
//

import SwiftUI

@available(iOS 15, *)
public enum ClientInformListDataState {
    
    case single(Single)
    case multiple(Multiple)
    
    public struct Single {
        
        public let label: Label<String>
        public let text: AttributedString
        
        public init(label: Label<String>, text: AttributedString) {
            self.label = label
            self.text = text
        }
    }
    
    public struct Multiple {
        
        public let title: Label<String>
        public let items: [Label<AttributedString>]
        
        public init(title: Label<String>, items: [Label<AttributedString>]) {
            self.title = title
            self.items = items
        }
    }
    
    public struct Label<Title>: Identifiable {
        
        public let id = UUID()
        public let image: Image
        public let title: Title
        
        public init(image: Image, title: Title) {
            self.image = image
            self.title = title
        }
    }
}

@available(iOS 15, *)
extension ClientInformListDataState {
    
    func navBarTitle() -> String {
        
        switch self {
        case .single(let singleInfo):
            return singleInfo.label.title
            
        case .multiple(let multipleInfo):
            return multipleInfo.title.title
        }
    }
}
