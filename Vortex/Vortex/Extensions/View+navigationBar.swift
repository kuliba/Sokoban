//
//  View+navigationBarWithBack.swift
//  Vortex
//
//  Created by Igor Malyarov on 13.12.2023.
//

import SwiftUI
import UIPrimitives

extension View {
    
    func navigationBarWithBack(
        title: String,
        subtitle: String? = nil,
        subtitleForegroundColor: Color,
        dismiss: @escaping () -> Void
    ) -> some View {
        
        navigationBar(with: .init(
            title: title,
            subtitle: subtitle,
            leftItems: [
                backButton(action: dismiss)
            ],
            subtitleForeground: subtitleForegroundColor
        ))
    }
    
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
        rightItem: NavigationBarView.ViewModel.ButtonItemViewModel,
        backgroundColor: Color = .clear
    ) -> some View {
        
        navigationBar(
            with: .init(
                title: title,
                subtitle: subtitle,
                leftItems: [
                    backButton(action: dismiss)
                ],
                rightItems: [rightItem]
            ),
            backgroundColor: backgroundColor
        )
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
    
    func navigationBarWithClose(
        title: String,
        subtitle: String? = nil,
        dismiss: @escaping () -> Void,
        rightIcon icon: Image,
        style: Payments.ParameterHeader.Style = .large,
        backgroundColor: Color = .clear
    ) -> some View {
        
        navigationBar(
            with: .init(
                title: title,
                subtitle: subtitle,
                leftItems: [
                    closeButton(action: dismiss)
                ],
                rightItems: [NavigationBarView.ViewModel.IconItemViewModel(icon: icon, style: style)]
            ),
            backgroundColor: backgroundColor
        )
    }
    
    func navigationBarWithClose(
        title: String,
        subtitle: String? = nil,
        dismiss: @escaping () -> Void,
        backgroundColor: Color = .clear
    ) -> some View {
        
        navigationBar(
            with: .init(
                title: title,
                subtitle: subtitle,
                leftItems: [
                    closeButton(action: dismiss)
                ],
                rightItems: []
            ),
            backgroundColor: backgroundColor
        )
    }
    
    func navigationBarWithClose(
        title: String,
        subtitle: String? = nil,
        dismiss: @escaping () -> Void,
        rightButton: NavigationBarView.ViewModel.ButtonItemViewModel,
        backgroundColor: Color = .clear
    ) -> some View {
        
        navigationBar(
            with: .init(
                title: title,
                subtitle: subtitle,
                leftItems: [
                    closeButton(action: dismiss)
                ],
                rightItems: [rightButton]
            ),
            backgroundColor: backgroundColor
        )
    }
    
    private func backButton(
        action: @escaping () -> Void
    ) -> BackButton {
        
        return .init(icon: .ic24ChevronLeft, action: action)
    }
    
    private func closeButton(
        action: @escaping () -> Void
    ) -> BackButton {
        
        return .init(icon: .ic24Close, action: action)
    }
    
    private typealias BackButton = NavigationBarView.ViewModel.BackButtonItemViewModel
    
    private func asyncImageModel(
        icon: UIPrimitives.AsyncImage,
        style: NavigationBarView.ViewModel.AsyncImageItemViewModel.Style = .normal
    ) -> NavigationBarView.ViewModel.AsyncImageItemViewModel {
        
        return .init(icon: icon, style: style)
    }
}
