//
//  ConfirmCodeView.swift
//  ForaBank
//
//  Created by Andryusina Nataly on 26.07.2023.
//

import PinCodeUI
import SwiftUI

struct ConfirmCodeView: View {
    
    let phoneNumber: String
    let cardId: Int
    let actionType: ConfirmViewModel.CVVPinAction
    let reset: () -> Void
    let resendRequest: () -> Void

    var hasDefaultBackButton: Bool = false
    var handler: (String, @escaping (String?) -> Void) -> Void
    let showSpinner: () -> Void
    let resendRequestAfterClose: (Int, ConfirmViewModel.CVVPinAction) -> Void
    
    var body: some View {
        
        PinCodeUI.ConfirmView(
            viewModel: .init(
                phoneNumber: phoneNumber,
                cardId: cardId,
                actionType: actionType,
                handler: handler,
                showSpinner: showSpinner,
                resendRequestAfterClose: resendRequestAfterClose
            ),
            resendRequest: resendRequest
        )
        .if(!hasDefaultBackButton) { view in
            
            view
                .toolbar {
                    
                    ToolbarItem(placement: .navigationBarLeading) {
                        
                        Button(
                            action: reset,
                            label: {
                                Image.ic24ChevronLeft
                                    .aspectRatio(contentMode: .fit)
                            }
                        )
                        .buttonStyle(.plain)
                    }
                }
        }
    }
}

struct ConfirmCodeView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        Group {
            
            preview(
                hasDefaultBackButton: true,
                previewDisplayName: "Default back button"
            )

            preview(
                previewDisplayName: "Custom back button"
            )
        }
    }
    
    private static func preview (
        phoneNumber: String = "71234567899",
        cardId: Int = 1111111,
        actionType: ConfirmViewModel.CVVPinAction = .showCvv,
        reset: @escaping () -> Void = { },
        resendRequest: @escaping () -> Void = { },
        hasDefaultBackButton: Bool = false,
        previewDisplayName: String
    ) -> some View {
        
        NavigationView{
            
            ConfirmCodeView(
                phoneNumber: phoneNumber, 
                cardId: cardId,
                actionType: actionType,
                reset: reset,
                resendRequest: resendRequest,
                hasDefaultBackButton: hasDefaultBackButton,
                handler: { _, _ in },
                showSpinner: {},
                resendRequestAfterClose: {_,_  in }
            )
        }
        .previewDisplayName(previewDisplayName)
        .previewLayout(.sizeThatFits)
    }
}
