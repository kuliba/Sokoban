//
//  MicroServices+GetSettingsMapper+ext.swift
//
//
//  Created by Igor Malyarov on 26.01.2024.
//

public extension MicroServices.GetSettings
where Contract == UserPaymentSettings.PaymentContract,
      Consent == ConsentListState,
      Settings == UserPaymentSettings {
    
    typealias GetProducts = () -> [Product]
    
    convenience init(
        getContract: @escaping GetContract,
        getConsent: @escaping GetConsent,
        getBankDefault: @escaping GetBankDefault,
        getProducts: @escaping GetProducts
    ) {
        let mapper = MicroServices.GetSettingsMapper(getProducts: getProducts)
        
        self.init(
            getContract: getContract,
            getConsent: getConsent,
            getBankDefault: getBankDefault,
            mapToMissing: { .success(.missingContract($0)) },
            mapToSettings: mapper.mapToSettings
        )
    }
}
