//
//  ProductProfileViewModel.swift
//  
//
//  Created by Andryusina Nataly on 06.02.2024.
//

import Foundation
import Combine
import CombineSchedulers
import UIPrimitives
import CardGuardianModule

public final class ProductProfileViewModel: ObservableObject {
    
    @Published public private(set) var state: ProductProfileNavigation.State
    
    private let product: Product
    private let navigationStateManager: ProductProfileNavigationStateManager
    
    private let stateSubject = PassthroughSubject<ProductProfileNavigation.State, Never>()
    private let scheduler: AnySchedulerOfDispatchQueue
    
    #warning("need remove/refactoring after add business logic")
    public var needBlockConfig: Bool {
        product.isUnBlock
    }
    
    public init(
        product: Product,
        initialState: ProductProfileNavigation.State,
        navigationStateManager: ProductProfileNavigationStateManager,
        scheduler: AnySchedulerOfDispatchQueue = .makeMain()
    ) {
        self.product = product
        self.state = initialState
        self.navigationStateManager = navigationStateManager
        self.scheduler = scheduler
        
        stateSubject
            .removeDuplicates()
            .receive(on: scheduler)
            .assign(to: &$state)
    }
}

public extension ProductProfileViewModel {
    
    struct Product {
        let isUnBlock: Bool
        let isShowOnMain: Bool
        
        public init(isUnBlock: Bool, isShowOnMain: Bool) {
            self.isUnBlock = isUnBlock
            self.isShowOnMain = isShowOnMain
        }
    }
}

public extension ProductProfileViewModel {
    
    enum State: Equatable {
        
        case initial
        case openPanel
        case toggleLock
        case changePin
        case showOnMain
    }
}

public struct ProductProfileNavigationStateManager {
    
    let reduce: ProductProfileReducer.Reduce
    let makeCardGuardianViewModel: MakeCardGuardianViewModel
    
    public init(
        reduce: @escaping ProductProfileReducer.Reduce,
        makeCardGuardianViewModel: @escaping MakeCardGuardianViewModel
    ) {
        self.reduce = reduce
        self.makeCardGuardianViewModel = makeCardGuardianViewModel
    }
}

// MARK: - CardGuardian

public extension ProductProfileViewModel {
    
    func openCardGuardian(){
        
        let cardGuardianViewModel = navigationStateManager.makeCardGuardianViewModel(scheduler)
        let cancellable = cardGuardianViewModel.$state
            .removeDuplicates()
            .receive(on: scheduler)
            .sink { [weak self] state in
                
                switch state.event {
                    
                case .none:
                    print("sink none")
                case let .some(event):
                    switch event {
                        
                    case .appear:
                        self?.event(.openCardGuardianPanel)

                    case let .buttonTapped(tap):
                        switch tap {
                            
                        case .toggleLock:
                            self?.event(.dismissDestinationAndShowAlertCardGuardian)

                        case .changePin:
                            self?.event(.dismissDestinationAndShowAlertChangePin)

                        case .showOnMain:
                            self?.event(.dismissDestination)
                        }
                    }
                }
            }
        
        state.destination = .init(cardGuardianViewModel, cancellable)
        cardGuardianViewModel.event(.appear)
    }
    
    func showAlertChangePin(){
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            
            self?.state.alert = .init(
                title: "Активируйте сертификат",
                message: "\nСертификат позволяет просматривать CVV по картам и изменять PIN-код\nв течение 6 месяцев\n\nЭто мера предосторожности во избежание мошеннических операций",
                primaryButton: .init(
                    type: .cancel,
                    title: "Отмена",
                    event: .closeAlert),
                secondaryButton: .init(
                    type: .default,
                    title: "Активировать",
                    event: .closeAlert)
            )
        }
    }
    
    func showAlertCardGuardian(){
        
        let title = titleForAlertCardGuardian
        let message = messageForAlertCardGuardian
        let titleSecondaryButton = titleSecondaryButtonForAlertCardGuardian

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            
            self?.state.alert = .init(
                title: title,
                message: message,
                primaryButton: .init(
                    type: .cancel,
                    title: "Отмена",
                    event: .closeAlert),
                secondaryButton: .init(
                    type: .default,
                    title: titleSecondaryButton,
                    event: .closeAlert)
            )
        }
    }
    
    private var titleForAlertCardGuardian: String {
        
        self.product.isUnBlock ? "Заблокировать карту?" : "Разблокировать карту?"
    }
    
    private var messageForAlertCardGuardian: String? {
        
        self.product.isUnBlock ? "Карту можно будет разблокировать в приложении или в колл-центре" : nil
    }
    
    private var titleSecondaryButtonForAlertCardGuardian: String {
        
        self.product.isUnBlock ? "ОК" : "Да"
    }
}

// MARK: - Types

public extension ProductProfileNavigationStateManager {
    
    typealias MakeCardGuardianViewModel = (AnySchedulerOfDispatchQueue) -> CardGuardianViewModel
}

extension ProductProfileViewModel {
    
    public func event(_ event: ProductProfileNavigation.Event) {
        
        let (state, effect) = navigationStateManager.reduce(state, event)
        stateSubject.send(state)
        
        if let effect {
            
            handleEffect(effect)
        }
    }
    
    private func handleEffect(_ effect: ProductProfileNavigation.Effect) {
        
        switch effect {
        case .showAlertChangePin:
            showAlertChangePin()
        case .showAlertCardGuardian:
            showAlertCardGuardian()
        }
    }
}
