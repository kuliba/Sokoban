//
//  RootViewModel+rootEventPublisher.swift
//  ForaBank
//
//  Created by Igor Malyarov on 12.11.2024.
//

import Combine

typealias RootEvent = ForaBank.RootViewDomain.Select

extension RootViewModel {
        
    var rootEventPublisher: AnyPublisher<RootEvent, Never> {
        
        return Publishers.MergeMany(rootEventPublishers).eraseToAnyPublisher()
    }
}

private extension RootViewModel {
    
    var rootEventPublishers: [AnyPublisher<RootEvent, Never>] {
        
        mainViewRootEventPublishers + paymentsTransfersRootEventPublishers
    }
    
    private var mainViewRootEventPublishers: [AnyPublisher<RootEvent, Never>] {
        
        tabsViewModel.mainViewModel.rootEventPublishers
    }
    
    private var paymentsTransfersRootEventPublishers: [AnyPublisher<RootEvent, Never>] {
        
        switch tabsViewModel.paymentsModel {
        case let .legacy(legacy):
            return legacy.rootEventPublishers
            
        default:
            return []
        }
    }
}

// MARK: - MainView

extension RootEvent: Action {}

private extension MainViewModel {

    var rootEventPublishers: [AnyPublisher<RootEvent, Never>] {
        
        explicitRootEventPublishers + fastRootEventPublishers
    }

    private var explicitRootEventPublishers: [AnyPublisher<RootEvent, Never>] {
     
        sections
            .map(\.action)
            .map { $0.compactMap { $0 as? RootEvent }.eraseToAnyPublisher() }
    }

    private var fastRootEventPublishers: [AnyPublisher<RootEvent, Never>] {
        
        sections
            .compactMap { $0 as? MainSectionFastOperationView.ViewModel }
            .map(\.rootEventPublisher)
    }
}

private extension MainSectionFastOperationView.ViewModel {
    
    var rootEventPublisher: AnyPublisher<RootEvent, Never> {
        
        action
            .compactMap { $0 as? MainSectionViewModelAction.FastPayment.ButtonTapped }
            .map(\.operationType)
            .compactMap(\.rootEvent)
            .eraseToAnyPublisher()
    }
}

private extension MainSectionFastOperationView.ViewModel.FastOperations {
    
    var rootEvent: RootEvent? {
        
        switch self {
        case .byQr: return .scanQR
        default:    return nil
        }
    }
}

// MARK: - PaymentsTransfers legacy

private extension PaymentsTransfersViewModel {
    
    var rootEventPublishers: [AnyPublisher<RootEvent, Never>] {
        
        sections
            .filter { $0.type == .payments }
            .compactMap { $0 as? PTSectionPaymentsView.ViewModel }
            .map(\.rootEventPublisher)
    }
}

private extension PTSectionPaymentsView.ViewModel {
    
    var rootEventPublisher: AnyPublisher<RootEvent, Never> {
        
        action
            .compactMap { $0 as? PTSectionPaymentsViewAction.ButtonTapped.Payment }
            .compactMap(\.rootEvent)
            .eraseToAnyPublisher()
    }
}

private extension PTSectionPaymentsViewAction.ButtonTapped.Payment {
    
    var rootEvent: RootEvent? {
        
        switch type {
        case .qrPayment: return .scanQR
        default:         return nil
        }
    }
}

// MARK: - PaymentsTransfers v1
