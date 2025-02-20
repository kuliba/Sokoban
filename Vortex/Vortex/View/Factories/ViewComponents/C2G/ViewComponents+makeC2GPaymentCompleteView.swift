//
//  ViewComponents+makeC2GPaymentCompleteView.swift
//  Vortex
//
//  Created by Igor Malyarov on 13.02.2025.
//

import PaymentCompletionUI
import SharedConfigs
import SwiftUI
import UIPrimitives

typealias C2GCompleteCover = C2GPaymentDomain.Navigation.Cover<C2GPaymentDomain.C2GPaymentComplete>

extension ViewComponents {
    
    @inlinable
    func makeC2GPaymentCompleteView(
        cover: C2GCompleteCover,
        config: C2GPaymentCompleteViewConfig = .iVortex
    ) -> some View {
        
        makePaymentCompletionLayoutView(
            state: cover.completion,
            statusConfig: .c2g,
            buttons: { makeC2GPaymentCompleteButtonsView(cover.content) },
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
            
            let response = cover.content.state.response
            
            response.merchantName?.text(withConfig: config.merchantName)
            response.purpose?.text(withConfig: config.purpose)
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
            formattedAmount: content.state.response.formattedAmount,
            merchantIcon: nil,
            status: status
        )
    }
    
    var status: PaymentCompletion.Status {
        
        switch content.state.response.status {
        case .completed: return .completed
        case .inflight:  return .inflight
        case .rejected:  return .rejected
        }
    }
}

struct MakeC2GPaymentCompleteView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        Group {
            
            completeView(.failure)
                .previewDisplayName("Operation Details Failure")
            
            completeView(.loading)
                .previewDisplayName("Loading Operation Details")
            
            completeView(.pending)
                .previewDisplayName("Pending")
            
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
                //    completeView(.inflightNoAmount)
                //        .previewDisplayName("Inflight: No Amount")
                //    completeView(.inflightNoMerchant)
                //        .previewDisplayName("Inflight: No Merchant")
                //    completeView(.inflightNoMessage)
                //        .previewDisplayName("Inflight: No Message")
                //    completeView(.inflightNoPurpose)
                //        .previewDisplayName("Inflight: No Purpose")
                //    completeView(.inflightNoMerchantNoMessage)
                //        .previewDisplayName("Inflight: No Merchant & No Message")
                //    completeView(.inflightMinimal)
                //        .previewDisplayName("Inflight: Minimal")
            }
            
            Group {
                
                completeView(.rejectedFull)
                    .previewDisplayName("Rejected: Full")
                //    completeView(.rejectedNoAmount)
                //        .previewDisplayName("Rejected: No Amount")
                //    completeView(.rejectedNoMerchant)
                //        .previewDisplayName("Rejected: No Merchant")
                //    completeView(.rejectedNoMessage)
                //        .previewDisplayName("Rejected: No Message")
                //    completeView(.rejectedNoPurpose)
                //        .previewDisplayName("Rejected: No Purpose")
                //    completeView(.rejectedNoMerchantNoMessage)
                //        .previewDisplayName("Rejected: No Merchant & No Message")
                //    completeView(.rejectedMinimal)
                //        .previewDisplayName("Rejected: Minimal")
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
    
    static var completedFull:                Self { completed(.completedFull) }
    static var completedNoAmount:            Self { completed(.completedNoAmount) }
    static var completedNoMerchant:          Self { completed(.completedNoMerchant) }
    static var completedNoMessage:           Self { completed(.completedNoMessage) }
    static var completedNoPurpose:           Self { completed(.completedNoPurpose) }
    static var completedNoMerchantNoMessage: Self { completed(.completedNoMerchantNoMessage) }
    static var completedMinimal:             Self { completed(.completedMinimal) }
    
    static var inflightFull:                 Self { completed(.inflightFull) }
    static var inflightNoAmount:             Self { completed(.inflightNoAmount) }
    static var inflightNoMerchant:           Self { completed(.inflightNoMerchant) }
    static var inflightNoMessage:            Self { completed(.inflightNoMessage) }
    static var inflightNoPurpose:            Self { completed(.inflightNoPurpose) }
    static var inflightNoMerchantNoMessage:  Self { completed(.inflightNoMerchantNoMessage) }
    static var inflightMinimal:              Self { completed(.inflightMinimal) }
    
    static var rejectedFull:                 Self { completed(.rejectedFull) }
    static var rejectedNoAmount:             Self { completed(.rejectedNoAmount) }
    static var rejectedNoMerchant:           Self { completed(.rejectedNoMerchant) }
    static var rejectedNoMessage:            Self { completed(.rejectedNoMessage) }
    static var rejectedNoPurpose:            Self { completed(.rejectedNoPurpose) }
    static var rejectedNoMerchantNoMessage:  Self { completed(.rejectedNoMerchantNoMessage) }
    static var rejectedMinimal:              Self { completed(.rejectedMinimal) }
    
    private static func completed(
        _ response: OperationDetailDomain.State.EnhancedResponse
    ) -> Self {
        
        return .init(
            id: .init(),
            content: .preview(
                details: .completed(.preview),
                response: response
            )
        )
    }
    
    static var failure: Self {
        
        return .init(
            id: .init(),
            content: .preview(
                details: .failure(NSError(domain: "Load failure", code: -1)),
                response: .preview
            )
        )
    }
    
    static var loading: Self {
        
        return .init(
            id: .init(),
            content: .preview(details: .loading(nil), response: .preview))
    }
    
    static var pending: Self {
        
        return .init(
            id: .init(),
            content: .preview(details: .pending, response: .preview))
    }
    
}

private extension OperationDetailDomain.State.Details {
    
    static let preview: Self = .init()
}

private extension OperationDetailDomain.Model {
    
    static func preview(
        details: OperationDetailDomain.State.DetailsState = .pending,
        response: OperationDetailDomain.State.EnhancedResponse
    ) -> OperationDetailDomain.Model {
        
        return .init(
            initialState: .init(details: details, response: response),
            reduce: { state, _ in (state, nil) },
            handleEffect: { _,_ in }
        )
    }
}

private extension OperationDetailDomain.State.EnhancedResponse {
    
    // ✅ COMPLETED STATUS
    static let completedFull: Self = .init(
        formattedAmount: "100.50 ₽",
        merchantName: "Merchant A",
        message: "Payment successful",
        paymentOperationDetailID: 1,
        product: .preview,
        purpose: "Purchase",
        status: .completed,
        uin: UUID().uuidString
    )
    
    static let completedNoAmount: Self = .init(
        formattedAmount: nil,
        merchantName: "Merchant B",
        message: "Payment processed",
        paymentOperationDetailID: 2,
        product: .preview,
        purpose: "Subscription",
        status: .completed,
        uin: UUID().uuidString
    )
    
    static let completedNoMerchant: Self = .init(
        formattedAmount: "75.00 ₽",
        merchantName: nil,
        message: "Transaction complete",
        paymentOperationDetailID: 3,
        product: .preview,
        purpose: "Service Payment",
        status: .completed,
        uin: UUID().uuidString
    )
    
    static let completedNoMessage: Self = .init(
        formattedAmount: "50.00 ₽",
        merchantName: "Merchant C",
        message: nil,
        paymentOperationDetailID: 4,
        product: .preview,
        purpose: "Gift",
        status: .completed,
        uin: UUID().uuidString
    )
    
    static let completedNoPurpose: Self = .init(
        formattedAmount: "125.00 ₽",
        merchantName: "Merchant D",
        message: "Transaction successful",
        paymentOperationDetailID: 5,
        product: .preview,
        purpose: nil,
        status: .completed,
        uin: UUID().uuidString
    )
    
    static let completedNoMerchantNoMessage: Self = .init(
        formattedAmount: "90.00 ₽",
        merchantName: nil,
        message: nil,
        paymentOperationDetailID: 6,
        product: .preview,
        purpose: "Utilities",
        status: .completed,
        uin: UUID().uuidString
    )
    
    static let completedMinimal: Self = .init(
        formattedAmount: nil,
        merchantName: nil,
        message: nil,
        paymentOperationDetailID: 7,
        product: .preview,
        purpose: nil,
        status: .completed,
        uin: UUID().uuidString
    )
    
    // ✅ INFLIGHT STATUS
    static let inflightFull: Self = .init(
        formattedAmount: "200.00 ₽",
        merchantName: "Merchant E",
        message: "Payment is being processed",
        paymentOperationDetailID: 8,
        product: .preview,
        purpose: "Transfer",
        status: .inflight,
        uin: UUID().uuidString
    )
    
    static let inflightNoAmount: Self = .init(
        formattedAmount: nil,
        merchantName: "Merchant F",
        message: "Awaiting confirmation",
        paymentOperationDetailID: 9,
        product: .preview,
        purpose: "Deposit",
        status: .inflight,
        uin: UUID().uuidString
    )
    
    static let inflightNoMerchant: Self = .init(
        formattedAmount: "150.00 ₽",
        merchantName: nil,
        message: "Processing transaction",
        paymentOperationDetailID: 10,
        product: .preview,
        purpose: "Bill Payment",
        status: .inflight,
        uin: UUID().uuidString
    )
    
    static let inflightNoMessage: Self = .init(
        formattedAmount: "175.00 ₽",
        merchantName: "Merchant G",
        message: nil,
        paymentOperationDetailID: 11,
        product: .preview,
        purpose: "Subscription Renewal",
        status: .inflight,
        uin: UUID().uuidString
    )
    
    static let inflightNoPurpose: Self = .init(
        formattedAmount: "120.00 ₽",
        merchantName: "Merchant H",
        message: "Payment pending",
        paymentOperationDetailID: 12,
        product: .preview,
        purpose: nil,
        status: .inflight,
        uin: UUID().uuidString
    )
    
    static let inflightNoMerchantNoMessage: Self = .init(
        formattedAmount: "130.00 ₽",
        merchantName: nil,
        message: nil,
        paymentOperationDetailID: 13,
        product: .preview,
        purpose: "Loan Payment",
        status: .inflight,
        uin: UUID().uuidString
    )
    
    static let inflightMinimal: Self = .init(
        formattedAmount: nil,
        merchantName: nil,
        message: nil,
        paymentOperationDetailID: 14,
        product: .preview,
        purpose: nil,
        status: .inflight,
        uin: UUID().uuidString
    )
    
    // ✅ REJECTED STATUS
    static let rejectedFull: Self = .init(
        formattedAmount: "300.75 ₽",
        merchantName: "Merchant I",
        message: "Payment failed due to insufficient funds",
        paymentOperationDetailID: 15,
        product: .preview,
        purpose: "Online Shopping",
        status: .rejected,
        uin: UUID().uuidString
    )
    
    static let rejectedNoAmount: Self = .init(
        formattedAmount: nil,
        merchantName: "Merchant J",
        message: "Transaction declined",
        paymentOperationDetailID: 16,
        product: .preview,
        purpose: "Loan Payment",
        status: .rejected,
        uin: UUID().uuidString
    )
    
    static let rejectedNoMerchant: Self = .init(
        formattedAmount: "125.00 ₽",
        merchantName: nil,
        message: "Card not accepted",
        paymentOperationDetailID: 17,
        product: .preview,
        purpose: "Charity Donation",
        status: .rejected,
        uin: UUID().uuidString
    )
    
    static let rejectedNoMessage: Self = .init(
        formattedAmount: "140.00 ₽",
        merchantName: "Merchant K",
        message: nil,
        paymentOperationDetailID: 18,
        product: .preview,
        purpose: "Food Order",
        status: .rejected,
        uin: UUID().uuidString
    )
    
    static let rejectedNoPurpose: Self = .init(
        formattedAmount: "110.00 ₽",
        merchantName: "Merchant L",
        message: "Insufficient funds",
        paymentOperationDetailID: 19,
        product: .preview,
        purpose: nil,
        status: .rejected,
        uin: UUID().uuidString
    )
    
    static let rejectedNoMerchantNoMessage: Self = .init(
        formattedAmount: "135.00 ₽",
        merchantName: nil,
        message: nil,
        paymentOperationDetailID: 20,
        product: .preview,
        purpose: "Membership Fee",
        status: .rejected,
        uin: UUID().uuidString
    )
    
    static let rejectedMinimal: Self = .init(
        formattedAmount: nil,
        merchantName: nil,
        message: nil,
        paymentOperationDetailID: 21,
        product: .preview,
        purpose: nil,
        status: .rejected,
        uin: UUID().uuidString
    )
}

extension ProductData {
    
    static let preview: ProductData = .init(id: 1, productType: .account, number: nil, numberMasked: nil, accountNumber: nil, balance: nil, balanceRub: nil, currency: "RUB", mainField: "", additionalField: nil, customName: nil, productName: "", openDate: nil, ownerId: 1, branchId: nil, allowCredit: false, allowDebit: true, extraLargeDesign: .init(description: ""), largeDesign: .init(description: ""), mediumDesign: .init(description: ""), smallDesign: .init(description: ""), fontDesignColor: .init(description: ""), background: [], order: 1, isVisible: true, smallDesignMd5hash: "", smallBackgroundDesignHash: "")
}
