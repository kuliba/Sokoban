//
//  View+navigationBar.swift
//  ForaBank
//
//  Created by Igor Malyarov on 13.12.2023.
//

import SwiftUI

extension View {
    
    private typealias BackButton = NavigationBarView.ViewModel.BackButtonItemViewModel
    
    func navigationBar(
        _ title: String,
        dismiss: @escaping () -> Void
    ) -> some View {
        
        navigationBar(with: .init(
            title: title,
            leftItems: [
                BackButton(
                    icon: .ic24ChevronLeft,
                    action: dismiss
                )
            ]
        ))
    }
}
