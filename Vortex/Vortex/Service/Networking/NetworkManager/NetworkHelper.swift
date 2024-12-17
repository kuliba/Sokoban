//
//  NetworkHelper.swift
//  ForaBank
//
//  Created by Константин Савялов on 21.06.2021.
//

import Foundation

final class Dict {
    private init() { }
    
    static let shared = Dict()
    
    var countries : [CountriesList]?
    var banks : [BanksList]?
    var paymentList: [PaymentSystemList]?
    var currencyList: [CurrencyList]?
    var organization: [GetAnywayOperatorsListDatum]?
    var bankFullInfoList: [BankFullInfoList]?
    var mobileSystem: [MobileList]?

}

struct NetworkHelper {
    
    static func request(_ requestType: RequestType,
                        _ parameters: [String: String]? = nil,
                        _ completion: @escaping (_ model: Any? ,_ error: String?) -> Void) {
        
        //_ cardList: [Datum]?,_ error: String?)->()
        
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
            
        case .getProductList:
            if ProductList.shared.productList != nil {
                completion(ProductList.shared.productList, nil)
            }
            
            NetworkManager<GetProductListDecodableModel>.addRequest(.getProductList, tempParameters, body) { model, error in
                if error != nil {
                    completion(nil, error)
                }
                guard let model = model else { return }
                
                if model.statusCode == 0 {
                    guard let data = model.data else { return }

                    ProductList.shared.productList = data
                    completion(data, nil)
                    
                } else {
                    completion(nil ,model.errorMessage)
                   
                }
            }
            
        case .keyExchange:
            NetworkManager<KeyExchangeDecodebleModel>.addRequest(.keyExchange, tempParameters, body) { model, error in
            
            }
        case .getCountries:
            if let countriesListSerial = UserDefaults().object(forKey: "CountriesListSerial") as? String {

                guard let documentsDirectoryUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
                let filePath = documentsDirectoryUrl.appendingPathComponent("CountriesList.json")
                
                // Read data from .json file and transform data into an array
                do {
                    let data = try Data(contentsOf: filePath, options: [])
                    
                    let list = try JSONDecoder().decode(GetCountriesDataClass.self, from: data)
                    Dict.shared.countries = list.countriesList
                    completion(list.countriesList, nil)
                } catch {

                }
                
                getCountries(withId: countriesListSerial)
                
            } else {
                getCountries()
            }
            
            func getCountries(withId: String? = nil) {
                
                let param = ["serial" : withId ?? ""]
                NetworkManager<GetCountriesDecodebleModel>.addRequest(.getCountries, param, body) { model, error in
                    if error != nil {
                        guard let error = error else { return }
                        completion(nil, error)
                    } else {
                        guard let statusCode = model?.statusCode else { return }
                        if statusCode == 0 {
                            if model?.data?.serial != withId {
                                
                                guard let data = model?.data else { return }
                                
                                let pathDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                                try? FileManager().createDirectory(at: pathDirectory, withIntermediateDirectories: true)
                                let filePath = pathDirectory.appendingPathComponent("CountriesList.json")

                                let json = try? JSONEncoder().encode(data)

                                do {
                                     try json!.write(to: filePath)
                                } catch {
                                }
                                
                                UserDefaults().set(data.serial, forKey: "CountriesListSerial")
                                
                                guard let countries = model?.data?.countriesList else { return }
                                Dict.shared.countries = countries
                                completion(countries, nil)
                            } else {
                            }
                            
                        } else {
                            let error = model?.errorMessage ?? "nil"
                            completion(nil, error)
                        }
                    }
                }
            }
            
            
        case .getBankFullInfoList:
            if let banksListSerial = UserDefaults().object(forKey: "BankFullInfoListSerial") as? String {

                guard let documentsDirectoryUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
                let filePath = documentsDirectoryUrl.appendingPathComponent("BankFullInfoList.json")
                
                // Read data from .json file and transform data into an array
                do {
                    let data = try Data(contentsOf: filePath, options: [])
                    
                    let list = try JSONDecoder().decode(GetFullBankInfoListDecodableModelDataClass.self, from: data)
                    Dict.shared.bankFullInfoList = list.bankFullInfoList
                    completion(list.bankFullInfoList, nil)
                } catch {
                }
                
                getBanks(withId: banksListSerial)
                
            } else {
                getBanks()
            }
            
            func getBanks(withId: String? = nil) {
//                let bodyTmp = [
//                    "bic": ""
//                ] as [String : AnyObject]
                let param = ["bic": "","serial" : withId ?? ""]
                NetworkManager<GetFullBankInfoListDecodableModel>.addRequest(.getFullBankInfoList, param, [:]) { model, error in
                    if error != nil {
                        guard let error = error else { return }
                        completion(nil, error)
                    } else {
                        guard let statusCode = model?.statusCode else { return }
                        if statusCode == 0 {
                            if model?.data?.serial != withId {
                                
                                guard let data = model?.data else { return }
                                
                                let pathDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                                try? FileManager().createDirectory(at: pathDirectory, withIntermediateDirectories: true)
                                let filePath = pathDirectory.appendingPathComponent("BankFullInfoList.json")

                                let json = try? JSONEncoder().encode(data)

                                do {
                                     try json!.write(to: filePath)
                                } catch {
                                }
                                
                                UserDefaults().set(data.serial, forKey: "BankFullInfoListSerial")
                                
                                guard let banks = model?.data?.bankFullInfoList else { return }
                                Dict.shared.bankFullInfoList = banks
                                completion(banks, nil)
                            } else {
                            }
                            
                        } else {
                            let error = model?.errorMessage ?? "nil"
                            completion(nil, error)
                        }
                    }
                }
            }
            
        case .getBanks:
                        
            if let banksListSerial = UserDefaults().object(forKey: "BanksListSerial") as? String {

                guard let documentsDirectoryUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
                let filePath = documentsDirectoryUrl.appendingPathComponent("BanksList.json")
                
                // Read data from .json file and transform data into an array
                do {
                    let data = try Data(contentsOf: filePath, options: [])
                    
                    let list = try JSONDecoder().decode(GetBanksDataClass.self, from: data)
                    Dict.shared.banks = list.banksList
                    completion(list.banksList, nil)
                } catch {
                }
                
                getBanks(withId: banksListSerial)
                
            } else {
                getBanks()
            }
            
            func getBanks(withId: String? = nil) {
                
                let param = ["serial" : withId ?? ""]
                NetworkManager<GetBanksDecodableModel>.addRequest(.getBanks, param, body) { model, error in
                    if error != nil {
                        guard let error = error else { return }
                        completion(nil, error)
                    } else {
                        guard let statusCode = model?.statusCode else { return }
                        if statusCode == 0 {
                            if model?.data?.serial != withId {
                                
                                guard let data = model?.data else { return }
                                
                                let pathDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                                try? FileManager().createDirectory(at: pathDirectory, withIntermediateDirectories: true)
                                let filePath = pathDirectory.appendingPathComponent("BanksList.json")

                                let json = try? JSONEncoder().encode(data)

                                do {
                                     try json!.write(to: filePath)
                                } catch {
                                }
                                
                                UserDefaults().set(data.serial, forKey: "BanksListSerial")
                                
                                guard let banks = model?.data?.banksList else { return }
                                Dict.shared.banks = banks
                                completion(banks, nil)
                            } else {
                            }
                            
                        } else {
                            let error = model?.errorMessage ?? "nil"
                            completion(nil, error)
                        }
                    }
                }
            }
            
        case .getPaymentSystemList:
            
            if let banksListSerial = UserDefaults().object(forKey: "PaymentListSerial") as? String {

                guard let documentsDirectoryUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
                let filePath = documentsDirectoryUrl.appendingPathComponent("PaymentsList.json")
                
                // Read data from .json file and transform data into an array
                do {
                    let data = try Data(contentsOf: filePath, options: [])
                    
                    let list = try JSONDecoder().decode(GetPaymentSystemListDataClass.self, from: data)
                    Dict.shared.paymentList = list.paymentSystemList
                    completion(list.paymentSystemList, nil)
                } catch {
                    
                }
                getPayments(withId: banksListSerial)
            } else {
                getPayments()
            }
            
            func getPayments(withId: String? = nil) {
                
                let param = ["serial" : withId ?? ""]
                NetworkManager<GetPaymentSystemListDecodableModel>.addRequest(.getPaymentSystemList, param, body) { model, error in
                    if error != nil {
                        guard let error = error else { return }
                        completion(nil, error)
                    } else {
                        guard let statusCode = model?.statusCode else { return }
                        if statusCode == 0 {
                            if model?.data?.serial != withId {
                                
                                guard let data = model?.data else { return }
                                
                                let pathDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                                try? FileManager().createDirectory(at: pathDirectory, withIntermediateDirectories: true)
                                let filePath = pathDirectory.appendingPathComponent("PaymentsList.json")

                                let json = try? JSONEncoder().encode(data)

                                do { try json!.write(to: filePath) }
                                catch { }
                                
                                UserDefaults().set(data.serial, forKey: "PaymentListSerial")
                                
                                guard let payments = model?.data?.paymentSystemList else { return }
                                Dict.shared.paymentList = payments
                                completion(payments, nil)
                            } else {
                            }
                            
                        } else {
                            let error = model?.errorMessage ?? "nil"
                            completion(nil, error)
                        }
                    }
                }
            }
            
        case .getMobileSystem:
            
            if let banksListSerial = UserDefaults().object(forKey: "getMobileSystem") as? String {

                guard let documentsDirectoryUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
                let filePath = documentsDirectoryUrl.appendingPathComponent("getMobileSystem.json")
                
                // Read data from .json file and transform data into an array
                do {
                    let data = try Data(contentsOf: filePath, options: [])
                    
                    let list = try JSONDecoder().decode(GetMobileListDataClass.self, from: data)
                    Dict.shared.mobileSystem = list.mobileList
                    completion(list.mobileList, nil)
                } catch {
                    
                }
                getPayments(withId: banksListSerial)
            } else {
                getPayments()
            }
            
            func getPayments(withId: String? = nil) {
                
                let param = ["serial" : withId ?? ""]
                NetworkManager<GetMobileListDecodableModel>.addRequest(.getMobileList, param, body) { model, error in
                    if error != nil {
                        guard let error = error else { return }
                        completion(nil, error)
                    } else {
                        guard let statusCode = model?.statusCode else { return }
                        if statusCode == 0 {
                            if model?.data?.serial != withId {
                                
                                guard let data = model?.data else { return }
                                
                                let pathDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                                try? FileManager().createDirectory(at: pathDirectory, withIntermediateDirectories: true)
                                let filePath = pathDirectory.appendingPathComponent("getMobileSystem.json")

                                let json = try? JSONEncoder().encode(data)

                                do { try json!.write(to: filePath) }
                                catch {  }
                                
                                UserDefaults().set(data.serial, forKey: "getMobileSystem")
                                
                                guard let payments = model?.data?.mobileList else { return }
                                Dict.shared.mobileSystem = payments
                                completion(payments, nil)
                            } else {

                            }
                            
                        } else {
                            let error = model?.errorMessage ?? "nil"
                            completion(nil, error)
                        }
                    }
                }
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
        case .getExchangeCurrencyRates:
            /// Курс обмена валют
            NetworkManager<GetExchangeCurrencyRatesDecodableModel>.addRequest(.getExchangeCurrencyRates, tempParameters, body) { model, error in
                if error != nil {
                    completion(nil, error)
                }
                guard let model = model else { return }
                
                if model.statusCode == 0 {
                    guard let data = model.data else { return }
                    completion(data, nil)
                    
                } else {
                    completion(nil ,model.errorMessage)
                }
            }
        case .getCurrencyList:
            
            if let banksListSerial = UserDefaults().object(forKey: "CurrencyListSerial") as? String {

                guard let documentsDirectoryUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
                let filePath = documentsDirectoryUrl.appendingPathComponent("CurrencyList.json")
                
                // Read data from .json file and transform data into an array
                do {
                    let data = try Data(contentsOf: filePath, options: [])
                    
                    let list = try JSONDecoder().decode(GetCurrencyListDataClass.self, from: data)
                    Dict.shared.currencyList = list.currencyList
                    completion(list.currencyList, nil)
                } catch {

                }
                getCurrency(withId: banksListSerial)
            } else {
                getCurrency()
            }
            
            func getCurrency(withId: String? = nil) {
                
                let param = ["serial" : withId ?? ""]
                NetworkManager<GetCurrencyListDecodableModel>.addRequest(.getCurrencyList, param, body) { model, error in
                    if error != nil {
                        guard let error = error else { return }
                        completion(nil, error)
                    } else {
                        guard let statusCode = model?.statusCode else { return }
                        if statusCode == 0 {
                            if model?.data?.serial != withId {
                                //17d41a8646c2a644b6db321888e00469
                                guard let data = model?.data else { return }
                                
                                let pathDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                                try? FileManager().createDirectory(at: pathDirectory, withIntermediateDirectories: true)
                                let filePath = pathDirectory.appendingPathComponent("CurrencyList.json")

                                let json = try? JSONEncoder().encode(data)

                                do { try json!.write(to: filePath) }
                                catch {}
                                
                                UserDefaults().set(data.serial, forKey: "CurrencyListSerial")
                                
                                guard let payments = model?.data?.currencyList else { return }
                                Dict.shared.currencyList = payments
                                completion(payments, nil)
                            } else {
                            }
                            
                        } else {
                            let error = model?.errorMessage ?? "nil"
                            completion(nil, error)
                        }
                    }
                }
            }
        }
    }
    
    
}
