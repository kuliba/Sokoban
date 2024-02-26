//
//  File.swift
//  
//
//  Created by Дмитрий Савушкин on 09.02.2024.
//

import Foundation

public struct NoCompanyInListViewModel {
 
    let title: String
    let description: String
    let subtitle: String
    let buttons: [ButtonSimpleViewModel]
    
    public init(
        title: String,
        description: String,
        subtitle: String,
        buttons: [ButtonSimpleViewModel]
    ) {
        self.title = title
        self.description = description
        self.subtitle = subtitle
        self.buttons = buttons
    }
}
