//
//  ViewComponents+c2gDetailsView.swift
//  Vortex
//
//  Created by Igor Malyarov on 18.02.2025.
//

import SwiftUI
import UIPrimitives

protocol TransactionDetailsProviding<TransactionDetails> {
    
    associatedtype TransactionDetails
    
    var transactionDetails: TransactionDetails { get }
}

protocol PaymentRequisitesProviding<PaymentRequisites> {
    
    associatedtype PaymentRequisites
    
    var paymentRequisites: PaymentRequisites { get }
}

extension PaymentRequisitesProviding
where PaymentRequisites == [DetailsCell.Field] {
    
    var shareItems: [String] { [shareItem] }
    
    private var shareItem: String {
        
        paymentRequisites
            .map { "\($0.title): \($0.value)" }
            .joined(separator: "\n")
    }
}

extension ViewComponents {
    
    @inlinable
    func c2gTransactionDetails(
        details: any TransactionDetailsProviding<[DetailsCell]>,
        dismiss: @escaping () -> Void
    ) -> some View {
        
        c2gDetailsView(details: details.transactionDetails)
            .navigationBarWithClose(
                title: "Детали операции",
                dismiss: dismiss,
                rightIcon: .ic24Sbp
            )
    }
    
    @inlinable
    func c2gPaymentRequisites(
        details: any PaymentRequisitesProviding<[DetailsCell.Field]>,
        dismiss: @escaping () -> Void
    ) -> some View {
        
        SharingView(shareItems: details.shareItems, config: .iVortex) { share in
            
            c2gDetailsView(details: details.paymentRequisites.map { .field($0) })
                .navigationBarWithClose(
                    title: "Реквизиты",
                    dismiss: dismiss,
                    rightButton: .init(icon: .ic24Share, action: share)
                )
        }
    }
    
    @inlinable
    func c2gDetailsView(
        details: [DetailsCell]
    ) -> some View {
        
        DetailsView(
            detailsCells: details,
            config: .iVortex,
            detailsCellView: detailsCellView
        )
        .safeAreaInset(edge: .bottom) {
            
            Image.ic72Sbp.renderingMode(.original)
        }
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
                details: PreviewDetails.preview,
                dismiss: {}
            )
            .previewDisplayName("c2gTransactionDetails")
            
            ViewComponents.preview.c2gPaymentRequisites(
                details: PreviewDetails.preview,
                dismiss: {}
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
    
    var transactionDetails: [DetailsCell] { .preview }
}

extension PreviewDetails: PaymentRequisitesProviding {
    
    var paymentRequisites: [DetailsCell.Field] {
        transactionDetails.compactMap(\.fieldCase)
    }
}

extension DetailsCell {
    
    var fieldCase: Field? {
        
        guard case let .field(field) = self
        else { return nil }
        
        return field
    }
}

extension [DetailsCell] {
    
    static let preview: Self = [
        .field(.init(
            image: .init(systemName: "calendar"),
            title: "Дата и время операции (МСК)",
            value: "06.05.2021 15:38:12")
        ),
        .field(.init(
            image: nil,
            title: "Назначение платежа",
            value: "Транспортный налог")
        ),
        .product(.preview)
    ]
}

extension DetailsCell.Product {
    
    static let preview: Self = .init(
        title: "Product Title",
        icon: .init(systemName: "creditcard"),
        name: "product name",
        formattedBalance: "$ 1 000.00",
        description: "- 3456"
    )
}
