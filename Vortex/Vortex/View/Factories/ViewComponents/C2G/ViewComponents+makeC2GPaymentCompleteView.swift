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
            
            let basicDetails = cover.content.state.basicDetails
            
            basicDetails.merchantName?.text(withConfig: config.merchantName)
            basicDetails.purpose?.text(withConfig: config.purpose)
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
            formattedAmount: content.state.basicDetails.formattedAmount,
            merchantIcon: nil,
            status: status
        )
    }
    
    var status: PaymentCompletion.Status {
        
        switch content.state.basicDetails.status {
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
        _ basicDetails: OperationDetailDomain.BasicDetails
    ) -> Self {
        
        return .init(
            id: .init(),
            content: .preview(
                basicDetails: basicDetails,
                fullDetails: .completed(.preview)
            )
        )
    }
    
    static var failure: Self {
        
        return .init(
            id: .init(),
            content: .preview(
                basicDetails: .preview,
                fullDetails: .failure(NSError(domain: "Load failure", code: -1))
            )
        )
    }
    
    static var loading: Self {
        
        return .init(
            id: .init(),
            content: .preview(basicDetails: .preview, fullDetails: .loading(nil)))
    }
    
    static var pending: Self {
        
        return .init(
            id: .init(),
            content: .preview(basicDetails: .preview, fullDetails: .pending))
    }
    
}

extension OperationDetailDomain.ExtendedDetails {
    
    static let preview: Self = .init(
        product: .preview,
        status: .completed,
        comment: "Единый налоговый платеж",
        dateForDetail: "06.05.2021 15:38:12",
        dateN: "06.05.2021",
        discount: "50 %",
        discountExpiry: "До 06.05.2024",
        formattedAmount: "1 000 ₽",
        legalAct: "Часть 1 статьи 12.16 КоАП, а так же ин...",
        payeeFullName: "УФК Владимирской области",
        paymentTerm: "06.05.2021",
        realPayerFIO: "ООО “Альфа”",
        realPayerINN: "771400007",
        realPayerKPP: "545345724",
        supplierBillID: "15877744552012365487",
        transAmm: "2 000 ₽",
        transferNumber: "А917910371020400SlfufFP7C847889D4",
        upno: "10422026034290522711202464279130"
    )
}

private extension OperationDetailDomain.Model {
    
    static func preview(
        basicDetails: OperationDetailDomain.BasicDetails,
        fullDetails: OperationDetailDomain.State.ExtendedDetailsState = .pending
    ) -> OperationDetailDomain.Model {
        
        return .init(
            initialState: .init(
                basicDetails: basicDetails,
                extendedDetails: fullDetails
            ),
            reduce: { state, _ in (state, nil) },
            handleEffect: { _,_ in }
        )
    }
}

private extension OperationDetailDomain.BasicDetails {
    
    // ✅ COMPLETED STATUS
    static let completedFull: Self = .init(
        product: .preview,
        status: .completed,
        formattedAmount: "100.50 ₽",
        formattedDate: "06.05.2021 15:38:12",
        merchantName: "Merchant A",
        message: "Payment successful",
        paymentOperationDetailID: 1,
        purpose: "Purchase",
        uin: UUID().uuidString
    )
    
    static let completedNoAmount: Self = .init(
        product: .preview,
        status: .completed,
        formattedAmount: nil,
        formattedDate: "06.05.2021 15:38:12",
        merchantName: "Merchant B",
        message: "Payment processed",
        paymentOperationDetailID: 2,
        purpose: "Subscription",
        uin: UUID().uuidString
    )
    
    static let completedNoMerchant: Self = .init(
        product: .preview,
        status: .completed,
        formattedAmount: "75.00 ₽",
        formattedDate: "06.05.2021 15:38:12",
        merchantName: nil,
        message: "Transaction complete",
        paymentOperationDetailID: 3,
        purpose: "Service Payment",
        uin: UUID().uuidString
    )
    
    static let completedNoMessage: Self = .init(
        product: .preview,
        status: .completed,
        formattedAmount: "50.00 ₽",
        formattedDate: "06.05.2021 15:38:12",
        merchantName: "Merchant C",
        message: nil,
        paymentOperationDetailID: 4,
        purpose: "Gift",
        uin: UUID().uuidString
    )
    
    static let completedNoPurpose: Self = .init(
        product: .preview,
        status: .completed,
        formattedAmount: "125.00 ₽",
        formattedDate: "06.05.2021 15:38:12",
        merchantName: "Merchant D",
        message: "Transaction successful",
        paymentOperationDetailID: 5,
        purpose: nil,
        uin: UUID().uuidString
    )
    
    static let completedNoMerchantNoMessage: Self = .init(
        product: .preview,
        status: .completed,
        formattedAmount: "90.00 ₽",
        formattedDate: "06.05.2021 15:38:12",
        merchantName: nil,
        message: nil,
        paymentOperationDetailID: 6,
        purpose: "Utilities",
        uin: UUID().uuidString
    )
    
    static let completedMinimal: Self = .init(
        product: .preview,
        status: .completed,
        formattedAmount: nil,
        formattedDate: "06.05.2021 15:38:12",
        merchantName: nil,
        message: nil,
        paymentOperationDetailID: 7,
        purpose: nil,
        uin: UUID().uuidString
    )
    
    // ✅ INFLIGHT STATUS
    static let inflightFull: Self = .init(
        product: .preview,
        status: .inflight,
        formattedAmount: "200.00 ₽",
        formattedDate: "06.05.2021 15:38:12",
        merchantName: "Merchant E",
        message: "Payment is being processed",
        paymentOperationDetailID: 8,
        purpose: "Transfer",
        uin: UUID().uuidString
    )
    
    static let inflightNoAmount: Self = .init(
        product: .preview,
        status: .inflight,
        formattedAmount: nil,
        formattedDate: "06.05.2021 15:38:12",
        merchantName: "Merchant F",
        message: "Awaiting confirmation",
        paymentOperationDetailID: 9,
        purpose: "Deposit",
        uin: UUID().uuidString
    )
    
    static let inflightNoMerchant: Self = .init(
        product: .preview,
        status: .inflight,
        formattedAmount: "150.00 ₽",
        formattedDate: "06.05.2021 15:38:12",
        merchantName: nil,
        message: "Processing transaction",
        paymentOperationDetailID: 10,
        purpose: "Bill Payment",
        uin: UUID().uuidString
    )
    
    static let inflightNoMessage: Self = .init(
        product: .preview,
        status: .inflight,
        formattedAmount: "175.00 ₽",
        formattedDate: "06.05.2021 15:38:12",
        merchantName: "Merchant G",
        message: nil,
        paymentOperationDetailID: 11,
        purpose: "Subscription Renewal",
        uin: UUID().uuidString
    )
    
    static let inflightNoPurpose: Self = .init(
        product: .preview,
        status: .inflight,
        formattedAmount: "120.00 ₽",
        formattedDate: "06.05.2021 15:38:12",
        merchantName: "Merchant H",
        message: "Payment pending",
        paymentOperationDetailID: 12,
        purpose: nil,
        uin: UUID().uuidString
    )
    
    static let inflightNoMerchantNoMessage: Self = .init(
        product: .preview,
        status: .inflight,
        formattedAmount: "130.00 ₽",
        formattedDate: "06.05.2021 15:38:12",
        merchantName: nil,
        message: nil,
        paymentOperationDetailID: 13,
        purpose: "Loan Payment",
        uin: UUID().uuidString
    )
    
    static let inflightMinimal: Self = .init(
        product: .preview,
        status: .inflight,
        formattedAmount: nil,
        formattedDate: "06.05.2021 15:38:12",
        merchantName: nil,
        message: nil,
        paymentOperationDetailID: 14,
        purpose: nil,
        uin: UUID().uuidString
    )
    
    // ✅ REJECTED STATUS
    static let rejectedFull: Self = .init(
        product: .preview,
        status: .rejected,
        formattedAmount: "300.75 ₽",
        formattedDate: "06.05.2021 15:38:12",
        merchantName: "Merchant I",
        message: "Payment failed due to insufficient funds",
        paymentOperationDetailID: 15,
        purpose: "Online Shopping",
        uin: UUID().uuidString
    )
    
    static let rejectedNoAmount: Self = .init(
        product: .preview,
        status: .rejected,
        formattedAmount: nil,
        formattedDate: "06.05.2021 15:38:12",
        merchantName: "Merchant J",
        message: "Transaction declined",
        paymentOperationDetailID: 16,
        purpose: "Loan Payment",
        uin: UUID().uuidString
    )
    
    static let rejectedNoMerchant: Self = .init(
        product: .preview,
        status: .rejected,
        formattedAmount: "125.00 ₽",
        formattedDate: "06.05.2021 15:38:12",
        merchantName: nil,
        message: "Card not accepted",
        paymentOperationDetailID: 17,
        purpose: "Charity Donation",
        uin: UUID().uuidString
    )
    
    static let rejectedNoMessage: Self = .init(
        product: .preview,
        status: .rejected,
        formattedAmount: "140.00 ₽",
        formattedDate: "06.05.2021 15:38:12",
        merchantName: "Merchant K",
        message: nil,
        paymentOperationDetailID: 18,
        purpose: "Food Order",
        uin: UUID().uuidString
    )
    
    static let rejectedNoPurpose: Self = .init(
        product: .preview,
        status: .rejected,
        formattedAmount: "110.00 ₽",
        formattedDate: "06.05.2021 15:38:12",
        merchantName: "Merchant L",
        message: "Insufficient funds",
        paymentOperationDetailID: 19,
        purpose: nil,
        uin: UUID().uuidString
    )
    
    static let rejectedNoMerchantNoMessage: Self = .init(
        product: .preview,
        status: .rejected,
        formattedAmount: "135.00 ₽",
        formattedDate: "06.05.2021 15:38:12",
        merchantName: nil,
        message: nil,
        paymentOperationDetailID: 20,
        purpose: "Membership Fee",
        uin: UUID().uuidString
    )
    
    static let rejectedMinimal: Self = .init(
        product: .preview,
        status: .rejected,
        formattedAmount: nil,
        formattedDate: "06.05.2021 15:38:12",
        merchantName: nil,
        message: nil,
        paymentOperationDetailID: 21,
        purpose: nil,
        uin: UUID().uuidString
    )
}

extension ProductData {
    
    static let preview: ProductData = .init(id: 1, productType: .account, number: nil, numberMasked: nil, accountNumber: nil, balance: nil, balanceRub: nil, currency: "RUB", mainField: "", additionalField: nil, customName: nil, productName: "", openDate: nil, ownerId: 1, branchId: nil, allowCredit: false, allowDebit: true, extraLargeDesign: .init(description: ""), largeDesign: .init(description: ""), mediumDesign: .init(description: ""), smallDesign: .init(description: ""), fontDesignColor: .init(description: ""), background: [], order: 1, isVisible: true, smallDesignMd5hash: "", smallBackgroundDesignHash: "")
}

extension OperationDetailDomain.Product {
    
    static let preview: Self = .init(id: 1, type: .account, isAdditional: false, header: "header", title: "title", footer: "footer", amountFormatted: "$ 10 000", balance: 1_234.56, look: .init(background: .image(.cardPlaceholder), color: .blue, icon: .image(.ic24NewCard)))
}
