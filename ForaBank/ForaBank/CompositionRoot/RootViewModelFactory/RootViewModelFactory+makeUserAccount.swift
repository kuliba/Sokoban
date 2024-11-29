//
//  RootViewModelFactory+makeUserAccount.swift
//  ForaBank
//
//  Created by Igor Malyarov on 29.11.2024.
//

extension RootViewModelFactory {
    
    func makeUserAccount(
        route: UserAccountRoute = .init(),
        close: @escaping () -> Void
    ) -> UserAccountViewModel? {
        
        guard let clientInfo = model.clientInfo.value 
        else { return nil }

        model.action.send(ModelAction.C2B.GetC2BSubscription.Request())
        
        let fastPaymentsFactory = FastPaymentsFactory(
            fastPaymentsViewModel: .new({
                
                self.makeNewFastPaymentsViewModel()
            })
        )

        let navigationStateManager = makeNavigationStateManager(
            modelEffectHandler: .init(model: model),
            otpServices: .init(httpClient, logger),
            otpDeleteBankServices: .init(for: httpClient, infoNetworkLog),
            fastPaymentsFactory: fastPaymentsFactory,
            makeSubscriptionsViewModel: makeSubscriptionsViewModel(
                getProducts: getSubscriptionProducts,
                c2bSubscription: model.subscriptions.value
            ),
            duration: 60
        )
        
        return .init(
            route: route,
            navigationStateManager: navigationStateManager,
            model: model,
            clientInfo: clientInfo,
            dismissAction: close,
            scheduler: schedulers.main
        )
    }
}
