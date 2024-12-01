//
//  RootViewModel+rootEventPublisher.swift
//  ForaBank
//
//  Created by Igor Malyarov on 12.11.2024.
//

import Combine

typealias RootEvent = RootViewSelect

extension RootViewModel {
        
    var rootEventPublisher: AnyPublisher<RootEvent, Never> {
        
        return Publishers.MergeMany(rootEventPublishers).eraseToAnyPublisher()
    }
}

private extension RootViewModel {
    
    var rootEventPublishers: [AnyPublisher<RootEvent, Never>] {
        
        [rootRootEventPublisher] 
        + mainViewRootEventPublishers
        + paymentsTransfersRootEventPublishers
    }
    
    private var rootRootEventPublisher: AnyPublisher<RootEvent, Never> {
        
        action.compactMap(\.rootEvent).eraseToAnyPublisher()
    }
    
    private var mainViewRootEventPublishers: [AnyPublisher<RootEvent, Never>] {
        
        tabsViewModel.mainViewModel.rootEventPublishers
    }
    
    private var paymentsTransfersRootEventPublishers: [AnyPublisher<RootEvent, Never>] {
        
        switch tabsViewModel.paymentsModel {
        case let .legacy(legacy):
            return legacy.rootEventPublishers
            
        case let .v1(switcher):
            return switcher.rootEventPublishers
        }
    }
}

private extension PaymentsTransfersSwitcherProtocol {
    
    var rootEventPublishers: [AnyPublisher<RootEvent, Never>] {
        
        switch self as? PaymentsTransfersSwitcher {
        case .none:
            return []
            
        case let .some(switcher):
            return switcher.rootEventPublishers
        }
    }
}

private extension PaymentsTransfersSwitcher {
    
    var rootEventPublishers: [AnyPublisher<RootEvent, Never>] {
        
        switch state {
        case .none:
            return []
            
        case let .corporate(corporate):
            return corporate.rootEventPublishers
            
        case let .personal(personal):
            return personal.rootEventPublishers
        }
    }
}

private extension PaymentsTransfersCorporateDomain.Binder {
    
    var rootEventPublishers: [AnyPublisher<RootEvent, Never>] {
        
        let flowRootEventPublisher = flow.$state
            .compactMap(\.navigation?.rootEvent)
            .eraseToAnyPublisher()
        
        return [flowRootEventPublisher]
    }
}

private extension PaymentsTransfersCorporateNavigation {
    
    var rootEvent: RootEvent? {
        
        switch self {
        case .userAccount:
            return .userAccount
        }
    }
}

private extension PaymentsTransfersPersonalDomain.Binder {
    
    var rootEventPublishers: [AnyPublisher<RootEvent, Never>] {
        
        let flowRootEventPublisher = flow.$state
            .compactMap(\.navigation?.rootEvent)
            .eraseToAnyPublisher()
        
        return [flowRootEventPublisher]
    }
}

private extension PaymentsTransfersPersonalNavigation {
    
    var rootEvent: RootEvent? {
        
        switch self {
        case .userAccount:
            return .userAccount
        }
    }
}

// MARK: - MainView

extension RootEvent: Action {}

private extension Action {
    
    var rootEvent: RootEvent? { self as? RootEvent }
    
    var fastButtonTapped: MainSectionViewModelAction.FastPayment.ButtonTapped? {
        
        self as? MainSectionViewModelAction.FastPayment.ButtonTapped
    }
}

private extension MainViewModel {

    var rootEventPublishers: [AnyPublisher<RootEvent, Never>] {
        
        explicitRootEventPublishers + fastRootEventPublishers
    }

    private var explicitRootEventPublishers: [AnyPublisher<RootEvent, Never>] {
        
        sections
            .map {
                $0.action.compactMap(\.rootEvent).eraseToAnyPublisher()
            }
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
            .compactMap(\.fastButtonTapped)
            .map(\.operationType)
            .compactMap(\.rootEvent)
            .eraseToAnyPublisher()
    }
}

private extension MainSectionFastOperationView.ViewModel.FastOperations {
    
    var rootEvent: RootEvent? {
        
        switch self {
        case .byQr:      return .scanQR
        case .templates: return .templates
        case .byPhone:   return nil
        case .utility:       return nil
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
