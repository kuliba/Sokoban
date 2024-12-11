//
//  ClientInformZoneTypes.swift
//  Vortex
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
        let text: String
        let url: URL?

        init(
            label: Label<String>,
            text: String,
            url: URL? = nil
        ) {
            self.label = label
            self.text = text
            self.url = url
        }
    }
    
    struct Multiple {
        
        let title: Label<String>
        let items: [Label<String>]
        
        init(title: Label<String>, items: [Label<String>]) {
            self.title = title
            self.items = items
        }
    }
    
    struct Label<Title>: Identifiable {
        
        let id: UUID
        let image: Image?
        let title: Title
        let url: URL?

        init(
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
