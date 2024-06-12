//
//  TransactionDetailButton.swift
//  ForaBank
//
//  Created by Igor Malyarov on 12.06.2024.
//

import ButtonWithSheet
import SwiftUI

struct TransactionDetailButton: View {
    
    let details: Details
    
    var body: some View {
        
        MagicButtonWithSheet(
            buttonLabel: buttonLabel,
            getValue: { $0(details) },
            makeValueView: makeDetailView
        )
    }
}

extension TransactionDetailButton {
    
    struct Details {
        
        let title = "Детали операции"
        let logo: Image?
        let cells: [Cell]
        
        typealias Cell = OperationDetailInfoViewModel.DefaultCellViewModel
    }
}

// MARK: - Previews

struct TransactionDetailButton_Previews: PreviewProvider {
    
    static var previews: some View {
        
        Group {
            button(details: .empty)
            button(details: .preview)
        }
    }
    
    static func button(
        details: TransactionDetailButton.Details
    ) -> some View {
        
        TransactionDetailButton(details: details)
    }
}

private extension TransactionDetailButton.Details {
    
    static let empty: Self = .init(logo: nil, cells: [])
    static let preview: Self = .init(logo: nil, cells: []) // TODO:
}

// MARK: - Helpers

private extension TransactionDetailButton {
    
    func buttonLabel() -> some View {
        
        buttonLabel(for: .details)
    }
    
    func buttonLabel(
        for option: Payments.ParameterSuccessOptionButtons.Option
    ) -> some View {
        
        PaymentsSuccessOptionButtonsView.ButtonView.ButtonLabel(
            title: option.title,
            icon: option.icon
        )
    }
    
    func makeDetailView(
        details: Details,
        dismiss: @escaping () -> Void
    ) -> some View {
        
        OperationDetailInfoInternalView(
            title: details.title,
            logo: details.logo,
            cells: details.cells,
            dismissAction: dismiss
        )
    }
}
