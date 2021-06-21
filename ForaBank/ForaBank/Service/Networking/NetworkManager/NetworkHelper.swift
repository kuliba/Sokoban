//
//  NetworkHelper.swift
//  ForaBank
//
//  Created by Константин Савялов on 21.06.2021.
//

import Foundation

struct NetworkHelper {
    
    static func request(_ requestType: RequestType,
                        _ parameters: [String: String]? = nil,
                        _ complischen: @escaping () -> Void) {
        
        var tempParameters = [String: String]()
        let body = [String: AnyObject]()
        
        if parameters != nil {
            tempParameters = parameters ?? ["":""]
        } else {
            tempParameters = ["":""]
        }
        
        switch requestType.self {
        case .loginDo:
            NetworkManager<LoginDoCodableModel>.addRequest(.login, tempParameters, body) { model, error in
                
//                if error != nil {
//                    guard let error = error else { return }
//                    self.showAlert(with: "Ошибка", and: error)
//                } else {
//                    guard let statusCode = model?.statusCode else { return }
//                    if statusCode == 0 {
//                        guard let phone = model?.data?.phone else { return }
//                        DispatchQueue.main.async { [weak self] in
//                            let vc = CodeVerificationViewController(phone: phone)
//                            self?.navigationController?.pushViewController(vc, animated: true)
//                        }
//                    } else {
//                        guard let error = model?.errorMessage else { return }
//                        self.showAlert(with: "Ошибка", and: error)
//                    }
//                }
            
            }
        case .setDeviceSetting:
            NetworkManager<SetDeviceSettingDecodbleModel>.addRequest(.setDeviceSetting, tempParameters, body) { model, error in
            
            }
        case .csrf:
            NetworkManager<CSRFDecodableModel>.addRequest(.csrf, tempParameters, body) { model, error in
            
            }
        case .chackClient:
            NetworkManager<CheckClientDecodebleModel>.addRequest(.checkCkient, tempParameters, body) { model, error in
            
            }
        case .verifyCode:
            NetworkManager<VerifyCodeDecodebleModel>.addRequest(.verifyCode, tempParameters, body) { model, error in
            
            }
        case .doRegistration:
            NetworkManager<DoRegistrationDecodebleModel>.addRequest(.doRegistration, tempParameters, body) { model, error in
            
            }
        case .getCode:
            NetworkManager<GetCodeDecodebleModel>.addRequest(.getCode, tempParameters, body) { model, error in
            
            }
        case .installPushDevice:
            NetworkManager<InstallPushDeviceDecodebleModel>.addRequest(.installPushDevice, tempParameters, body) { model, error in
            
            }
        case .registerPushDeviceForUser:
            NetworkManager<RegisterPushDeviceDecodebleModel>.addRequest(.registerPushDeviceForUser, tempParameters, body) { model, error in
            
            }
        case .uninstallPushDevice:
            NetworkManager<InstallPushDeviceDecodebleModel>.addRequest(.uninstallPushDevice, tempParameters, body) { model, error in
            
            }
        case .getCardList:
            NetworkManager<GetCardListDecodebleModel>.addRequest(.getCardList, tempParameters, body) { model, error in
            
            }
        case .keyExchange:
            NetworkManager<KeyExchangeDecodebleModel>.addRequest(.keyExchange, tempParameters, body) { model, error in
            
            }
        case .getCountries:
            NetworkManager<GetCountriesDecodebleModel>.addRequest(.getCountries, tempParameters, body) { model, error in
            
            }
        case .anywayPaymentBegin:
            NetworkManager<AnywayPaymentBeginDecodebleModel>.addRequest(.anywayPaymentBegin, tempParameters, body) { model, error in
            
            }
        case .anywayPaymentMake:
            NetworkManager<AnywayPaymentMakeDecodableModel>.addRequest(.anywayPaymentMake, tempParameters, body) { model, error in
            
            }
        case .anywayPayment:
            NetworkManager<AnywayPaymentDecodableModel>.addRequest(.anywayPayment, tempParameters, body) { model, error in
            
            }
        case .prepareCard2Phone:
            NetworkManager<PrepareCard2PhoneDecodableModel>.addRequest(.prepareCard2Phone, tempParameters, body) { model, error in
            
            }
        case .getOwnerPhoneNumber:
            NetworkManager<GetOwnerPhoneNumberPhoneDecodableModel>.addRequest(.getOwnerPhoneNumber, tempParameters, body) { model, error in
            
            }
        case .fastPaymentBanksList:
            NetworkManager<FastPaymentBanksListDecodableModel>.addRequest(.fastPaymentBanksList, tempParameters, body) { model, error in
            
            }
        case .makeCard2Card:
            NetworkManager<MakeCard2CardDecodableModel>.addRequest(.makeCard2Card, tempParameters, body) { model, error in
            
            }
        case .getLatestPayments:
            NetworkManager<GetLatestPaymentsDecodableModel>.addRequest(.getLatestPayments, tempParameters, body) { model, error in
            
            }
        }
        
    }
    
    
}
