//
//  View+navigationBarWithBack.swift
//  ForaBank
//
//  Created by Igor Malyarov on 13.12.2023.
//

import SwiftUI

extension View {
    
    private typealias BackButton = NavigationBarView.ViewModel.BackButtonItemViewModel
    
    func navigationBarWithBack(
        title: String,
        dismiss: @escaping () -> Void
    ) -> some View {
        
        navigationBar(with: .init(
            title: title,
            leftItems: [
                backButton(action: dismiss)
            ]
        ))
    }
    
    func navigationBarWithBack(
        title: String,
        dismiss: @escaping () -> Void,
        rightItem: NavigationBarView.ViewModel.ButtonItemViewModel
    ) -> some View {
        
        navigationBar(with: .init(
            title: title,
            leftItems: [
                backButton(action: dismiss)
            ],
            rightItems: [rightItem]
        ))
    }
    
    private func backButton(
        action: @escaping () -> Void
    ) -> BackButton {
        
        return .init(icon: .ic24ChevronLeft, action: action)
    }
}
