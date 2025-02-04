//
//  SelectedOptionView.swift
//
//
//  Created by Valentin Ozerov on 28.01.2025.
//

import SwiftUI

struct SelectedOptionView: View {
    
    let optionTitle: String
    
    var body: some View {
        
        Text(optionTitle)
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(Rectangle())
    }
}
