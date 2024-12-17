//
//  PTSectionLatestPaymentsViewComponent.swift
//  ForaBank
//
//  Created by Dmitry Martynov on 19.05.2022.
//

import SwiftUI
import Combine

//MARK: Section ViewModel

extension PTSectionLatestPaymentsView {
    
    class ViewModel: PaymentsTransfersSectionViewModel {
        
        @Published var latestPayments: LatestPaymentsView.ViewModel
        
        override var type: PaymentsTransfersSectionType { .latestPayments }
        private let model: Model
        
        private var bindings = Set<AnyCancellable>()
        
        init(latestsPayments: LatestPaymentsView.ViewModel, model: Model) {
            
            self.latestPayments = latestsPayments
            self.model = model
            super.init()
        }
        
        init(model: Model) {
            
            self.latestPayments = .init(model)
            self.model = model
            super.init()
            bind()
            bind(latestPayments)
        }
        
        func bind() {
            
            model.action
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] action in
                    
                    switch action {
                
                    case let payload as ModelAction.Contacts.PermissionStatus.Update:
                    
                        switch payload.status {
                        case .available:
                       
                            if !model.latestPayments.value.isEmpty {
                                
                                withAnimation(.easeInOut(duration: 1)) {
                                    
                                    // temporally removed taxAndStateService from list
                                    let latestPayments = LatestPaymentsView.ViewModel(model)
                                    self.latestPayments = latestPayments
                                    bind(latestPayments)
                                }
                            }
                        
                        default:
                            break
                        }
                    default:
                        break
                    }
                    
            }.store(in: &bindings)
        }
        
        func bind(_ latestPayments: LatestPaymentsView.ViewModel) {
            
            latestPayments.action
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] action in
                    
                    switch action {
                    case let payload as LatestPaymentsViewModelAction.ButtonTapped.LatestPayment:
                        self.action.send(LatestPaymentsViewModelAction.ButtonTapped.LatestPayment(latestPayment: payload.latestPayment))
                        
                    case _ as LatestPaymentsViewModelAction.ButtonTapped.Templates:
                        self.action.send(LatestPaymentsViewModelAction.ButtonTapped.Templates())
                        
                    case _ as LatestPaymentsViewModelAction.ButtonTapped.CurrencyWallet:
                        self.action.send(LatestPaymentsViewModelAction.ButtonTapped.CurrencyWallet())
                        
                    default:
                        break
                    }
                    
                }.store(in: &bindings)
        }
    }
}

//MARK: Section View

struct PTSectionLatestPaymentsView: View {
    
    @ObservedObject
    var viewModel: ViewModel
    
    var body: some View {
        
        Text(viewModel.title)
            .frame(maxWidth: .infinity, alignment: .leading)
            .font(.textH1Sb24322())
            .foregroundColor(.textSecondary)
            .padding(.vertical, 16)
            .padding(.leading, 20)

        LatestPaymentsView(viewModel: viewModel.latestPayments)
        
    }
}

//MARK: default LatestPaymentButton by type

extension LatestPaymentData.Kind {
    
    var defaultName: String {
        
        switch self {
        case .outside: return "За рубеж"
        case .phone: return "По телефону"
        case .service: return "Услуги ЖКХ"
        case .mobile: return "Услуги связи"
        case .internet: return "Услуги интернет"
        case .transport: return "Услуги Транспорта"
        case .taxAndStateService: return  "Госуслуги"
        case .unknown: return "Неизвестно"
        }
    }
    
    var defaultIcon: Image {
        
        switch self {
        case .outside: return .ic24Globe
        case .phone: return .ic24Smartphone
        case .service: return .ic24Zkx
        case .mobile: return .ic24Smartphone
        case .internet: return .ic24Tv
        case .transport: return .ic24Car
        case .taxAndStateService: return .ic24Emblem
        case .unknown: return .ic24AlertTriangle
        }
    }
}

//MARK: - Preview

struct PTSectionLatestPaymentsView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        PTSectionLatestPaymentsView(viewModel: .init(model: .emptyMock))
            .previewLayout(.fixed(width: 350, height: 150))
            .previewDisplayName("Section LatestPayments")
    }
}
