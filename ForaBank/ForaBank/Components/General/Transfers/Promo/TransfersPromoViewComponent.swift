//
//  TransfersPromoViewComponent.swift
//  ForaBank
//
//  Created by Pavel Samsonov on 28.11.2022.
//  Refactor by Dmitry Martynov on 29.12.2022
//

import SwiftUI
import Combine

// MARK: - ViewModel

extension TransfersBannersView {
    
    class ViewModel: TransfersSectionViewModel {
        
        override var type: TransfersSectionType { .promo }
        
        let promoViewModel: MainSectionPromoView.ViewModel
        
        private var bindings = Set<AnyCancellable>()
        private let model: Model
        
        init(_ model: Model, promoViewModel: MainSectionPromoView.ViewModel) {
            
            self.model = model
            self.promoViewModel = promoViewModel
        }
        
        convenience init(model: Model, data: [BannerCatalogListData]) {
            
            model.authCatalogBanners.send(data)
            
            self.init(model, promoViewModel: .init(model, promoType: .auth))
            bind()
        }
        
        private func bind() {
            
            promoViewModel.action
                .receive(on: DispatchQueue.main)
                .sink { action in
                    
                    switch action {
                    case let payload as MainSectionViewModelAction.PromoAction.ButtonTapped:
                        
                        switch payload.actionData {
                        case let payload as BannerActionMigAuthTransfer:

                            self.action.send(TransfersPromoAction.Banner.Mig.Tap(countryId: payload.countryId,
                                                                                 bannerType: payload.type))
                            
                        case let payload as BannerActionDepositTransfer:
                            
                            self.action.send(TransfersPromoAction.Banner.Deposit.Tap(countryId: payload.countryId,
                                                                                     bannerType: payload.type))
                            
                        default:
                            break
                        }
                        
                    default:
                        break
                    }
                    
                }.store(in: &bindings)
        }
        
        
        static func createBanners(_ promoViewModel: MainSectionPromoView.ViewModel) -> [MainSectionPromoView.ViewModel.BannerViewModel] {
            
            return [
                .init(id: 1,
                      image: .image(.init("Transfers Banner Mig")),
                      action: .action {
                    
                    promoViewModel.action.send(MainSectionViewModelAction.PromoAction.ButtonTapped(actionData: BannerActionMigTransfer(countryId: "AM")))
                }),
                .init(id: 2,
                      image: .image(.init("Transfers Banner Deposit")),
                      action: .action {
                    
                    promoViewModel.action.send(MainSectionViewModelAction.PromoAction.ButtonTapped(actionData: BannerActionDepositTransfer(countryId: "AM")))
                })
            ]
        }
    }
}

// MARK: - Action

enum TransfersPromoAction {
    
    enum Banner {
        
        enum Mig {
            
            struct Tap: Action {
                
                let countryId: String
                let bannerType: BannerActionType
            }
        }
        
        enum Deposit {
            
            struct Tap: Action {
                
                let countryId: String
                let bannerType: BannerActionType
            }
        }
    }
}

// MARK: - View

struct TransfersBannersView: View {
    
    let viewModel: TransfersBannersView.ViewModel
    
    var body: some View {
       
        MainSectionPromoView(viewModel: viewModel.promoViewModel)
    }
}
