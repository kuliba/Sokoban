//
//  ViewComponents+makeOrderSavingsAccountCompleteView.swift
//  Vortex
//
//  Created by Andryusina Nataly on 21.02.2025.
//

import RxViewModel
import SwiftUI
import PaymentCompletionUI
import UIPrimitives

extension ViewComponents {
        
    @inlinable
    func makeOrderSavingsAccountCompleteView(
        processingFlag: ProcessingFlag,
        _ complete: OpenSavingsAccountCompleteDomain.Complete,
        action: @escaping () -> Void,
        makePlacesView: @escaping () -> PlacesView?
    ) -> some View {
       
        let needProcessing: Bool = complete.context.status.status == .inflight && processingFlag.isActive
        let title: String = .savingsAccountTitle(needProcessing, complete.context.formattedAmount != nil)
        let subtitle: String? = needProcessing ? .processingSubtitle : nil

        let config: PaymentCompletionConfig = .orderSavingsAccount(title: title, subtitle: subtitle)
        
        return makePaymentCompletionLayoutView(
            state: complete.context.state(needProcessing),
            statusConfig: config,
            buttons: { makeButtons(needProcessing, complete, makePlacesView) },
            details: { EmptyView() },
            footer: {
                heroButton(title: "На главный") {
                    action()
                    goToMain()
                }
            }
        )
    }

    @ViewBuilder
    func makeButtons(
        _ needProcessing: Bool,
        _ complete: OpenSavingsAccountCompleteDomain.Complete,
        _ makePlacesView: @escaping () -> PlacesView?
    ) -> some View {
        
        switch (needProcessing, complete.context.status.status) {
        case (true, _):
            RxWrapperView(model: complete.details) { state, _ in
                
                makeDetailsButton(state: state)
            }
            
        case (false, .completed):
            HStack {
                RxWrapperView(model: complete.document) { state, _ in
                    
                    makeDocumentButtonViewWithShareButton(state: state, makePlacesView)
                }
                
                RxWrapperView(model: complete.details) { state, _ in
                    
                    makeDetailsButton(state: state)
                }
            }
            
        default:
            EmptyView()
        }
    }
    
    @ViewBuilder
    func makeDetailsButton(
        state: OperationDetailSADomain.State
    )  -> some View {
        
        switch state {
        case let .completed(details):
            WithFullScreenCoverView {
                circleButton(image: .ic24Info, title: "Детали", action: $0)
            } sheet: {
                saTransactionDetails(details: details, dismiss: $0)
            }
            
        case .failure, .pending:
            EmptyView()
            
        case .loading:
            circleButtonPlaceholder()
        }
    }
    
    @inlinable
    func saTransactionDetails(
        details: any TransactionDetailsProviding<[DetailsCell]>,
        dismiss: @escaping () -> Void
    ) -> some View {
        
        saDetailsView(details: details.transactionDetails)
            .navigationBarWithClose(
                title: "Детали операции",
                dismiss: dismiss
            )
    }

    @inlinable
    func saDetailsView(
        details: [DetailsCell]
    ) -> some View {
        
        DetailsView(
            detailsCells: details,
            config: .iVortex,
            detailsCellView: detailsCellView
        )
    }
    
    @inlinable
    @ViewBuilder
    func makeDocumentButtonViewWithShareButton(
        state: DocumentButtonDomain.State,
        _ makePlacesView: @escaping () -> PlacesView?
    ) -> some View {
        
        switch state {
        case let .completed(document):
            WithSheetView {
                circleButton(image: .ic24File, title: "Документ", action: $0)
            } sheet: {
                PrintFormView(viewModel: .init(pdfDocument: document, dismissAction: $0))
            }
        
        case .pending:
            EmptyView()
            
        case .failure:
            SAFailureDocumentView(
                content: {
                    circleButton(image: .ic24File, title: "Документ", action: $0)
                },
                goToMain: goToMain,
                makePlacesView: makePlacesView
            )

        case .loading:
            circleButtonPlaceholder()
        }
    }
    
    @ViewBuilder
    func makeDetailsButton(
        state: OperationDetailDomain.State
    )  -> some View {
        
        switch state.extendedDetails {
            
        case let .completed(details):
            
            WithFullScreenCoverView {
                circleButton(image: .ic24Info, title: "Детали", action: $0)
            } sheet: {
                c2gTransactionDetails(details: details, dismiss: $0)
            }
            
        case .failure, .pending:
            EmptyView()
            
        case .loading:
            circleButtonPlaceholder()
        }
    }
}

extension OpenSavingsAccountCompleteDomain.Complete.Context.Status {
    
    var status: PaymentCompletion.Status {
        
        switch self {
        case .completed:
            return .completed
        case .inflight:
            return .inflight
        case .rejected:
            return .rejected
        case let .fraud(fraud):
            switch fraud {
            case .cancelled:
                return .fraud(.cancelled)
            case .expired:
                return .fraud(.expired)
            }
        case .suspend:
            return .suspend
        }
    }
}

extension String {
    
    static let processingTitle: Self = "Платеж успешно принят в обработку"
    static let processingSubtitle: Self =  "Баланс обновится после\nобработки операции"
}

private extension String {
    
    static let titleWithTopUp: Self = "Накопительный счет открыт\nи пополнен на сумму"
    static let titleWithOutTopUp: Self = "Накопительный счет открыт"
    
    static func savingsAccountTitle(
        _ processing: Bool,
        _ withTopUp: Bool
    ) -> Self {
        processing
        ? processingTitle
        : {
            withTopUp ? titleWithTopUp : titleWithOutTopUp
        }()
    }
}

private extension OpenSavingsAccountCompleteDomain.Complete.Context.Status {
    
    func newStatus(
        _ needProcessing: Bool
    ) -> PaymentCompletion.Status {
        
        switch self.status {
        case .inflight:
            needProcessing ? .completed : .inflight
            
        default: self.status
        }
    }
}

private extension OpenSavingsAccountCompleteDomain.Complete.Context {
    
    func state(
        _ needProcessing: Bool
    ) -> PaymentCompletion {
        
        .init(
            formattedAmount: status == .rejected ? nil : formattedAmount,
            merchantIcon: nil,
            status: status.newStatus(needProcessing)
        )
    }
}

private struct SAFailureDocumentView<Content: View>: View {
    
    @State private var isPresented: Bool
    @State private var isShowAlert: Bool = true
    @State private var needShowPlaces: Bool = false
    
    private let content: (@escaping () -> Void) -> Content
    private let goToMain: () -> Void
    private let makePlacesView: () -> PlacesView?
    
    init(
        @ViewBuilder content: @escaping (@escaping () -> Void) -> Content,
        isPresented: Bool = false,
        goToMain: @escaping () -> Void,
        makePlacesView: @escaping () -> PlacesView?
    ) {
        self.goToMain = goToMain
        self.isPresented = isPresented
        self.makePlacesView = makePlacesView
        self.content = content
    }
    
    var body: some View {
        
        content {
            isPresented = true
            needShowPlaces = false
            isShowAlert = true
        }
        .sheet(isPresented: $isPresented) {
            ZStack {
                Color.clear
                    .alert(
                        item: alert,
                        content: Alert.init
                    )
                if needShowPlaces {
                    makePlacesView()
                }
            }
        }
    }
    
    private var alert: Alert.ViewModel? {
        
        if isShowAlert {
            
            return .init(
                title: "Форма временно недоступна",
                message: "Для получения Заявления-анкеты\nобратитесь в отделение банка",
                primary: .init(
                    type: .default,
                    title: "Наши офисы",
                    action: {
                        isShowAlert = false
                        needShowPlaces = true
                    }),
                secondary: .init(
                    type: .default,
                    title: "Ок",
                    action: {
                        isPresented = false
                        needShowPlaces = false
                        isShowAlert = false
                    })
            )
        }
        
        return nil
    }
}
