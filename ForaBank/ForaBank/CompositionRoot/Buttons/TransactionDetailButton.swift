//
//  TransactionDetailButton.swift
//  ForaBank
//
//  Created by Igor Malyarov on 12.06.2024.
//

import ButtonWithSheet
import SwiftUI

struct TransactionDetailButton: View {
    
    let getDetail: GetDetail
    
    var body: some View {
        
        MagicButtonWithSheet(
            buttonLabel: buttonLabel,
            getValue: getDetail,
            makeValueView: makeDetailView
        )
    }
}

extension TransactionDetailButton {
    
    typealias GetDetail = (@escaping (Detail?) -> Void) -> Void
    
    struct Detail {
        
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
            button(detail: nil)
            button(detail: .empty)
            button(detail: .preview)
        }
    }
    
    static func button(
        detail: TransactionDetailButton.Detail?
    ) -> some View {
        
        TransactionDetailButton(
            getDetail: { completion in
                
                DispatchQueue.main.delay(for: .seconds(1)) {
                    
                    completion(detail)
                }
            }
        )
    }
}

private extension TransactionDetailButton.Detail {
    
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
        detail: Detail,
        dismiss: @escaping () -> Void
    ) -> some View {
        
        OperationDetailInfoInternalView(
            title: detail.title,
            logo: detail.logo,
            cells: detail.cells,
            dismissAction: dismiss
        )
    }
}
