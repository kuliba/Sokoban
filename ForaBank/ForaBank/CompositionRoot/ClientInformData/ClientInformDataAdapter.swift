//
//  ClientInformData.swift
//  ForaBank
//
//  Created by Nikolay Pochekuev on 22.10.2024.
//

import Foundation
import SwiftUI
//import ClientInformList

struct GetAuthorizedZoneClientInformData: Equatable {
    
    let title: String
    let image: Image
    let text: AttributedString
    let url: URL?
}

extension ClientInformListDataState {
    
    init?(
        _ array: [GetAuthorizedZoneClientInformData],
        infoLabel: ClientInformListDataState.Label<String>
    ) {
        
        switch (array.count, array.first) {
        case (0, .none):
            return nil
            
        case let (1, .some(item)):
            self = .single(.init(
                label: .init(
                    image: item.image,
                    title: item.title
                ),
                text: item.text
            ))
            
        default:
            self = .multiple(.init(
                title: infoLabel,
                items: array.map {
                    
                    return .init(image: $0.image, title: $0.text)
                }
            ))
        }
    }
}
