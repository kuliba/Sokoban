//
//  View+card.swift
//
//
//  Created by Andryusina Nataly on 19.03.2024.
//

import SwiftUI

extension View {
    
    func card(
        isChecked: Bool,
        isUpdating: Bool,
        activationView: some View = EmptyView(),
        statusView: some View = EmptyView(),
        config: Config,
        isFrontView: Bool,
        action: @escaping () -> Void
    ) -> some View {
                
        return self
            .modifier(
                CardModifier(
                    isChecked: isChecked,
                    isUpdating: isUpdating,
                    isFrontView: isFrontView,
                    config: config,
                    activationView: {
                        activationView
                    },
                    statusView: {
                        statusView
                    }
                )
            )
            .onTapGesture(perform: action)
    }
}

