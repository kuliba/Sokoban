//
//  ViewComponents+navBar.swift
//  Vortex
//
//  Created by Igor Malyarov on 15.02.2025.
//

extension ViewComponents {
    
    @inlinable
    func navBarModelWithQR(
        title: String,
        subtitle: String? = nil,
        dismiss: @escaping () -> Void
    ) -> NavigationBarView.ViewModel {
        
        navBarModelWithBack(
            title: title,
            subtitle: subtitle,
            dismiss: dismiss,
            rightItem: .barcodeScanner { rootEvent(.scanQR) }
        )
    }
    
    @inlinable
    func navBarModelWithBack(
        title: String,
        subtitle: String? = nil,
        dismiss: @escaping () -> Void
    ) -> NavigationBarView.ViewModel {
        
        navBarModelWithBack(title: title, subtitle: subtitle, dismiss: dismiss, rightItems: [])
    }
    
    @inlinable
    func navBarModelWithBack(
        title: String,
        subtitle: String? = nil,
        dismiss: @escaping () -> Void,
        rightItem: NavigationBarView.ViewModel.ButtonItemViewModel
    ) -> NavigationBarView.ViewModel {
        
        navBarModelWithBack(title: title, subtitle: subtitle, dismiss: dismiss, rightItems: [rightItem])
    }
    
    @inlinable
    func navBarModelWithBack(
        title: String,
        subtitle: String? = nil,
        dismiss: @escaping () -> Void,
        rightItems: [NavigationBarView.ViewModel.ButtonItemViewModel]
    ) -> NavigationBarView.ViewModel {
        
        typealias BackButton = NavigationBarView.ViewModel.BackButtonItemViewModel
        
        return .init(
            title: title,
            subtitle: subtitle,
            leftItems: [BackButton(icon: .ic24ChevronLeft, action: dismiss)],
            rightItems: rightItems
        )
    }
}
