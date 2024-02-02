//
//  MicroServices+GetSettingsMapper+ext.swift
//
//
//  Created by Igor Malyarov on 26.01.2024.
//

public extension MicroServices.GetSettings
where Contract == UserPaymentSettings.PaymentContract,
      Consent == FastPaymentsSettings.Consent?,
      Settings == UserPaymentSettings {
    
    typealias GetProducts = () -> [Product]
    typealias GetSelectableBanks = () -> [ConsentList.SelectableBank]

    convenience init(
        getContract: @escaping GetContract,
        getConsent: @escaping GetConsent,
        getBankDefault: @escaping GetBankDefault,
        getProducts: @escaping GetProducts,
        getSelectableBanks: @escaping GetSelectableBanks
    ) {
        let mapper = MicroServices.GetSettingsMapper(
            getProducts: getProducts,
            getSelectableBanks: getSelectableBanks
        )
        
        let mapToMissing: MapToMissing = { consent in
            
            guard let consent
            else { return .failure(.connectivityError) }
            
            return .success(.missingContract(consent: .success(.init(
                banks: getSelectableBanks(),
                consent: consent,
                mode: .collapsed,
                searchText: ""
            ))))
        }
        
        self.init(
            getContract: getContract,
            getConsent: getConsent,
            getBankDefault: getBankDefault,
            mapToMissing: mapToMissing,
            mapToSettings: mapper.mapToSettings
        )
    }
}
