//
//  ViewComponents+navBar.swift
//  Vortex
//
//  Created by Igor Malyarov on 15.02.2025.
//

import SwiftUI

extension ViewComponents {
    
    @inlinable
    func navBarModelWithQR(
        title: String,
        subtitle: String? = nil,
        subtitleForeground: Color = .textSecondary,
        dismiss: @escaping () -> Void,
        scanQR: (() -> Void)? = nil
    ) -> NavigationBarView.ViewModel {
        
        let scanQR = scanQR ?? { rootEvent(.scanQR) }
        
        return navBarModelWithBack(
            title: title,
            subtitle: subtitle,
            subtitleForeground: subtitleForeground,
            dismiss: dismiss,
            rightItem: .barcodeScanner(action: scanQR)
        )
    }
    
    @inlinable
    func navBarModelWithBack(
        title: String,
        subtitle: String? = nil,
        subtitleForeground: Color = .textSecondary,
        dismiss: @escaping () -> Void
    ) -> NavigationBarView.ViewModel {
        
        navBarModelWithBack(
            title: title,
            subtitle: subtitle,
            subtitleForeground: subtitleForeground,
            dismiss: dismiss,
            rightItems: []
        )
    }
    
    @inlinable
    func navBarModelWithBack(
        title: String,
        subtitle: String? = nil,
        subtitleForeground: Color = .textSecondary,
        dismiss: @escaping () -> Void,
        rightItem: NavigationBarView.ViewModel.ButtonItemViewModel
    ) -> NavigationBarView.ViewModel {
        
        navBarModelWithBack(
            title: title,
            subtitle: subtitle,
            subtitleForeground: subtitleForeground,
            dismiss: dismiss,
            rightItems: [rightItem]
        )
    }
    
    @inlinable
    func navBarModelWithBack(
        title: String,
        subtitle: String? = nil,
        subtitleForeground: Color = .textSecondary,
        dismiss: @escaping () -> Void,
        rightItems: [NavigationBarView.ViewModel.ButtonItemViewModel]
    ) -> NavigationBarView.ViewModel {
        
        typealias BackButton = NavigationBarView.ViewModel.BackButtonItemViewModel
        
        return .init(
            title: title,
            subtitle: subtitle,
            leftItems: [BackButton(icon: .ic24ChevronLeft, action: dismiss)],
            rightItems: rightItems,
            subtitleForeground: subtitleForeground
        )
    }
}
