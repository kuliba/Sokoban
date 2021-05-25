/*
 * Copyright (C) 2017-2019 Brig Invest ltd. All rights reserved.
 * CONFIDENTIAL
 *
 * Авторское право (C) 2017-2019 OОО "Бриг Инвест". Все права защищены.
 * КОНФИДЕНЦИАЛЬНО
 */

import Foundation
import Alamofire
import UIKit

class NetworkManager {

    // MARK: - Properties

    private static var sharedNetworkManager: NetworkManager = {
        let host = Host.shared

        let authService = AuthService(host: host)
        let cardService = CardService(host: host)
        let cardInfoService = CardInfoService(host: host)
        let paymentServices = PaymentServices(host: host)
        let suggestBankService = SuggestBankService(host: host)
        let suggestCompanyService = SuggestCompanyService(host: host)
        let mapService = MapService(host: host) //для работы с картами
        
        let regService = RegService(host: host)
        let depositsService = DepositService(host: host)
        let accountsService = AccountsService(host: host)
        let loansService = LoansService(host: host)
        let historyService = HistoryService(host: host)
        let statementService = StatementService(host: host)
        let loanPaymentSchedule = LoanPaymentSchedule(host: host)
        let productService = ProductsService(host: host)
        let currentService = CurrencysService(host: host)
        let operationService = OperationListService(host: host)
        let userService = UserSettingsService()
        let blockUserService = BlockUserService(host: host)
        let getOwnerPhoneNumberService = GetOwnerPhoneNumberService()
        let anywayPayment = AnywayPaymentService(host: host)
        let paymentBankListService = PaymentBankListService()
        let personService = PersonService(host: host)
        let pushNotificationService = PushNotificationService(host: host)
        let getVerificationCodeService = GetVerificationService(host: host)

        
        


        let networkManager = NetworkManager(host, authService, suggestBankService, suggestCompanyService, regService, cardService, cardInfoService, paymentServices, depositsService, accountsService, loanPaymentSchedule, historyService, loansService, statementService, productService: productService, mapService: mapService, currencyService: currentService, operationService, userService, blockUserService, getOwnerPhoneNumberService, anywayPayment, paymentBankListService, personService, pushNotificationService, getVerificationCodeService)
        // Configuration


        return networkManager
    }()

    private let authService: AuthServiceProtocol
    private let regService: RegServiceProtocol
    private let cardService: CardServiceProtocol
    private let cardInfoService: CardInfoServiceProtocol
    private let suggestBankService: SuggestBankService
    private let suggestCompanyService: SuggestCompanyService
    private let paymentServices: IPaymetsApi
    private let productService: IProductService
    private let depositsService: DepositsServiceProtocol
    private let accountsService: AccountsServiceProtocol
    private let loanPaymentSchedule: LoanPaymentScheduleProtocol
    private let historyService: HistoryServiceProtocol
    private let loansService: LoansServiceProtocol
    private let statementService: StatementServiceProtocol
    private let mapService: MapServiceProtocol
    private let currencyService: CurrencysProtocol
    private let operationService: OperationProtocolService
    private let userService: UserSettingsProtocolService
    private let blockUserService: BlockUserProtocolService
    private let getOwnerPhoneNumberService: GetOwnerPhoneNumberProtocol
    private let host: Host
    private let anywayPaymentService: AnywayPaymentProtocol
    private let paymentBankListService: paymentBankListProtocol
    private let personService: PersonServiceProtocol
    private let pushNotificationService: PushNotificationProtocol
    private let getVerificationCode: getVerificationCodeProtocol
    
    public var headers: HTTPHeaders = [
        "Accept": "application/json",
        "Content-Type": "application/json",
        "X-XSRF-TOKEN": "4022b0e6-e822-4b00-9d91-aacf9ae3b8c7",
        "JSESSIONID": "983F3FBC20F69C7A1A89B4DEAE690175"
    ]
    
//    let parametersForNotification = [
//    "pushDeviceId": UIDevice.current.identifierForVendor!.uuidString,
//    "token": Messaging.messaging().fcmToken as Any,
//    "model": UIDevice().model,
//     "operationSystem": "IOS"
//    ] as [String : Any]

// Initialization
    private init(_ host: Host, _ authService: AuthServiceProtocol, _ suggestBankService: SuggestBankService,_ suggestCompanyService: SuggestCompanyService, _ regService: RegServiceProtocol, _ cardService: CardServiceProtocol, _ cardInfoService: CardInfoServiceProtocol, _ paymentsServices: IPaymetsApi, _ depositsService: DepositsServiceProtocol, _ accountsService: AccountsServiceProtocol, _ LaonSchedules: LoanPaymentScheduleProtocol, _ historyService: HistoryServiceProtocol, _ loansService: LoansServiceProtocol, _ statementService: StatementServiceProtocol, productService: IProductService, mapService:MapServiceProtocol, currencyService:CurrencysProtocol, _ operationService: OperationProtocolService,_ userService: UserSettingsProtocolService,_ blockUserService: BlockUserProtocolService, _ getOwnerPhoneNumberService: GetOwnerPhoneNumberProtocol, _ anywayPayment: AnywayPaymentProtocol, _ paymentBankListSevice: paymentBankListProtocol, _ personService: PersonServiceProtocol, _ pushNotificationService: PushNotificationProtocol, _ getVerificationCodeService: getVerificationCodeProtocol) {
        self.host = host
        self.authService = authService
        self.regService = regService
        self.cardService = cardService
        self.cardInfoService = cardInfoService
        self.suggestBankService = suggestBankService
        self.paymentServices = paymentsServices
        self.loansService = loansService
        self.suggestCompanyService = suggestCompanyService
        self.loanPaymentSchedule = LaonSchedules
        self.depositsService = depositsService
        self.accountsService = accountsService
        self.historyService = historyService
        self.statementService = statementService
        self.productService = productService
        self.mapService = mapService
        self.currencyService = currencyService
        self.operationService = operationService
        self.userService = userService
        self.blockUserService = blockUserService
        self.getOwnerPhoneNumberService = getOwnerPhoneNumberService
        self.anywayPaymentService = anywayPayment
        self.paymentBankListService = paymentBankListSevice
        self.personService = personService
        self.pushNotificationService = pushNotificationService
        self.getVerificationCode = getVerificationCodeService
    }

// MARK: - Accessors

    class func shared() -> NetworkManager {
        return sharedNetworkManager
    }

    
    func getAnywayPayment(completionHandler: @escaping (_ success: Bool?, [AnywayPaymentInputs?], String?) -> Void) {
        anywayPaymentService.AnywayPayment(headers: headers, completionHandler: completionHandler)
    }
    
    func getAnywayPaymentBegin(numberCard: String?, puref: String?, completionHandler: @escaping (_ success: Bool, AnywayPaymentBegin?, String?) -> Void) {
        anywayPaymentService.anywayPaymentBegin(headers: headers, numberCard: numberCard, puref: puref, completionHandler: completionHandler)
    }
    func getAnywayPaymentFinal(memberId: String?,amount: String?, numberPhone: String?, parameters: [Additional]?, completionHandler: @escaping (_ success: Bool?, [AnywayPaymentInputs?], String?) -> Void) {
        anywayPaymentService.AnywayPaymentFinal(memberId: memberId, amount: amount, numberPhone: numberPhone, parameters: parameters ?? [], headers: headers, completionHandler: completionHandler)
    }
    
    func anywayPaymentMake(code: String, completionHandler: @escaping (Bool, String?) -> Void){
        anywayPaymentService.anywayPaymentMake(code: code, completionHandler: completionHandler)
    }
//MARK: - fastPayment
    func getFastPayment(completionHandler: @escaping (_ success: Bool, [BLBankList?],_ errorMessage: String?) -> Void){
        paymentBankListService.getBankList(headers: headers) { (success, bankList, errorMessage) in
        }
    }
    func findBankList(completionHandler: @escaping (_ success: Bool, BLBankList? ,_ errorMessage: String?) -> Void){
        anywayPaymentService.findBankList(headers: headers, completionHandler: completionHandler)
    }

//MARK: - Person
    func getPerson(completionHandler: @escaping (_ success: Bool?, FPerson,_ errorMassage: String?) -> Void){
        personService.personService(header: headers, completionHandler: completionHandler)
    }
    func getVerificationCode(completionHandler: @escaping (_ success: Bool?,_ errorMassage: String?) -> Void){
        getVerificationCode.getVerificationCode(headers: headers, completionHandler: completionHandler)
    }
    
//MARK: - auth service
    func isSignedIn(completionHandler: @escaping (_ success: Bool) -> Void) {
        authService.isSignedIn(completionHandler: completionHandler)
    }
    var work = true
    func installPushDevice(parameters: [String : Any], auth: Bool, completionHandler: @escaping (_ success: Bool,_ errorMessage: String?) -> Void) {
        if auth{
            work = false
            pushNotificationService.checkPushDevice(headers: self.headers, parameters: parameters, auth: auth) { [self] (success, errorMessage) in
                        if success{
                            pushNotificationService.installPushDevice(headers: self.headers, parameters: parameters, auth: auth, completionHandler: completionHandler)
                        }
                        work = true
                    }

        } else {
            authService.csrf(headers: headers) { [unowned self] (success, newHeaders) in
                if success {
                    self.headers.merge(newHeaders ?? [:], uniquingKeysWith: { (_, k2) -> String in
                        return k2
                    })
            pushNotificationService.checkPushDevice(headers: self.headers, parameters: parameters, auth: auth) { [self] (success, errorMessage) in
                        if success{
                            pushNotificationService.installPushDevice(headers: self.headers, parameters: parameters, auth: false, completionHandler: completionHandler)
                        }
                        work = true
                    }
                }
             
            }
        }
        }
    func checkPushDevice(parameters: [String : Any], completionHandler: @escaping (_ success: Bool,_ errorMessage: String?) -> Void) {
                pushNotificationService.checkPushDevice(headers: self.headers, parameters: parameters, auth: false, completionHandler: completionHandler)
    

        }
    
    func keyExchange(key: String,
               completionHandler: @escaping (_ success: Bool, _ errorMessage: String?) -> Void) {
    }
    func login(login: String,
               password: String,
               completionHandler: @escaping (_ success: Bool, _ errorMessage: String?) -> Void) {
        authService.csrf(headers: headers) { [unowned self] (success, newHeaders) in
            if success {
                self.headers.merge(newHeaders ?? [:], uniquingKeysWith: { (_, k2) -> String in
                    return k2
                })
                self.authService.loginDo(headers: headers,
                                         login: login,
                                         password: password,
                                         completionHandler: { (success, errorMessage) in
                                             completionHandler(success, errorMessage)
                                         })
            }
            else {
                completionHandler(false, nil)
            }
        }
    }
    func prepareResetPassword(login: String,
                              completionHandler: @escaping (_ success: Bool, _ errorMessage: String?) -> Void) {
        authService.csrf(headers: headers) { [unowned self] (success, newHeaders) in
            if success {
                self.headers.merge(newHeaders ?? [:], uniquingKeysWith: { (_, k2) -> String in
                    return k2
                })
                self.authService.prepareResetPassword(headers: self.headers,
                                                      login: login,
                                                      completionHandler: { (success, errorMessage) in
                                                          completionHandler(success, errorMessage)
                                                      })
            }
            else {
                completionHandler(false, nil)
            }
        }
    }
    
  
    
    func newPasswordReset(password: String,
                          completionHandler: @escaping (_ success: Bool, _ errorMessage: String?) -> Void) {
        authService.csrf(headers: headers) { [unowned self] (success, newHeaders) in
            if success {
                self.headers.merge(newHeaders ?? [:], uniquingKeysWith: { (_, k2) -> String in
                    return k2
                })
                self.authService.newPasswordReset(headers: self.headers,
                                                  password: password,
                                                  completionHandler: { (success, errorMessage) in
                                                      completionHandler(success, errorMessage)
                                                  })
            }
            else {
                completionHandler(false, nil)
            }
        }
    }
    
    func changePassword(oldPassword: String,
                        newPassword: String,
                        completionHandler: @escaping (_ success: Bool, _ errorMessage: String?) -> Void){
        authService.changePassword(headers: self.headers, oldPassword: oldPassword, newPassword: newPassword) { (success, errorMessage) in
            completionHandler(success, errorMessage)
        }
    }

    func checkVerificationCode(code: String,
                               completionHandler: @escaping (_ success: Bool) -> Void) {
        authService.checkVerificationCode(headers: self.headers, code: code, completionHandler: completionHandler)
    }
    func checkCodeResetPassword(code: String,
                                completionHandler: @escaping (_ success: Bool) -> Void) {
        authService.checkCodeResetPassword(headers: self.headers, code: code, completionHandler: completionHandler)
    }

    func logOut(completionHandler: ((_ success: Bool) -> Void)?) {
        authService.logOut { [self] (success) in
            if completionHandler != nil {
                completionHandler!(success)
//                pushNotificationService.uninstallPushDevice(headers: headers) { (success, errorMessage) in
//
//                }
                
            }
        }
    }

    func getProfile(completionHandler: @escaping (_ success: Bool, _ profile: Profile?, _ errorMessage: String?) -> Void) {
        authService.getProfile(headers: headers) { [unowned self] (success, profile, errorMessage) in
            if self.checkForClosingSession(errorMessage) == false {
                completionHandler(success, profile, errorMessage)
            } else {
                completionHandler(success, profile, errorMessage)
            }
        }
    }

//MARK: - registration service
    func checkClient(cardNumber: String,
                     login: String,
                     password: String,
                     phone: String,
                     verificationCode: Int,
                     completionHandler: @escaping (_ success: Bool, _ errorMessage: String?) -> Void) {
        authService.csrf(headers: headers) { [unowned self] (success, newHeaders) in
            if success {
                self.headers.merge(newHeaders ?? [:], uniquingKeysWith: { (_, k2) -> String in
                    return k2
                })
                self.regService.checkClient(headers: self.headers, cardNumber: cardNumber, login: login, password: password, phone: phone, verificationCode: verificationCode, completionHandler: completionHandler)
            }
            else {
                completionHandler(false, nil)
            }
        }
    }
    
    func getOwnerPhoneNumber(phoneNumber: String, completionHandler: @escaping (_ success: Bool?,_ errorMessage: String?) -> Void ) {
        getOwnerPhoneNumberService.getOwnerPhoneNumber(headers: headers, phoneNumber: phoneNumber, completionHandler: completionHandler)
    }
    func paymentCompany(
    numberAcoount: String,
    amount: String,
    kppBank: String,
    payerCard: String,
    innBank: String,
    bikBank: String,
    comment: String,
    nameCompany: String,
    comission: Double,
    completionHandler: @escaping (_ success: Bool, _ errorMessage: String?, _ commission: Double?) -> Void) {
        authService.csrf(headers: headers) { [unowned self] (success, newHeaders) in
            if success {
                self.headers.merge(newHeaders ?? [:], uniquingKeysWith: { (_, k2) -> String in
                    return k2
                })
                self.regService.paymentCompany(headers: self.headers, numberAcoount: numberAcoount, amount: amount, payerCard: payerCard, kppBank: kppBank, innBank: innBank, bikBank: bikBank, comment: comment, nameCompany: nameCompany, commission: comission , completionHandler: completionHandler)
            }
            else {
                completionHandler(false, nil, 20.0)
            }
        }
    }


    func doRegistration(completionHandler: @escaping (_ success: Bool, _ errorMessage: String?, _ login: String?, _ password: String?) -> Void) {
        authService.csrf(headers: headers) { [unowned self] (success, newHeaders) in
            if success {
                self.headers.merge(newHeaders ?? [:], uniquingKeysWith: { (_, k2) -> String in
                    return k2
                })
                self.regService.doRegistration(headers: self.headers, completionHandler: completionHandler)
//                AppDelegate.application(AppDelegate)
            }
            else {
                completionHandler(false, nil, nil, nil)
            }
        }
    }
    
    func saveCardName(newName: String, id: Double, completionHandler: @escaping (_ success: Bool, _ errorMessage: String?, _ id: Double?, _ name: String?) -> Void) {
        authService.csrf(headers: headers) { [unowned self] (success, newHeaders) in
            if success {
                self.regService.saveCardName(headers: self.headers, id: id, newName: newName, completionHandler: completionHandler)
            }
            else {
                completionHandler(false, nil, nil, nil)
            }
        }
    }
    
    func saveLoanName(newName: String, id: Int, completionHandler: @escaping (_ success: Bool, _ errorMessage: String?, _ id: Int?, _ name: String?) -> Void) {
        authService.csrf(headers: headers) { [unowned self] (success, newHeaders) in
            if success {
                //self.regService.saveLoanName(headers: self.headers, id: id, newName: newName, completionHandler: completionHandler)
                self.regService.saveLoanName(headers: self.headers, id: id, newName: newName) { (successSLN, errorMessage, id, name) in
                    completionHandler(true, nil, nil, nil)
                }
            }
            else {
                completionHandler(false, nil, nil, nil)
            }
        }
    }
    
    func saveCustomName(newName: String, id: Int, productType: productTypes, completionHandler: @escaping (_ success: Bool, _ errorMessage: String?, _ id: Int?, _ name: String?) -> Void){
        authService.csrf(headers: headers) { [unowned self] (success, newHeaders) in
            if success {
                //self.regService.saveLoanName(headers: self.headers, id: id, newName: newName, completionHandler: completionHandler)
//                self.regService.saveLoanName(headers: self.headers, id: id, newName: newName) { (successSLN, errorMessage, id, name) in
//                    completionHandler(true, nil, nil, nil)
//                }
                self.regService.saveCustomName(headers: self.headers, id: id, newName: newName, productType: productType) { (successSLN, errorMessage, id, name)in
                    completionHandler(true, nil, nil, nil)
                }
            }
            else {
                completionHandler(false, nil, nil, nil)
            }
        }
        
    }
    
    func best2Pay(completionHandler: @escaping (_ success: Bool, _ errorMessage: String?, _ id: Double?, _ name: String?) -> Void) {
        //self.best2Pay(completionHandler: completionHandler)

    }
    func verifyCode(verificationCode: Int,
                    completionHandler: @escaping (_ success: Bool, _ errorMessage: String?) -> Void) {
        authService.csrf(headers: headers) { [unowned self] (success, newHeaders) in
            if success {
                self.headers.merge(newHeaders ?? [:], uniquingKeysWith: { (_, k2) -> String in
                    return k2
                })
                self.regService.verifyCode(headers: self.headers, verificationCode: verificationCode, completionHandler: completionHandler)
            }
            else {
                completionHandler(false, nil)
            }
        }
    }


//MARK: - card service
    func getCardList(completionHandler: @escaping (_ success: Bool, _ cards: [Card]?) -> Void) {
        cardService.getCardList(headers: headers, completionHandler: completionHandler)
    }
    
    func getCardInfo(cardNumber: String, completionHandler: @escaping (_ success: Bool, _ cardInfo: [AboutItem]?) -> Void) {
        cardInfoService.getCardInfo(cardNumber: cardNumber, headers: headers, completionHandler: completionHandler)
    }
    func getSuggestBank(bicBank: String, completionHandler: @escaping (_ success: Bool, _ cardInfo: [BankSuggest]?,_ bicBank: String?) -> Void) {
        suggestBankService.getSuggestBank(bicBank: bicBank, headers: headers, completionHandler: completionHandler)
        

      }
    func getSuggestCompany(bicBank: String, completionHandler: @escaping (_ success: Bool, _ cardInfo: [BankSuggest]?,_ bicBank: String?) -> Void) {
        suggestCompanyService.getSuggestCompany(bicBank: bicBank, headers: headers, completionHandler: completionHandler)
        

      }



    func getPaymentsList(completionHandler: @escaping (_ success: Bool, _ payments: [Operations]?) -> Void) {
        paymentServices.getPaymentsList(completionHandler: completionHandler)
    }

    func blockCard(withNumber num: String,
                   completionHandler: @escaping (Bool) -> Void) {
        cardService.blockCard(withNumber: num, completionHandler: completionHandler)
    }

    func getTransactionsStatement(forCardNumber number: String,
                                  fromDate: Date,
                                  toDate: Date,
                                  completionHandler: @escaping (_ success: Bool, _ datedTransactions: [DatedTransactions]?) -> Void) {
        cardService.getTransactionsStatement(forCardNumber: number,
                                             fromDate: fromDate,
                                             toDate: toDate,
                                             headers: headers,
                                             completionHandler: completionHandler)
    }

//MARK: - Statement service
    func getSortedFullStatement(completionHandler: @escaping (Bool, [DatedTransactionsStatement]?, String?) -> Void) {
        statementService.getSortedFullStatement(headers: headers) { [unowned self] (success, fullStatement, errorMessage) in
            if self.checkForClosingSession(errorMessage) == false {
                completionHandler(success, fullStatement, errorMessage)
            } else {
                completionHandler(false, fullStatement, errorMessage)
            }
        }
    }

//MARK: - deposits service
    func getBonds(completionHandler: @escaping (_ success: Bool, _ obligations: [Deposit]?) -> Void) {
        depositsService.getBonds(headers: headers, completionHandler: completionHandler)
    }
    func getLoans(completionHandler: @escaping (_ success: Bool, _ obligations: [Loan]?) -> Void) {
        loansService.getLoans(headers: headers, completionHandler: completionHandler)
    }
    func getLoansPayment(completionHandler: @escaping (_ loanId: String?, _ success: Bool, _ obligations: [LaonSchedules]?) -> Void) {
        loanPaymentSchedule.getLoansPayment(headers: headers, completionHandler: completionHandler)
    }
    func getHistoryCard(cardNumber: String, completionHandler: @escaping (_ success: Bool, _ obligations: [DatedCardTransactionsStatement]?) -> Void) {
        historyService.getHistoryCard(headers: headers, cardNumber: cardNumber, completionHandler: completionHandler)
    }
    func getOperationService(completionHandler: @escaping (_ success: Bool, _ obligations: OperationsList?, String?) -> Void){
        operationService.getOperations(headers: headers, completionHandler: completionHandler)
    }
    func setSetting(parameters: [String : Any], completionHandler: @escaping (_ success: Bool) -> Void){
        userService.setSettings(parameters: parameters
            , headers: headers, completionHandler: completionHandler)
      }
    func addSetting(parameters:[String : Any], completionHandler: @escaping (_ success: Bool) -> Void){
        userService.addSettings(parameters: parameters, headers: headers, completionHandler: completionHandler)
         }
    func getSettings(completionHandler: @escaping (_ success: Bool, _ obligations: GetUserSettings?, String?) -> Void){
        userService.getSettings(headers: headers, completionHandler: completionHandler)       }
    func blockUser(completionHandler: @escaping (_ success: Bool, _ errorMessage: String?) -> Void){
        blockUserService.blockUser(headers: headers, completionHandler: completionHandler)   }
    func getHistoryDeposit(id: Int, name: String,completionHandler: @escaping (_ success: Bool, _ obligations: [DatedCardTransactionsStatement]?) -> Void) {
        historyService.getHistoryDeposit(headers: headers, id: id, name: name) { (success, historyStatment) in
            if success{
                completionHandler(true, historyStatment)
                return
            }else{
                completionHandler(false, nil)
            }
        }
    }
    
    
//MARK: - deposits service
    func getDepos(completionHandler: @escaping (_ success: Bool, _ obligations: [Account]?) -> Void) {
        accountsService.getDepos(headers: headers, completionHandler: completionHandler)
    }

//MARK: - check errorMessage for closing session
    func checkForClosingSession(_ errorMessage: String?) -> Bool {
        if let errorMessage = errorMessage,
            errorMessage.range(of: "Сессия не авторизована") != nil {
            logOut { (success) in
            }
            return true
        } else {
            return false
        }
    }
}

//MARK: - Products

extension NetworkManager: IProductsApi {
    func getProducts(completionHandler: @escaping (Bool, [Product]?) -> Void) {
        productService.getProducts(completionHandler: completionHandler)
    }
}



//MARK: - Payments

extension NetworkManager: IPaymetsApi {
    func prepareCard2Account(from sourceNumber: String, to destinationNumber: String, amount: Double, completionHandler: @escaping (Bool, String?, DataClassPayment?) -> Void) {
        paymentServices.prepareCard2Account(from: sourceNumber, to: destinationNumber, amount: amount, completionHandler: completionHandler)
    }
    
    func prepareAccount2Phone(from sourceNumber: String, to destinationNumber: String, amount: Double, completionHandler: @escaping (Bool, String?, DataClassPayment?) -> Void) {
        paymentServices.prepareAccount2Phone(from: sourceNumber, to: destinationNumber, amount: amount, completionHandler: completionHandler)
    }
    
    func prepareAccount2Card(from sourceNumber: String, to destinationNumber: String, amount: Double, completionHandler: @escaping (Bool, String?, DataClassPayment?) -> Void) {
        paymentServices.prepareAccount2Card(from: sourceNumber, to: destinationNumber, amount: amount, completionHandler: completionHandler)
    }
    
    func prepareAccount2Account(from sourceNumber: String, to destinationNumber: String, amount: Double, completionHandler: @escaping (Bool, String?, DataClassPayment?) -> Void) {
        paymentServices.prepareAccount2Account(from: sourceNumber, to: destinationNumber, amount: amount, completionHandler: completionHandler)
    }
    
    func allPaymentOptions(completionHandler: @escaping (Bool, [PaymentOption]?) -> Void) {
        paymentServices.allPaymentOptions(completionHandler: completionHandler)
    }

    func prepareCard2Phone(from sourceNumber: String, to destinationNumber: String, amount: Double, completionHandler: @escaping (Bool, String?, DataClassPayment?) -> Void) {
        paymentServices.prepareCard2Phone(from: sourceNumber, to: destinationNumber, amount: amount, completionHandler: completionHandler)
    }

    func prepareCard2Card(from sourceNumber: String, to destinationNumber: String, amount: Double, completionHandler: @escaping (Bool, String?, DataClassPayment?) -> Void) {
        paymentServices.prepareCard2Card(from: sourceNumber, to: destinationNumber, amount: amount, completionHandler: completionHandler)
    }

    func makeCard2Card(code: String,
                       completionHandler: @escaping (_ success: Bool) -> Void) {
        paymentServices.makeCard2Card(code: code, completionHandler: completionHandler)
    }
}

//MARK: Map Bank Branches
extension NetworkManager{
    func getBankBranches(completionHandler: @escaping (_ success: Bool, _ bankBranches: Data?, _ errorMessage: String?) -> Void){
        mapService.getBankBranches(headers: headers) { (success, nsData, errorMessage) in
            if success{
                guard let dataData = nsData else {
                    completionHandler(false, nil, "Не удалось получить данные")
                    return
                }
                completionHandler(success, dataData, errorMessage)
                return
            }else{
                completionHandler(success, nil, errorMessage)
            }
        }
    }
}


extension NetworkManager{
    
    func getExchangeCurrencyRates(currency: String, completionHandler: @escaping (Bool, Currency?) -> Void){

        self.currencyService.getExchangeCurrencyRates(headers: headers , currency: currency) { (success, currency) in

            if success{
                guard let currencyData = currency else {
                    completionHandler(false, nil)
                    return
                }
                completionHandler(true, currencyData)
            }else{
                completionHandler(false, nil)
            }
        }
    }
    
    func getABSCurrencyRates(currencyOne: String, currencyTwo: String, rateTypeID: Int, completionHandler: @escaping (Bool, Double?) -> Void){
        

            self.currencyService.getABSCurrencyRates(headers:  self.headers, currencyOne: currencyOne, currencyTwo: currencyTwo, rateTypeID: rateTypeID) { (success, rateCB) in
            if success{
                if rateCB != nil{
                    completionHandler(true, rateCB)
                    return
                }else{
                    completionHandler(false, nil)
                    return
                }
            }else{
                completionHandler(false, nil)
                return
            }
        }
    
    }
}
