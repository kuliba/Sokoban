//
//  ViewComponents+c2gDetailsView.swift
//  Vortex
//
//  Created by Igor Malyarov on 18.02.2025.
//

import SwiftUI

protocol TransactionDetailsProviding<TransactionDetails> {
    
    associatedtype TransactionDetails
    
    var transactionDetails: TransactionDetails { get }
}

protocol PaymentRequisitesProviding<PaymentRequisites> {
    
    associatedtype PaymentRequisites
    
    var paymentRequisites: PaymentRequisites { get }
}

extension ViewComponents {
    
    @inlinable
    func c2gTransactionDetails(
        details: any TransactionDetailsProviding<[DetailsCell]>
    ) -> some View {
        
        c2gDetailsView(details: details.transactionDetails)
    }
    
    @inlinable
    func c2gPaymentRequisites(
        details: any PaymentRequisitesProviding<[DetailsCell]>
    ) -> some View {
        
        c2gDetailsView(details: details.paymentRequisites)
    }
    
    @inlinable
    func c2gDetailsView(
        details: [DetailsCell]
    ) -> some View {
        
        DetailsView(
            detailsCells: details,
            config: .iVortex,
            detailsCellView: detailsCellView,
            footer: { Image.ic72Sbp.renderingMode(.original) }
        )
    }
    
    @inlinable
    func detailsCellView(
        cell: DetailsCell
    ) -> some View {
        
        DetailsCellView(cell: cell, config: .iVortex)
    }
}

// MARK: - Previews

struct C2GDetailsView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        Group {
            
            ViewComponents.preview.c2gTransactionDetails(
                details: PreviewDetails.preview
            )
            .previewDisplayName("c2gTransactionDetails")
            
            ViewComponents.preview.c2gPaymentRequisites(
                details: PreviewDetails.preview
            )
            .previewDisplayName("c2gPaymentRequisites")
        }
    }
}

private struct PreviewDetails {}

extension PreviewDetails {
    
    static let preview: Self = .init()
}

extension PreviewDetails: TransactionDetailsProviding {
    
    var transactionDetails: [DetailsCell] {
        
        [
            .init(image: .ic24Calendar, title: "Дата и время операции (МСК)", value: "06.05.2021 15:38:12"),
            .init(image: nil, title: "Назначение платежа", value: "Транспортный налог")
        ]
    }
}

extension PreviewDetails: PaymentRequisitesProviding {
    
    var paymentRequisites: [DetailsCell] { transactionDetails }
}
