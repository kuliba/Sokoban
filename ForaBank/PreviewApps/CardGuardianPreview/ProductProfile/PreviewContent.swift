//
//  PreviewContent.swift
//  CardGuardianPreview
//
//  Created by Andryusina Nataly on 06.02.2024.
//

import Foundation
import CardGuardianModule
import ProductProfile

extension ProductProfileView {
    
    static let cardUnblokedOnMain: Self = .init(
        viewModel: .init(
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
    
    static let cardBlockedUnlockNotAvailable : Self = .init(
        viewModel: .init(
            initialState: .init(),
            navigationStateManager: .init(
                reduce: ProductProfileReducer().reduce(_:_:),
                makeCardGuardianViewModel: { _ in
                    
                        .init(
                            initialState: .init(buttons: .previewBlockUnlockNotAvailable),
                            reduce: CardGuardianReducer().reduce(_:_:),
                            handleEffect: { _,_ in }
                        )
                })))

}
