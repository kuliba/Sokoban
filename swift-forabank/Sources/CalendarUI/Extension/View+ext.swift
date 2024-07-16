//
//  View+ext.swift
//
//
//  Created by Дмитрий Савушкин on 22.05.2024.
//

import SwiftUI

extension View {
    
    @ViewBuilder func active(if condition: Bool) -> some View {
        if condition { self }
    }
}
