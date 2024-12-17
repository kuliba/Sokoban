//
//  ComposedPaymentsTransfersTransfersContentView.swift
//  ForaBank
//
//  Created by Igor Malyarov on 13.11.2024.
//

import PayHub
import RxViewModel
import SwiftUI

struct ComposedPaymentsTransfersTransfersContentView: View {
    
    let content: Content
    
    var body: some View {
        
        RxWrapperView(model: content) { state, event in
            
            VStack {
                
                PTSectionTransfersButtonsView(
                    title: PaymentsTransfersSectionType.transfers.name,
                    buttons: state.buttonTypes.map { type in
                        
                        return .init(type: type) {
                            
                            event(.select(.buttonType(type)))
                        }
                    }
                )
            }
        }
    }
}

extension ComposedPaymentsTransfersTransfersContentView {
    
    typealias Domain = PaymentsTransfersPersonalTransfersDomain
    typealias Content = Domain.Content
}

private extension PickerContentState<PaymentsTransfersPersonalTransfersDomain.Select> {
    
    var buttonTypes: [PaymentsTransfersPersonalTransfersDomain.ButtonType] {
        
        elements.compactMap(\.type)
    }
}

private extension PaymentsTransfersPersonalTransfersDomain.Select {
    
    var type: PaymentsTransfersPersonalTransfersDomain.ButtonType? {
        
        guard case let .buttonType(buttonType) = self else { return nil }
        
        return buttonType
    }
}
