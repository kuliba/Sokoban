//
//  TransportPaymentsViewModel.swift
//  ForaBank
//
//  Created by Igor Malyarov on 15.06.2023.
//

import Combine
import CvvPin
import Foundation
import SwiftUI

final class TransportPaymentsViewModel: ObservableObject {
    
    @Published private(set) var destination: Destination?
    
    let operators: [OperatorGroupData.OperatorData]
    let latestPayments: PaymentsServicesLatestPaymentsSectionViewModel
    
    typealias MakePaymentsViewModel = (Payments.Operation.Source) -> PaymentsViewModel
    typealias HandleError = (String) -> Void
    
    private let makePaymentsViewModel: MakePaymentsViewModel
    private let handleError: HandleError
    
    init(
        operators: [OperatorGroupData.OperatorData],
        latestPayments: PaymentsServicesLatestPaymentsSectionViewModel,
        makePaymentsViewModel: @escaping MakePaymentsViewModel,
        handleError: @escaping HandleError
    ) {
        self.operators = operators
        self.latestPayments = latestPayments
        self.makePaymentsViewModel = makePaymentsViewModel
        self.handleError = handleError
        
        latestPayments.action
            .compactMap { $0 as? PaymentsServicesSectionViewModelAction.LatestPayments.ItemDidTapped }
            .map(Payments.Operation.Source.init(withItemDidTapped:))
            .map(makePaymentsViewModel)
            .map(Destination.payment)
            .receive(on: DispatchQueue.main)
            .assign(to: &$destination)
    }
    
    enum Destination {
        
        case payment(PaymentsViewModel)
        case mosParking
    }
}

extension TransportPaymentsViewModel {
    
    func setDestination(to isActive: Bool) {
        
        if !isActive { destination = nil }
    }
}

extension TransportPaymentsViewModel {
    
    func select(track: Track) {
        
        do {
            let link = try destination(for: track)
            
            DispatchQueue.main.async { [weak self] in
                
                self?.destination = link
            }
        } catch {
            switch track {
            case let .puref(puref):
                handleError("Ошибка создания платежа для оператора \(puref)")
                
            case let .source(source):
                handleError("Ошибка создания платежа для \(source)")
            }
        }
    }
    
    enum Track {
        
        case puref(String)
        case source(Payments.Operation.Source)
    }
    
    func destination(
        for track: Track
    ) throws -> Destination {
        
        switch track {
        case let .puref(puref):
            
            let source: Payments.Operation.Source
            
            switch puref {
            case Purefs.avtodorGroup:
                source = .avtodor
                
            case Purefs.iForaMosParking:
                return .mosParking
                
            case Purefs.iForaGibdd:
                source = .gibdd
                
            default:
                source = .makeServicePayment(puref: puref)
            }
            
            return .payment(makePaymentsViewModel(source))
            
        case let .source(source):
            return .payment(makePaymentsViewModel(source))
        }
    }
    
    func selectMosParkingID(id: String) {
        
        let source: Payments.Operation.Source = .makeServicePayment(
            puref: Purefs.iForaMosParking,
            additionalList: [additional(value: id)]
        )
        select(track: .source(source))
    }
    
    private func additional(
        value: String
    ) -> PaymentServiceData.AdditionalListData {
        
        .init(
            fieldTitle: nil,
            fieldName: "a3_serviceId_2_1",
            fieldValue: value,
            svgImage: nil
        )
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
        
        let action: (String) -> Void = { [weak self] puref in
            
            self?.select(track: .puref(puref))
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
            inn: nil,
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
    
    func mosParkingPaymentAction() {
        
        let paymentsViewModel = makePaymentsViewModel(
            .servicePayment(
                puref: Purefs.iForaMosParking,
                additionalList: .none,
                amount: 0, 
                productId: nil
            )
        )
        
        destination = .payment(paymentsViewModel)
    }
    
    func continueAction() {
        
    }
}

private extension Payments.Operation.Source {
    
    typealias ItemDidTapped = PaymentsServicesSectionViewModelAction.LatestPayments.ItemDidTapped
    
    init(withItemDidTapped itemDidTapped: ItemDidTapped) {
        
        self = .servicePayment(
            puref: itemDidTapped.latestPayment.puref,
            additionalList: itemDidTapped.latestPayment.additionalList,
            amount: itemDidTapped.latestPayment.amount,
            productId: nil
        )
    }
    
    static func makeServicePayment(
        puref: String,
        additionalList: [PaymentServiceData.AdditionalListData]? = nil,
        amount: Double = 0
    ) -> Self {
        
        .servicePayment(
            puref: puref,
            additionalList: additionalList,
            amount: amount, 
            productId: nil
        )
    }
}
