//
//  View+navigationBarWithBack.swift
//  ForaBank
//
//  Created by Igor Malyarov on 13.12.2023.
//

import SwiftUI
import UIPrimitives

extension View {
    
    func navigationBarWithBack(
        title: String,
        subtitle: String? = nil,
        dismiss: @escaping () -> Void
    ) -> some View {
        
        navigationBar(with: .init(
            title: title,
            subtitle: subtitle,
            leftItems: [
                backButton(action: dismiss)
            ]
        ))
    }
    
    func navigationBarWithBack(
        title: String,
        subtitle: String? = nil,
        dismiss: @escaping () -> Void,
        rightItem: NavigationBarView.ViewModel.ButtonItemViewModel
    ) -> some View {
        
        navigationBar(with: .init(
            title: title,
            subtitle: subtitle,
            leftItems: [
                backButton(action: dismiss)
            ],
            rightItems: [rightItem]
        ))
    }
    
    func navigationBarWithAsyncIcon(
        title: String,
        subtitle: String? = nil,
        dismiss: @escaping () -> Void,
        icon: UIPrimitives.AsyncImage,
        style: NavigationBarView.ViewModel.AsyncImageItemViewModel.Style = .normal
    ) -> some View {
        
        navigationBar(with: .init(
            title: title,
            subtitle: subtitle,
            leftItems: [
                backButton(action: dismiss)
            ],
            rightItems: [
                asyncImageModel(icon: icon, style: style)
            ]
        ))
    }
    
    private func backButton(
        action: @escaping () -> Void
    ) -> BackButton {
        
        return .init(icon: .ic24ChevronLeft, action: action)
    }
    
    private typealias BackButton = NavigationBarView.ViewModel.BackButtonItemViewModel
    
    private func asyncImageModel(
        icon: UIPrimitives.AsyncImage,
        style: NavigationBarView.ViewModel.AsyncImageItemViewModel.Style = .normal
    ) -> NavigationBarView.ViewModel.AsyncImageItemViewModel {
        
        return .init(icon: icon, style: style)
    }
}
