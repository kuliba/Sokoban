//
//  OptionButtonView.swift
//  
//
//  Created by Дмитрий Савушкин on 27.08.2024.
//

import Foundation
import SwiftUI

struct OptionButtonView: View {
    
    var viewModel: OptionsViewModel
    
    var body: some View {
        
        Button(
            action: viewModel.action,
            label: label
        )
    }
    
    @ViewBuilder
    private func label() -> some View {
        
        Text(viewModel.title())
            .foregroundColor(viewModel.isSelected ? Color.white : Color.black)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Capsule().foregroundColor(viewModel.isSelected ? Color.black.opacity(0.9) : Color.gray.opacity(0.1)))
        
    }
}

public struct OptionsViewModel: Identifiable {

    public var id: String { type.rawValue }
    let title: () -> String
    let type: Kind
    let isSelected: Bool
    let action: () -> Void
    
    enum Kind: String {
        case week = "Неделя"
        case month = "Месяц"
        case dates
    }
}
