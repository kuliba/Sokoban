//
//  ConfirmCodeView.swift
//  Vortex
//
//  Created by Andryusina Nataly on 26.07.2023.
//

import PinCodeUI
import SwiftUI
import Tagged

struct ConfirmCodeView: View {
    
    let phoneNumber: PhoneDomain.Phone
    var newPin: PinDomain.NewPin = ""

    let cardId: CardDomain.CardId
    let actionType: ConfirmViewModel.CVVPinAction
    let reset: () -> Void
    let resendRequest: () -> Void

    var hasDefaultBackButton: Bool = false
    let handler: ConfirmViewModel.OtpHandler
    let handlerChangePin: ConfirmViewModel.ChangePinHandler?

    let showSpinner: () -> Void
    let resendRequestAfterClose: (CardDomain.CardId, ConfirmViewModel.CVVPinAction) -> Void
    
    var body: some View {
        
        PinCodeUI.ConfirmView(
            viewModel: .init(
                phoneNumber: phoneNumber,
                cardId: cardId,
                actionType: actionType,
                newPin: newPin,
                handler: handler,
                handlerChangePin: handlerChangePin,
                showSpinner: showSpinner,
                resendRequestAfterClose: resendRequestAfterClose
            ),
            resendRequest: resendRequest
        )
        .if(!hasDefaultBackButton) { view in
            
            VStack {
                Button(
                    action: reset,
                    label: {
                        Image.ic24ChevronLeft
                            .frame(width: 24, height: 24)
                            .aspectRatio(contentMode: .fit)
                    }
                )
                .buttonStyle(.plain)
                .padding(.top, 12)
                .padding(.leading, 20)
                .maxWidthLeadingFrame()
                view
            }
        }
        .frame(maxHeight: .infinity)
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
        phoneNumber: PhoneDomain.Phone = "71234567899",
        cardId: CardDomain.CardId = 1111111,
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
                handlerChangePin: {_,_ in },
                showSpinner: {},
                resendRequestAfterClose: {_,_  in }
            )
        }
        .previewDisplayName(previewDisplayName)
        .previewLayout(.sizeThatFits)
    }
}
