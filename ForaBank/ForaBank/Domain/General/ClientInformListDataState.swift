//
//  ClientInformZoneTypes.swift
//  ForaBank
//
//  Created by Nikolay Pochekuev on 21.10.2024.
//

import SwiftUI

struct ClientAuthorizationState {
    
    var authorized: ClientInformListDataState?
    var notAuthorized: Void?
}

enum ClientInformListDataState {
    
    case single(Single)
    case multiple(Multiple)
    
    struct Single {
        
        let label: Label<String>
        let text: AttributedString
        
        init(label: Label<String>, text: AttributedString) {
            self.label = label
            self.text = text
        }
    }
    
    struct Multiple {
        
        let title: Label<String>
        let items: [Label<AttributedString>]
        
        init(title: Label<String>, items: [Label<AttributedString>]) {
            self.title = title
            self.items = items
        }
    }
    
    struct Label<Title>: Identifiable {
        
        let id: UUID
        let image: Image?
        let title: Title
        
        init(
            id: UUID = .init(),
            image: Image?,
            title: Title
        ) {
            self.id = id
            self.image = image
            self.title = title
        }
    }
}
