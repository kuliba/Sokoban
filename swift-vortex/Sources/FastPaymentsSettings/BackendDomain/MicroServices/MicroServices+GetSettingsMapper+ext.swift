//
//  MicroServices+GetSettingsMapper+ext.swift
//
//
//  Created by Igor Malyarov on 26.01.2024.
//

public extension MicroServices.SettingsGetter
where Contract == UserPaymentSettings.PaymentContract,
      Consent == FastPaymentsSettings.Consent?,
      Settings == UserPaymentSettings {
    
    typealias GetProducts = () -> [Product]
    typealias GetBanks = () -> [Bank]
    
    convenience init(
        getContract: @escaping GetContract,
        getConsent: @escaping GetConsent,
        getBankDefault: @escaping GetBankDefault,
        getProducts: @escaping GetProducts,
        getBanks: @escaping GetBanks
    ) {
        let mapper = MicroServices.GetSettingsMapper(
            getProducts: getProducts,
            getBanks: getBanks
        )
        
        let mapToMissing: MapToMissing = { consent in
            
            return .success(.missingContract(.init(
                banks: getBanks(),
                consent: consent
            )))
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
