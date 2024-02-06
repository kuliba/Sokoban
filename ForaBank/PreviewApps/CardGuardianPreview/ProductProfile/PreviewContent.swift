//
//  PreviewContent.swift
//  CardGuardianPreview
//
//  Created by Andryusina Nataly on 06.02.2024.
//

import Foundation
import CardGuardianModule
import ProductProfile

extension ProductProfileViewModel.Product {
    
    static let cardUnblokedOnMain: Self = .init(isUnBlock: true, isShowOnMain: true)
    
    static let cardBlockedHideOnMain: Self = .init(isUnBlock: false, isShowOnMain: false)
}

extension ProductProfileView {
    
    static let cardUnblokedOnMain: Self = .init(
        viewModel: .init(
            product: .cardUnblokedOnMain,
            initialState: .init(),
            navigationStateManager: .init(
                reduce: ProductProfileReducer().reduce(_:_:),
                makeCardGuardianViewModel: { _ in
                    
                        .init(
                            initialState: .init(buttons: .preview),
                            reduce: CardGuardianReducer().reduce(_:_:),
                            handleEffect: { _,_ in }
                        )
                })))
    
    static let cardBlockedHideOnMain : Self = .init(
        viewModel: .init(
            product: .cardBlockedHideOnMain,
            initialState: .init(),
            navigationStateManager: .init(
                reduce: ProductProfileReducer().reduce(_:_:),
                makeCardGuardianViewModel: { _ in
                    
                        .init(
                            initialState: .init(buttons: .previewBlockHide),
                            reduce: CardGuardianReducer().reduce(_:_:),
                            handleEffect: { _,_ in }
                        )
                })))
}
