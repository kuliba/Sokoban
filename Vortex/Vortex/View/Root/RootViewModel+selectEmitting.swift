//
//  RootViewModel+rootEventPublisher.swift
//  Vortex
//
//  Created by Igor Malyarov on 12.11.2024.
//

import Combine

typealias RootEvent = Vortex.FlowEvent<RootViewSelect, Never>

extension RootViewModel {
    
    var rootEventPublisher: AnyPublisher<RootEvent, Never> {
        
        return Publishers.MergeMany([
            rootRootEventPublisher,
            mainViewRootEventPublisher,
            paymentsTransfersRootEventPublisher
        ])
        .eraseToAnyPublisher()
    }
    
    private var rootRootEventPublisher: AnyPublisher<RootEvent, Never> {
        
        action.compactMap(\.rootEvent).eraseToAnyPublisher()
    }
    
    private var mainViewRootEventPublisher: AnyPublisher<RootEvent, Never> {
        
        tabsViewModel.mainViewModel.rootEventPublisher
    }
    
    private var paymentsTransfersRootEventPublisher: AnyPublisher<RootEvent, Never> {
        
        switch tabsViewModel.paymentsModel {
        case let .legacy(legacy):
            return legacy.rootEventPublisher
            
        case let .v1(switcher):
            return switcher.rootEventPublisher
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
    
    var rootEventPublisher: AnyPublisher<RootEvent, Never> {
        
        Publishers.MergeMany(rootEventPublishers).eraseToAnyPublisher()
    }
    
    private var rootEventPublishers: [AnyPublisher<RootEvent, Never>] {
        
        explicitRootEventPublishers + fastRootEventPublishers + [toolbarRootEventPublisher]
    }
    
    private var explicitRootEventPublishers: [AnyPublisher<RootEvent, Never>] {
        
        [action.compactMap(\.rootEvent).eraseToAnyPublisher()]
        
        + sections
            .map {
                
                $0.action.compactMap(\.rootEvent).eraseToAnyPublisher()
            }
    }
    
    private var fastRootEventPublishers: [AnyPublisher<RootEvent, Never>] {
        
        sections
            .compactMap { $0 as? MainSectionFastOperationView.ViewModel }
            .map(\.rootEventPublisher)
    }
    
    private var toolbarRootEventPublisher: AnyPublisher<RootEvent, Never> {
        
        action
            .compactMap {
                
                switch $0 as? MainViewModelAction.Toolbar {
                case .scanQR: return .select(.scanQR)
                default: return nil
                }
            }
            .eraseToAnyPublisher()
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

private extension FastOperations {
    
    var rootEvent: RootEvent? {
        
        switch self {
        case .byPhone:   return nil
        case .byQr:      return .select(.scanQR)
        case .templates: return .select(.templates)
        case .uin:       return .select(.searchByUIN)
        case .utility:   return nil
        }
    }
}

// MARK: - PaymentsTransfers legacy

private extension PaymentsTransfersViewModel {
    
    var rootEventPublisher: AnyPublisher<RootEvent, Never> {
        
        Publishers.MergeMany(rootEventPublishers).eraseToAnyPublisher()
    }
    
    private var rootEventPublishers: [AnyPublisher<RootEvent, Never>] {
        
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
        case .qrPayment: return .select(.scanQR)
        default:         return nil
        }
    }
}

// MARK: - PaymentsTransfers v1

private extension PaymentsTransfersSwitcherProtocol {
    
    var rootEventPublisher: AnyPublisher<RootEvent, Never> {
        
        switch self as? PaymentsTransfersSwitcher {
        case .none:
            return Empty().eraseToAnyPublisher()
            
        case let .some(switcher):
            return switcher.$state
                .compactMap { $0 }
                .flatMap(\.rootEventPublisher)
                .eraseToAnyPublisher()
        }
    }
}

private extension PaymentsTransfersSwitcher.State {
    
    var rootEventPublisher: AnyPublisher<RootEvent, Never> {
        
        switch self {
        case let .corporate(corporate):
            return corporate.rootEventPublisher
            
        case let .personal(personal):
            return personal.rootEventPublisher
        }
    }
}

private extension PaymentsTransfersCorporateDomain.Binder {
    
    var rootEventPublisher: AnyPublisher<RootEvent, Never> {
        
        return flow.$state
            .compactMap(\.navigation?.rootEvent)
            .eraseToAnyPublisher()
    }
}

private extension PaymentsTransfersCorporateNavigation {
    
    var rootEvent: RootEvent? {
        
        switch self {
        case .main:
            return .select(.outside(.tab(.main)))
            
        case .userAccount:
            return .select(.userAccount)
        }
    }
}

private extension PaymentsTransfersPersonalDomain.Binder {
    
    var rootEventPublisher: AnyPublisher<RootEvent, Never> {
        
        flow.$state
            .compactMap(\.navigation?.rootEvent)
            .eraseToAnyPublisher()
    }
}

private extension PaymentsTransfersPersonalNavigation {
    
    var rootEvent: RootEvent? {
        
        switch self {
        case .byPhoneTransfer:           return nil // .byPhoneTransfer
        case .main:                      return .select(.outside(.tab(.main)))
        case let .standardPayment(type): return .select(.standardPayment(type))
        case .scanQR:                    return .select(.scanQR)
        case .searchByUIN:               return .select(.searchByUIN)
        case .templates:                 return .select(.templates)
        case .userAccount:               return .select(.userAccount)
        }
    }
}
