//
//  FooterState.swift
//
//
//  Created by Дмитрий Савушкин on 05.03.2024.
//

import SwiftUI

public enum FooterState {
     
    case footer(title: String, description: String, subtitle: String)
    case failure(image: Image, description: String)
}
