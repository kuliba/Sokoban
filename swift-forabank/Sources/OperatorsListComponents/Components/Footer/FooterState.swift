//
//  FooterState.swift
//
//
//  Created by Дмитрий Савушкин on 05.03.2024.
//

import SwiftUI

public enum FooterState {
     
    case footer(title: String, description: String, buttons: [ButtonSimpleViewModel]?, subtitle: String)
    case searchResult(image: Image, description: String, button: ButtonSimpleViewModel)
}
