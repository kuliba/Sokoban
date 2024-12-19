//
//  ClientInformListDataState.swift
//  Vortex
//
//  Created by Nikolay Pochekuev on 10.10.2024.
//

import SwiftUI

public enum ClientInformListDataState {
    
    case single(Single)
    case multiple(Multiple)
    
    public struct Single {
        
        public let label: Label<String>
        public let text: String
        
        public init(label: Label<String>, text: String) {
            
            self.label = label
            self.text = text
        }
    }
    
    public struct Multiple {
        
        public let label: Label<String>
        public let items: [Label<String>]
        
        public init(title: Label<String>, items: [Label<String>]) {
            self.label = title
            self.items = items
        }
    }
    
    public struct Label<Title>: Identifiable {
        
        public let id: UUID
        public let image: Image?
        public let title: Title
        public let url: URL?
        
        public init(
            id: UUID = .init(),
            image: Image?,
            title: Title,
            url: URL? = nil
        ) {
            self.id = id
            self.image = image
            self.title = title
            self.url = url
        }
    }
}

extension ClientInformListDataState {

    func navBarTitle() -> String {
        
        switch self {
        case .single(let singleInfo):
            return singleInfo.label.title
            
        case .multiple(let multipleInfo):
            return multipleInfo.label.title
        }
    }
}
