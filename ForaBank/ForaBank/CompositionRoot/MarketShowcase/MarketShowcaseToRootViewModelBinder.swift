//
//  MarketShowcaseToRootViewModelBinder.swift
//  ForaBank
//
//  Created by Andryusina Nataly on 21.10.2024.
//

import Combine
import CombineSchedulers
import Foundation
import LandingUIComponent
import MarketShowcase

final class MarketShowcaseToRootViewModelBinder {
    
    private let marketShowcase: MarketShowcaseDomain.Binder
    private let rootViewModel: RootViewModel
    private let scheduler: AnySchedulerOf<DispatchQueue>
    
    init(
        marketShowcase: MarketShowcaseDomain.Binder,
        rootViewModel: RootViewModel,
        scheduler: AnySchedulerOf<DispatchQueue>
    ) {
        self.marketShowcase = marketShowcase
        self.rootViewModel = rootViewModel
        self.scheduler = scheduler
    }
    
    func bind() -> Set<AnyCancellable> {
        
        var bindings = Set<AnyCancellable>()
        
        rootViewModel.tabsViewModel.marketShowcaseBinder.flow.$state
            .compactMap(\.outside)
            .receive(on: scheduler)
            .sink { [weak rootViewModel] in
                
                rootViewModel?.handleOutside($0)
            }
            .store(in: &bindings)
        
        rootViewModel.tabsViewModel.marketShowcaseBinder.flow.$state
            .compactMap(\.informer)
            .receive(on: scheduler)
            .sink { [weak rootViewModel] in
                
                rootViewModel?.model.action.send(ModelAction.Informer.Show(informer: $0))
            }
            .store(in: &bindings)

        return bindings
    }
}

extension RootViewModel {
    
    func openCard() {
        
        if model.onlyCorporateCards {
            model.productsOpenAccountURL.absoluteString.openLink()
        } else {
            openOrderCard()
        }
    }
    
    func openOrderCard() {
        
        let authProductsViewModel = AuthProductsViewModel(
            model,
            products: model.catalogProducts.value,
            dismissAction: { [weak self] in
                self?.resetLink()
            })
        
        setLink(to: .openCard(authProductsViewModel))
    }
    
    func orderSticker() {
        
        if model.onlyCorporateCards {
            alert = .disableForCorporateCard { [weak self] in
                self?.action.send(RootViewModelAction.CloseAlert())
            }
        } else {
            
            let productsCard = model.products(.card)
            
            if productsCard == nil ||
                productsCard?.contains(where: {
                    ($0 as? ProductCardData)?.isMain == true }) == false
            {
                alert = .needOrderCard(primaryAction: { [weak self] in
                    self?.openOrderCard()
                })
            } else {
                setLink(to: .paymentSticker)
            }
        }
    }
    
    func handleOutside(
        _ outside: MarketShowcaseDomain.FlowState.Status.Outside
    ) {
        switch outside {
        case .main:
            rootActions.switchTab(.main)
            
        case let .openURL(linkURL):
            linkURL.openLink()
            
        case let .landing(type):
            landing(by: type)
        }
    }
}

private extension RootViewModel {
    
    func landing(by type: String) {
        
        landingServices.loadLandingByType(type) { [weak self] in
            
            guard let self else { return }
            
            switch $0 {
            case let .success(landing):
                
                let viewModel = model.landingViewModelFactory(
                    result: landing,
                    config: type == "abroadSticker" ? .stickerDefault : .default,
                    landingActions: { self.landingActions($0) },
                    outsideAction: {_ in },
                    orderCard: openCard
                )
                
                setLink(to: .landing(viewModel, type == "abroadSticker"))
                
            case .failure:
                break
            }
        }
    }
    
    func landingActions(_ event: LandingEvent) {
        switch event {
        case let .card(action): 
            cardActions(action)
            
        case let .sticker(action):
            stickerActions(action)
            
        case .goToBack:
            resetLink()
            
        default:break
        }
    }
            
    func cardActions(_ action: LandingEvent.Card) {
        switch action {
        case .goToMain: 
            goToMain()
            
        case let .openUrl(linkURL):
            linkURL.openLink()
            
        default: break
        }
    }
    
    func stickerActions(_ action: LandingEvent.Sticker) {
        switch action {
        case .goToMain: 
            goToMain()

        case .order: 
            orderSticker()
        }
    }
    
    func goToMain() {
        resetLink()
        rootActions.switchTab(.main)
    }
}

private extension MarketShowcaseFlowState {
    
    var outside: Status.Outside? {
        
        guard case let .outside(outside) = self.status
        else { return nil }
        
        return outside
    }
}

private extension MarketShowcaseFlowState {
    
    var informer: InformerPayload? {
        
        guard case let .informer(informerPayload) = self.status
        else { return nil }
        
        return informerPayload
    }
}

