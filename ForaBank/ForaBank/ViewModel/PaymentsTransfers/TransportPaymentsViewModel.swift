//
//  TransportPaymentsViewModel.swift
//  ForaBank
//
//  Created by Igor Malyarov on 15.06.2023.
//

import Combine
import Foundation
import SwiftUI

final class TransportPaymentsViewModel: ObservableObject {
    
    @Published private(set) var link: Link?
    
    let operators: [OperatorGroupData.OperatorData]
    let latestPayments: PaymentsServicesLatestPaymentsSectionViewModel
    let navigationBar: NavigationBarView.ViewModel
    
    typealias MakePaymentsViewModel = (Payments.Operation.Source) -> PaymentsViewModel
    
    private let makePaymentsViewModel: MakePaymentsViewModel
    
    private var bindings = Set<AnyCancellable>()

    init(
        operators: [OperatorGroupData.OperatorData],
        latestPayments: PaymentsServicesLatestPaymentsSectionViewModel,
        navigationBar: NavigationBarView.ViewModel,
        makePaymentsViewModel: @escaping PaymentsServicesViewModel.MakePaymentsViewModel
    ) {
        self.operators = operators
        self.latestPayments = latestPayments
        self.navigationBar = navigationBar
        self.makePaymentsViewModel = makePaymentsViewModel
        
        bind()
    }
    
    func setLink(to isActive: Bool) {
        
        if !isActive { link = nil }
    }
    
    enum Link {
        
#warning("replace with strong type")
        case avtodor((String) -> Void)
        case payments(PaymentsViewModel)
    }
    
    private func bind() {
        
        latestPayments.action
            .compactMap { $0 as? PaymentsServicesSectionViewModelAction.LatestPayments.ItemDidTapped }
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] payload in
                
                let paymentsViewModel = makePaymentsViewModel(
                    .servicePayment(
                        puref: payload.latestPayment.puref,
                        additionalList: payload.latestPayment.additionalList,
                        amount: payload.latestPayment.amount
                    )
                )
                
                Task { @MainActor [weak self] in
                    
                    self?.link = .payments(paymentsViewModel)
                }
            }
            .store(in: &bindings)
    }
}

extension TransportPaymentsViewModel {
    
    struct ItemViewModel: Identifiable {
        
        let id: String
        let icon: Image?
        let name: String
        let inn: String?
        let select: (String) -> Void
    }
    
    var viewOperators: [ItemViewModel] {
        
        let action: (String) -> Void = { [weak self] code in
            
            guard let link = self?.link(for: code) else { return }
            
            Task { @MainActor [weak self] in self?.link = link }
        }
        
        return operators
            .filter { !$0.parameterList.isEmpty }
            .sorted { $0.name.lowercased() < $1.name.lowercased() }
            .sorted { $0.name.caseInsensitiveCompare($1.name) == .orderedAscending }
            .map { .makeItemViewModel(from: $0, with: action) }
    }
}

extension TransportPaymentsViewModel.ItemViewModel {
    
    static func makeItemViewModel(
        from operatorData: OperatorGroupData.OperatorData,
        with action: @escaping (String) -> Void
    ) -> TransportPaymentsViewModel.ItemViewModel {
        
        return .init(
            id: operatorData.code,
            icon: operatorData.iconImageData?.image,
            name: operatorData.name,
            inn: operatorINN(for: operatorData.description),
            select: action
        )
    }
    
    static func operatorINN(
        for description: String?
    ) -> String {
        
        guard let description,
              !description.isEmpty,
              description.isNumeric
        else { return "" }
        
        return "ИНН \(description)"
    }
}

extension TransportPaymentsViewModel {
    
    func link(for code: String) -> Link {
        
        let link: Link
        
        switch code {
        case Purefs.avtodorGroup:
            let action: (String) -> Void = { [weak self] puref in
                
                guard let self else { return }
                
                let paymentsViewModel = makePaymentsViewModel(
                    .servicePayment(puref: puref, additionalList: .none, amount: 0)
                )
                
                self.link = .init(.payments(paymentsViewModel))
            }
            
            link = .avtodor(action)
            
            // case Purefs.iForaMosParking:
            //     link = { fatalError() }()
            
        default:
            let paymentsViewModel = makePaymentsViewModel(
                .servicePayment(puref: code, additionalList: .none, amount: 0)
            )
            link = .payments(paymentsViewModel)
        }
        
        return link
    }
}
