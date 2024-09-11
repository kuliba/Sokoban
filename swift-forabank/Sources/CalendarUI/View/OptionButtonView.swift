//
//  OptionButtonView.swift
//  
//
//  Created by Дмитрий Савушкин on 27.08.2024.
//

import Foundation
import SwiftUI

struct OptionButtonState {

    let title: String
    let type: FilterState.Period
    let range: MDateRange?
}

struct OptionButtonView: View {
    
    typealias State = OptionButtonState
    
    let state: State
    
    var body: some View {
        
        if state.type == .dates,
           let lowerDate = state.range?.lowerDate,
           let upperDate = state.range?.upperDate {
            
            Text("\(DateFormatter.shortDate.string(from: lowerDate)) - \(DateFormatter.shortDate.string(from: upperDate))")
            
        } else {
            
            Text(state.title)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
        }
    }
}

public struct OptionsViewModel: Identifiable {

    public var id: String { type.rawValue }
    let title: () -> String
    let type: Kind
    var isSelected: Bool
    let action: () -> Void
    
    public enum Kind: String {
        case week = "Неделя"
        case month = "Месяц"
        case dates
    }
}
