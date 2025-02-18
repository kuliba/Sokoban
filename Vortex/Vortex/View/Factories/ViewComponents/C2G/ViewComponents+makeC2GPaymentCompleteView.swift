//
//  ViewComponents+makeC2GPaymentCompleteView.swift
//  Vortex
//
//  Created by Igor Malyarov on 13.02.2025.
//

import PaymentCompletionUI
import SharedConfigs
import SwiftUI

typealias C2GCompleteCover = C2GPaymentDomain.Navigation.Cover<C2GPaymentDomain.Navigation.C2GPaymentComplete>

extension ViewComponents {
    
    @inlinable
    func makeC2GPaymentCompleteView(
        cover: C2GCompleteCover,
        config: C2GPaymentCompleteViewConfig = .iVortex
    ) -> some View {
        
        makePaymentCompletionLayoutView(
            state: cover.completion,
            statusConfig: .c2g,
            // TODO: replace stub with buttons
            buttons: { Color.bgIconIndigoLight.frame(height: 92) },
            details: { makeC2GPaymentDetailsView(cover: cover, config: config) }
        ) {
            makeSPBFooter(isActive: true, event: goToMain, title: "На главный")
        }
    }
    
    @inlinable
    func makeC2GPaymentDetailsView(
        cover: C2GCompleteCover,
        config: C2GPaymentCompleteViewConfig
    ) -> some View {
        
        VStack(spacing: config.spacing) {
            
            cover.success.merchantName?.text(withConfig: config.merchantName)
            cover.success.purpose?.text(withConfig: config.purpose)
        }
    }
}

struct C2GPaymentCompleteViewConfig {
    
    let spacing: CGFloat
    let merchantName: TextConfig
    let purpose: TextConfig
}

private extension C2GCompleteCover {
    
    var completion: PaymentCompletion {
        
        return .init(
            formattedAmount: "12,345 £", // TODO: REPLACE STUBS with real data
            merchantIcon: nil,
            status: status
        )
    }
    
    var status: PaymentCompletion.Status {
        
        switch success.status {
        case .completed: return .completed
        case .inflight:  return .inflight
        case .rejected:  return .rejected
        }
    }
}

struct MakeC2GPaymentCompleteView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        Group {
            
            Group {
                
                completeView(.completedFull)
                    .previewDisplayName("Completed: Full")
                completeView(.completedNoAmount)
                    .previewDisplayName("Completed: No Amount")
                completeView(.completedNoMerchant)
                    .previewDisplayName("Completed: No Merchant")
                completeView(.completedNoMessage)
                    .previewDisplayName("Completed: No Message")
                completeView(.completedNoPurpose)
                    .previewDisplayName("Completed: No Purpose")
                completeView(.completedNoMerchantNoMessage)
                    .previewDisplayName("Completed: No Merchant & No Message")
                completeView(.completedMinimal)
                    .previewDisplayName("Completed: Minimal")
            }
            
            Group {
                
                completeView(.inflightFull)
                    .previewDisplayName("Inflight: Full")
                completeView(.inflightNoAmount)
                    .previewDisplayName("Inflight: No Amount")
                completeView(.inflightNoMerchant)
                    .previewDisplayName("Inflight: No Merchant")
                completeView(.inflightNoMessage)
                    .previewDisplayName("Inflight: No Message")
                completeView(.inflightNoPurpose)
                    .previewDisplayName("Inflight: No Purpose")
                completeView(.inflightNoMerchantNoMessage)
                    .previewDisplayName("Inflight: No Merchant & No Message")
                completeView(.inflightMinimal)
                    .previewDisplayName("Inflight: Minimal")
            }
            
            Group {
                
                completeView(.rejectedFull)
                    .previewDisplayName("Rejected: Full")
                completeView(.rejectedNoAmount)
                    .previewDisplayName("Rejected: No Amount")
                completeView(.rejectedNoMerchant)
                    .previewDisplayName("Rejected: No Merchant")
                completeView(.rejectedNoMessage)
                    .previewDisplayName("Rejected: No Message")
                completeView(.rejectedNoPurpose)
                    .previewDisplayName("Rejected: No Purpose")
                completeView(.rejectedNoMerchantNoMessage)
                    .previewDisplayName("Rejected: No Merchant & No Message")
                completeView(.rejectedMinimal)
                    .previewDisplayName("Rejected: Minimal")
            }
        }
    }
    
    private typealias Cover = C2GCompleteCover
    
    private static func completeView(
        _ cover: Cover
    ) -> some View {
        
        ViewComponents.preview.makeC2GPaymentCompleteView(
            cover: cover,
            config: .iVortex
        )
    }
}

private extension C2GCompleteCover {
    
    static var completedFull:                Self { make(.completedFull) }
    static var completedNoAmount:            Self { make(.completedNoAmount) }
    static var completedNoMerchant:          Self { make(.completedNoMerchant) }
    static var completedNoMessage:           Self { make(.completedNoMessage) }
    static var completedNoPurpose:           Self { make(.completedNoPurpose) }
    static var completedNoMerchantNoMessage: Self { make(.completedNoMerchantNoMessage) }
    static var completedMinimal:             Self { make(.completedMinimal) }
    
    static var inflightFull:                 Self { make(.inflightFull) }
    static var inflightNoAmount:             Self { make(.inflightNoAmount) }
    static var inflightNoMerchant:           Self { make(.inflightNoMerchant) }
    static var inflightNoMessage:            Self { make(.inflightNoMessage) }
    static var inflightNoPurpose:            Self { make(.inflightNoPurpose) }
    static var inflightNoMerchantNoMessage:  Self { make(.inflightNoMerchantNoMessage) }
    static var inflightMinimal:              Self { make(.inflightMinimal) }
    
    static var rejectedFull:                 Self { make(.rejectedFull) }
    static var rejectedNoAmount:             Self { make(.rejectedNoAmount) }
    static var rejectedNoMerchant:           Self { make(.rejectedNoMerchant) }
    static var rejectedNoMessage:            Self { make(.rejectedNoMessage) }
    static var rejectedNoPurpose:            Self { make(.rejectedNoPurpose) }
    static var rejectedNoMerchantNoMessage:  Self { make(.rejectedNoMerchantNoMessage) }
    static var rejectedMinimal:              Self { make(.rejectedMinimal) }
    
    private static func make(_ success: Success) -> Self {
        
        return .init(id: .init(), success: success)
    }
}

private extension C2GPaymentDomain.Navigation.C2GPaymentComplete {
    
    // ✅ COMPLETED STATUS
    static let completedFull: Self = .init(
        amount: 100.50,
        status: .completed,
        merchantName: "Merchant A",
        message: "Payment successful",
        paymentOperationDetailID: 1,
        purpose: "Purchase"
    )
    
    static let completedNoAmount: Self = .init(
        amount: nil,
        status: .completed,
        merchantName: "Merchant B",
        message: "Payment processed",
        paymentOperationDetailID: 2,
        purpose: "Subscription"
    )
    
    static let completedNoMerchant: Self = .init(
        amount: 75.00,
        status: .completed,
        merchantName: nil,
        message: "Transaction complete",
        paymentOperationDetailID: 3,
        purpose: "Service Payment"
    )
    
    static let completedNoMessage: Self = .init(
        amount: 50.00,
        status: .completed,
        merchantName: "Merchant C",
        message: nil,
        paymentOperationDetailID: 4,
        purpose: "Gift"
    )
    
    static let completedNoPurpose: Self = .init(
        amount: 125.00,
        status: .completed,
        merchantName: "Merchant D",
        message: "Transaction successful",
        paymentOperationDetailID: 5,
        purpose: nil
    )
    
    static let completedNoMerchantNoMessage: Self = .init(
        amount: 90.00,
        status: .completed,
        merchantName: nil,
        message: nil,
        paymentOperationDetailID: 6,
        purpose: "Utilities"
    )
    
    static let completedMinimal: Self = .init(
        amount: nil,
        status: .completed,
        merchantName: nil,
        message: nil,
        paymentOperationDetailID: 7,
        purpose: nil
    )
    
    
    // ✅ INFLIGHT STATUS
    static let inflightFull: Self = .init(
        amount: 200.00,
        status: .inflight,
        merchantName: "Merchant E",
        message: "Payment is being processed",
        paymentOperationDetailID: 8,
        purpose: "Transfer"
    )
    
    static let inflightNoAmount: Self = .init(
        amount: nil,
        status: .inflight,
        merchantName: "Merchant F",
        message: "Awaiting confirmation",
        paymentOperationDetailID: 9,
        purpose: "Deposit"
    )
    
    static let inflightNoMerchant: Self = .init(
        amount: 150.00,
        status: .inflight,
        merchantName: nil,
        message: "Processing transaction",
        paymentOperationDetailID: 10,
        purpose: "Bill Payment"
    )
    
    static let inflightNoMessage: Self = .init(
        amount: 175.00,
        status: .inflight,
        merchantName: "Merchant G",
        message: nil,
        paymentOperationDetailID: 11,
        purpose: "Subscription Renewal"
    )
    
    static let inflightNoPurpose: Self = .init(
        amount: 120.00,
        status: .inflight,
        merchantName: "Merchant H",
        message: "Payment pending",
        paymentOperationDetailID: 12,
        purpose: nil
    )
    
    static let inflightNoMerchantNoMessage: Self = .init(
        amount: 130.00,
        status: .inflight,
        merchantName: nil,
        message: nil,
        paymentOperationDetailID: 13,
        purpose: "Loan Payment"
    )
    
    static let inflightMinimal: Self = .init(
        amount: nil,
        status: .inflight,
        merchantName: nil,
        message: nil,
        paymentOperationDetailID: 14,
        purpose: nil
    )
    
    
    // ✅ REJECTED STATUS
    static let rejectedFull: Self = .init(
        amount: 300.75,
        status: .rejected,
        merchantName: "Merchant I",
        message: "Payment failed due to insufficient funds",
        paymentOperationDetailID: 15,
        purpose: "Online Shopping"
    )
    
    static let rejectedNoAmount: Self = .init(
        amount: nil,
        status: .rejected,
        merchantName: "Merchant J",
        message: "Transaction declined",
        paymentOperationDetailID: 16,
        purpose: "Loan Payment"
    )
    
    static let rejectedNoMerchant: Self = .init(
        amount: 125.00,
        status: .rejected,
        merchantName: nil,
        message: "Card not accepted",
        paymentOperationDetailID: 17,
        purpose: "Charity Donation"
    )
    
    static let rejectedNoMessage: Self = .init(
        amount: 140.00,
        status: .rejected,
        merchantName: "Merchant K",
        message: nil,
        paymentOperationDetailID: 18,
        purpose: "Food Order"
    )
    
    static let rejectedNoPurpose: Self = .init(
        amount: 110.00,
        status: .rejected,
        merchantName: "Merchant L",
        message: "Insufficient funds",
        paymentOperationDetailID: 19,
        purpose: nil
    )
    
    static let rejectedNoMerchantNoMessage: Self = .init(
        amount: 135.00,
        status: .rejected,
        merchantName: nil,
        message: nil,
        paymentOperationDetailID: 20,
        purpose: "Membership Fee"
    )
    
    static let rejectedMinimal: Self = .init(
        amount: nil,
        status: .rejected,
        merchantName: nil,
        message: nil,
        paymentOperationDetailID: 21,
        purpose: nil
    )
}
