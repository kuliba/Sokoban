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
                    print("DEBUG: Error: ", error ?? "")
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
            
        case .getCardList:
            if CardModel.cardList != nil {
                completion(CardModel.cardList, nil)
            }
            NetworkManager<GetCardListDecodebleModel>.addRequest(.getCardList, tempParameters, body) { model, error in
                if error != nil {
                    print("DEBUG: Error: ", error ?? "")
                    completion(nil, error)
                }
                guard let model = model else { return }
                
                if model.statusCode == 0 {
                    guard let data = model.data else { return }
                    CardModel.cardList = data
                    
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
                    print(error)
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
                        print("DEBUG: ", #function, error)
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
                                    print("Failed to write JSON data: \(error.localizedDescription)")
                                }
                                
                                UserDefaults().set(data.serial, forKey: "CountriesListSerial")
                                
                                guard let countries = model?.data?.countriesList else { return }
                                Dict.shared.countries = countries
                                completion(countries, nil)
                            } else {
                                print("DEBUG: CountriesList уже есть")
                            }
                            
                        } else {
                            let error = model?.errorMessage ?? "nil"
                            print("DEBUG: ", #function, error)
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
                    print(error)
                }
                
                getBanks(withId: banksListSerial)
                
            } else {
                getBanks()
            }
            
            func getBanks(withId: String? = nil) {
                
                let param = ["serial" : withId ?? ""]
                print("DEBUG: getBanks param", param)
                NetworkManager<GetBanksDecodableModel>.addRequest(.getBanks, param, body) { model, error in
                    if error != nil {
                        guard let error = error else { return }
                        print("DEBUG: ", #function, error)
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
                                    print("Failed to write JSON data: \(error.localizedDescription)")
                                }
                                
                                UserDefaults().set(data.serial, forKey: "BanksListSerial")
                                
                                guard let banks = model?.data?.banksList else { return }
                                Dict.shared.banks = banks
                                completion(banks, nil)
                            } else {
                                print("DEBUG: BanksList уже есть")
                            }
                            
                        } else {
                            let error = model?.errorMessage ?? "nil"
                            print("DEBUG: ", #function, error)
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
                    print(error)
                }
                getPayments(withId: banksListSerial)
            } else {
                getPayments()
            }
            
            func getPayments(withId: String? = nil) {
                
                let param = ["serial" : withId ?? ""]
                print("DEBUG: getPayments param", param)
                NetworkManager<GetPaymentSystemListDecodableModel>.addRequest(.getPaymentSystemList, param, body) { model, error in
                    if error != nil {
                        guard let error = error else { return }
                        print("DEBUG: ", #function, error)
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
                                catch { print("Failed to write JSON: \(error.localizedDescription)") }
                                
                                UserDefaults().set(data.serial, forKey: "PaymentListSerial")
                                
                                guard let payments = model?.data?.paymentSystemList else { return }
                                Dict.shared.paymentList = payments
                                completion(payments, nil)
                            } else {
                                print("DEBUG: BanksList уже есть")
                            }
                            
                        } else {
                            let error = model?.errorMessage ?? "nil"
                            print("DEBUG: ", #function, error)
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
        }
        
    }
    
    
}
