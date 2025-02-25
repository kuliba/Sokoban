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

typealias C2GCompleteCover = C2GPaymentDomain.Navigation.Cover<C2GPaymentDomain.Complete>

extension ViewComponents {
    
    @inlinable
    func makeC2GPaymentCompleteView(
        cover: C2GCompleteCover,
        config: C2GPaymentCompleteViewConfig = .iVortex
    ) -> some View {
        
        makePaymentCompletionLayoutView(
            state: cover.completion,
            statusConfig: .c2g,
            buttons: { makeC2GPaymentCompleteButtonsView(cover.content.details) },
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
            
            let context = cover.content.context
            
            context.merchantName?.text(withConfig: config.merchantName)
            context.purpose?.text(withConfig: config.purpose)
        }
    }
}

struct C2GPaymentCompleteViewConfig {
    
    let spacing: CGFloat
    let merchantName: TextConfig
    let purpose: TextConfig
}

// MARK: - Adapters

private extension C2GCompleteCover {
    
    var completion: PaymentCompletion {
        
        return .init(
            formattedAmount: content.context.formattedAmount,
            merchantIcon: nil,
            status: status
        )
    }
    
    var status: PaymentCompletion.Status {
        
        switch content.context.status {
        case .completed: return .completed
        case .inflight:  return .inflight
        case .rejected:  return .rejected
        }
    }
}

// MARK: - Previews

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
    
    private static func completeView(
        _ cover: C2GCompleteCover
    ) -> some View {
        
        ViewComponents.preview.makeC2GPaymentCompleteView(
            cover: cover,
            config: .iVortex
        )
    }
}

private extension C2GCompleteCover {
    
    static var failure: Self {
        
        return .init(
            id: .init(),
            content: .init(
                context: .completedFull,
                details: .preview(
                    basicDetails: .completedFull,
                    fullDetails: .failure(NSError(domain: "Load failure", code: -1))
                )
            )
        )
    }
    
    static var loading: Self {
        
        return .init(
            id: .init(),
            content: .init(
                context: .completedFull,
                details: .preview(
                    basicDetails: .completedFull,
                    fullDetails: .loading(nil)
                )
            )
        )
    }
    
    static var pending: Self {
        
        return .init(
            id: .init(),
            content: .init(
                context: .completedFull,
                details: .preview(
                    basicDetails: .completedFull,
                    fullDetails: .pending
                )
            )
        )
    }
    
    static var completedFull:                Self { preview(.completedFull) }
    static var completedNoAmount:            Self { preview(.completedNoAmount) }
    static var completedNoMerchant:          Self { preview(.completedNoMerchant) }
    static var completedNoMessage:           Self { preview(.completedNoMessage) }
    static var completedNoPurpose:           Self { preview(.completedNoPurpose) }
    static var completedNoMerchantNoMessage: Self { preview(.completedNoMerchantNoMessage) }
    static var completedMinimal:             Self { preview(.completedMinimal) }
    
    static var inflightFull:                 Self { preview(.inflightFull) }
    static var inflightNoAmount:             Self { preview(.inflightNoAmount) }
    static var inflightNoMerchant:           Self { preview(.inflightNoMerchant) }
    static var inflightNoMessage:            Self { preview(.inflightNoMessage) }
    static var inflightNoPurpose:            Self { preview(.inflightNoPurpose) }
    static var inflightNoMerchantNoMessage:  Self { preview(.inflightNoMerchantNoMessage) }
    static var inflightMinimal:              Self { preview(.inflightMinimal) }
    
    static var rejectedFull:                 Self { preview(.rejectedFull) }
    static var rejectedNoAmount:             Self { preview(.rejectedNoAmount) }
    static var rejectedNoMerchant:           Self { preview(.rejectedNoMerchant) }
    static var rejectedNoMessage:            Self { preview(.rejectedNoMessage) }
    static var rejectedNoPurpose:            Self { preview(.rejectedNoPurpose) }
    static var rejectedNoMerchantNoMessage:  Self { preview(.rejectedNoMerchantNoMessage) }
    static var rejectedMinimal:              Self { preview(.rejectedMinimal) }
    
    private static func preview(
        _ fields: C2GPaymentDomain.Complete.Context
    ) -> Self {
        
        return .init(
            id: .init(),
            content: .init(
                context: fields,
                details: .preview(
                    basicDetails: fields.basicDetails,
                    fullDetails: .completed(.preview)
                )
            )
        )
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

private extension C2GPaymentDomain.Complete {
    
    static func preview(
        fields: Context,
        details: OperationDetailDomain.Model
    ) -> Self {
        
        return .init(context: fields, details: details)
    }
}

extension OperationDetailDomain.Model {
    
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
    
    static let completedFull: Self = C2GPaymentDomain.Complete.Context.completedFull.basicDetails
    static let completedNoAmount: Self = C2GPaymentDomain.Complete.Context.completedNoAmount.basicDetails
    static let completedNoMerchant: Self = C2GPaymentDomain.Complete.Context.completedNoMerchant.basicDetails
    static let completedNoMessage: Self = C2GPaymentDomain.Complete.Context.completedNoMessage.basicDetails
    static let completedNoPurpose: Self = C2GPaymentDomain.Complete.Context.completedNoPurpose.basicDetails
    static let completedNoMerchantNoMessage: Self = C2GPaymentDomain.Complete.Context.completedNoMerchantNoMessage.basicDetails
    static let completedMinimal: Self = C2GPaymentDomain.Complete.Context.completedMinimal.basicDetails
    
    static let inflightFull: Self = C2GPaymentDomain.Complete.Context.inflightFull.basicDetails
    static let inflightNoAmount: Self = C2GPaymentDomain.Complete.Context.inflightNoAmount.basicDetails
    static let inflightNoMerchant: Self = C2GPaymentDomain.Complete.Context.inflightNoMerchant.basicDetails
    static let inflightNoMessage: Self = C2GPaymentDomain.Complete.Context.inflightNoMessage.basicDetails
    static let inflightNoPurpose: Self = C2GPaymentDomain.Complete.Context.inflightNoPurpose.basicDetails
    static let inflightNoMerchantNoMessage: Self = C2GPaymentDomain.Complete.Context.inflightNoMerchantNoMessage.basicDetails
    static let inflightMinimal: Self = C2GPaymentDomain.Complete.Context.inflightMinimal.basicDetails
    
    static let rejectedFull: Self = C2GPaymentDomain.Complete.Context.rejectedFull.basicDetails
    static let rejectedNoAmount: Self = C2GPaymentDomain.Complete.Context.rejectedNoAmount.basicDetails
    static let rejectedNoMerchant: Self = C2GPaymentDomain.Complete.Context.rejectedNoMerchant.basicDetails
    static let rejectedNoMessage: Self = C2GPaymentDomain.Complete.Context.rejectedNoMessage.basicDetails
    static let rejectedNoPurpose: Self = C2GPaymentDomain.Complete.Context.rejectedNoPurpose.basicDetails
    static let rejectedNoMerchantNoMessage: Self = C2GPaymentDomain.Complete.Context.rejectedNoMerchantNoMessage.basicDetails
    static let rejectedMinimal: Self = C2GPaymentDomain.Complete.Context.rejectedMinimal.basicDetails
}

private extension C2GPaymentDomain.Complete.Context {
    
    var basicDetails: OperationDetailDomain.BasicDetails {
        
        return .init(formattedAmount: formattedAmount, formattedDate: "06.05.2021 15:38:12", product: .accountPreview)
    }
}

private extension C2GPaymentDomain.Complete.Context {
    
    // ✅ COMPLETED STATUS
    static let completedFull: Self = .init(
        formattedAmount: "100.50 ₽",
        merchantName: "Merchant A",
        purpose: "Purchase",
        status: .completed
    )
    
    static let completedNoAmount: Self = .init(
        formattedAmount: nil,
        merchantName: "Merchant B",
        purpose: "Subscription",
        status: .completed
    )
    
    static let completedNoMerchant: Self = .init(
        formattedAmount: "75.00 ₽",
        merchantName: nil,
        purpose: "Service Payment",
        status: .completed
    )
    
    static let completedNoMessage: Self = .init(
        formattedAmount: "50.00 ₽",
        merchantName: "Merchant C",
        purpose: "Gift",
        status: .completed
    )
    
    static let completedNoPurpose: Self = .init(
        formattedAmount: "125.00 ₽",
        merchantName: "Merchant D",
        purpose: nil,
        status: .completed
    )
    
    static let completedNoMerchantNoMessage: Self = .init(
        formattedAmount: "90.00 ₽",
        merchantName: nil,
        purpose: "Utilities",
        status: .completed
    )
    
    static let completedMinimal: Self = .init(
        formattedAmount: nil,
        merchantName: nil,
        purpose: nil,
        status: .completed
    )
    
    // ✅ INFLIGHT STATUS
    static let inflightFull: Self = .init(
        formattedAmount: "200.00 ₽",
        merchantName: "Merchant E",
        purpose: "Transfer",
        status: .inflight
    )
    
    static let inflightNoAmount: Self = .init(
        formattedAmount: nil,
        merchantName: "Merchant F",
        purpose: "Deposit",
        status: .inflight
    )
    
    static let inflightNoMerchant: Self = .init(
        formattedAmount: "150.00 ₽",
        merchantName: nil,
        purpose: "Bill Payment",
        status: .inflight
    )
    
    static let inflightNoMessage: Self = .init(
        formattedAmount: "175.00 ₽",
        merchantName: "Merchant G",
        purpose: "Subscription Renewal",
        status: .inflight
    )
    
    static let inflightNoPurpose: Self = .init(
        formattedAmount: "120.00 ₽",
        merchantName: "Merchant H",
        purpose: nil,
        status: .inflight
    )
    
    static let inflightNoMerchantNoMessage: Self = .init(
        formattedAmount: "130.00 ₽",
        merchantName: nil,
        purpose: "Loan Payment",
        status: .inflight
    )
    
    static let inflightMinimal: Self = .init(
        formattedAmount: nil,
        merchantName: nil,
        purpose: nil,
        status: .inflight
    )
    
    // ✅ REJECTED STATUS
    static let rejectedFull: Self = .init(
        formattedAmount: "300.75 ₽",
        merchantName: "Merchant I",
        purpose: "Online Shopping",
        status: .rejected
    )
    
    static let rejectedNoAmount: Self = .init(
        formattedAmount: nil,
        merchantName: "Merchant J",
        purpose: "Loan Payment",
        status: .rejected
    )
    
    static let rejectedNoMerchant: Self = .init(
        formattedAmount: "125.00 ₽",
        merchantName: nil,
        purpose: "Charity Donation",
        status: .rejected
    )
    
    static let rejectedNoMessage: Self = .init(
        formattedAmount: "140.00 ₽",
        merchantName: "Merchant K",
        purpose: "Food Order",
        status: .rejected
    )
    
    static let rejectedNoPurpose: Self = .init(
        formattedAmount: "110.00 ₽",
        merchantName: "Merchant L",
        purpose: nil,
        status: .rejected
    )
    
    static let rejectedNoMerchantNoMessage: Self = .init(
        formattedAmount: "135.00 ₽",
        merchantName: nil,
        purpose: "Membership Fee",
        status: .rejected
    )
    
    static let rejectedMinimal: Self = .init(
        formattedAmount: nil,
        merchantName: nil,
        purpose: nil,
        status: .rejected
    )
}

extension ProductData {
    
    static let preview: ProductData = .init(id: 1, productType: .account, number: nil, numberMasked: nil, accountNumber: nil, balance: nil, balanceRub: nil, currency: "RUB", mainField: "", additionalField: nil, customName: nil, productName: "", openDate: nil, ownerId: 1, branchId: nil, allowCredit: false, allowDebit: true, extraLargeDesign: .init(description: ""), largeDesign: .init(description: ""), mediumDesign: .init(description: ""), smallDesign: .init(description: ""), fontDesignColor: .init(description: ""), background: [], order: 1, isVisible: true, smallDesignMd5hash: "", smallBackgroundDesignHash: "")
}

extension OperationDetailDomain.Product {
    
    static let preview: Self = .init(id: 1, type: .account, isAdditional: false, header: "header", title: "title", footer: "footer", amountFormatted: "$ 10 000", balance: 1_234.56, look: .init(background: .image(.cardPlaceholder), color: .blue, icon: .image(.ic24NewCard)))
}
