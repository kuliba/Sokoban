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

protocol AuthServiceProtocol {
    func isSignedIn(completionHandler: @escaping (_ success:Bool) -> Void)
    func csrf(headers: HTTPHeaders,
              completionHandler: @escaping (_ success:Bool, _ headers: HTTPHeaders?) -> Void)
    func loginDo(headers: HTTPHeaders,
                 login: String,
                 password: String,
                 completionHandler: @escaping (_ success:Bool,_ errorMessage: String?) -> Void)
    func checkVerificationCode(headers: HTTPHeaders,
                               code: String,
                               completionHandler: @escaping (_ success:Bool) -> Void)
    func logOut(completionHandler: @escaping (_ success:Bool) -> Void)
    func getProfile(headers: HTTPHeaders,
                    completionHandler: @escaping (_ success:Bool, _ profile: Profile?,_ errorMessage: String?) -> Void)
}

protocol CardServiceProtocol {
    func getCardList(headers: HTTPHeaders,
                     completionHandler: @escaping (_ success:Bool, _ cards: [Card]?) -> Void)
    func blockCard(withNumber num: String,
                   completionHandler: @escaping (_ success:Bool) -> Void)
    func getTransactionsStatement(forCardNumber: String,
                                  fromDate: Date,
                                  toDate: Date,
                                  headers: HTTPHeaders,
                                  completionHandler: @escaping (_ success:Bool, _ datedTransactions: [DatedTransactions]?) -> Void)
}

protocol DeposServiceProtocol {
    func getDepos(headers: HTTPHeaders,
                  completionHandler: @escaping (_ success:Bool, _ obligations: [Depos]?) -> Void)
}
protocol LoansServiceProtocol {
    func getLoans(headers: HTTPHeaders,
                  completionHandler: @escaping (_ success:Bool, _ obligations: [Loan]?) -> Void)
}

protocol DepositsServiceProtocol {
    func getBonds(headers: HTTPHeaders,
                  completionHandler: @escaping (_ success:Bool, _ obligations: [Bond]?) -> Void)
}

protocol RegServiceProtocol {
    func checkClient(headers: HTTPHeaders,
                     cardNumber: String,
                     login: String,
                     password: String,
                     phone: String,
                     verificationCode: Int,
                     completionHandler: @escaping (_ success:Bool,_ errorMessage: String?) -> Void)
    func verifyCode(headers: HTTPHeaders,
                    verificationCode: Int,
                    completionHandler: @escaping (_ success:Bool,_ errorMessage: String?) -> Void)
    func doRegistration(headers: HTTPHeaders,
                        completionHandler: @escaping (_ success:Bool,_ errorMessage: String?, _ login: String?,_ password: String?) -> Void)
}

protocol StatementServiceProtocol {
    func getSortedFullStatement(headers: HTTPHeaders,
                  completionHandler: @escaping (_ success:Bool, _ obligations: [DatedTransactionsStatement]?,_ errorMessage: String?) -> Void)
}

class NetworkManager {
    
    // MARK: - Properties
    
    private static var sharedNetworkManager: NetworkManager = {
        let host = "https://git.briginvest.ru/dbo/api/v2/"
        
        let authService = AuthService(baseURLString: host)//TestAuthService()//
        let cardService = CardService(baseURLString: host)//TestCardService()//
        let regService = RegService(baseURLString: host)//TestRegService()//
        let depositsService = TestDepositsService(baseURLString: host)
        let deposService = DeposService(baseURLString: host)
        let loansService = LoansService(baseURLString: host)
        let statementService = StatementService(baseURLString: host)//TestStatementService()
        
        let networkManager = NetworkManager(host, authService, regService, cardService, depositsService, deposService, loansService, statementService)
        
        // Configuration
        
        
        return networkManager
    }()
    private let authService: AuthServiceProtocol
    private let regService: RegServiceProtocol
    private let cardService: CardServiceProtocol
    private let depositsService: DepositsServiceProtocol
    private let deposService: DeposServiceProtocol
    private let loansService: LoansServiceProtocol
    private let statementService: StatementServiceProtocol

    private let baseURLString: String
    private var headers: HTTPHeaders = [
        "Accept": "application/json",
        "Content-Type": "application/json",
        "X-XSRF-TOKEN": "40e3a7ef-2a2d-48f4-9d1d-f024429aac3a",
        "JSESSIONID": "983F3FBC20F69C7A1A89B4DEAE690175"
    ]
    
    // Initialization
    
    private init(_ baseURLString: String,_ authService: AuthServiceProtocol,_ regService: RegServiceProtocol,_ cardService: CardServiceProtocol,_ depositsService: DepositsServiceProtocol,_ DeposService: DeposServiceProtocol,_ loansService: LoansServiceProtocol ,_ statementService: StatementServiceProtocol) {
        self.baseURLString = baseURLString
        self.authService = authService
        self.regService = regService
        self.cardService = cardService
        self.loansService = loansService
        self.depositsService = depositsService
        self.deposService = DeposService
        self.statementService = statementService
    }
    
    // MARK: - Accessors
    
    class func shared() -> NetworkManager {
        return sharedNetworkManager
    }
    
    //MARK: - auth service
    func isSignedIn(completionHandler: @escaping (_ success:Bool) -> Void) {
        authService.isSignedIn(completionHandler: completionHandler)
    }
    
    func login(login: String,
               password: String,
               completionHandler: @escaping (_ success:Bool,_ errorMessage: String?) -> Void) {
        authService.csrf(headers: headers) { [unowned self] (success, newHeaders) in
            if success {
                self.headers.merge(newHeaders ?? [:], uniquingKeysWith: { (_, k2) -> String in
                    return k2
                    })
//                print("headers \(self.headers)")
                self.authService.loginDo(headers: self.headers,
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
    
    func checkVerificationCode(code: String,
                               completionHandler: @escaping (_ success:Bool) -> Void) {
        authService.checkVerificationCode(headers: self.headers, code: code, completionHandler: completionHandler)
    }
    
    func logOut(completionHandler: ((_ success:Bool) -> Void)? ) {
        authService.logOut { (success) in
            if completionHandler != nil {
                completionHandler!(success)
            }
        }
    }
    
    func getProfile(completionHandler: @escaping (_ success:Bool, _ profile: Profile?,_ errorMessage: String?) -> Void) {
        authService.getProfile(headers: headers) { [unowned self] (success, profile, errorMessage) in
            if self.checkForClosingSession(errorMessage) == false {
                completionHandler(success, profile, errorMessage)
            } else {
                completionHandler(false, profile, errorMessage)
            }
        }
    }
    
    //MARK: - registration service
    func checkClient(cardNumber: String,
                     login: String,
                     password: String,
                     phone: String,
                     verificationCode: Int,
                     completionHandler: @escaping (_ success:Bool,_ errorMessage: String?) -> Void) {
        authService.csrf(headers: headers) { [unowned self] (success, newHeaders) in
            if success {
                self.headers.merge(newHeaders ?? [:], uniquingKeysWith: { (_, k2) -> String in
                    return k2
                })
                //                print("headers \(self.headers)")
                self.regService.checkClient(headers: self.headers, cardNumber: cardNumber, login: login, password: password, phone: phone, verificationCode: verificationCode, completionHandler: completionHandler)
            }
            else {
                completionHandler(false, nil)
            }
        }
    }
    
    func doRegistration(completionHandler: @escaping (_ success:Bool,_ errorMessage: String?, _ login: String?,_ password: String?) -> Void) {
        authService.csrf(headers: headers) { [unowned self] (success, newHeaders) in
            if success {
                self.headers.merge(newHeaders ?? [:], uniquingKeysWith: { (_, k2) -> String in
                    return k2
                })
                //                print("headers \(self.headers)")
                self.regService.doRegistration(headers: self.headers, completionHandler: completionHandler)
            }
            else {
                completionHandler(false, nil, nil, nil)
            }
        }
    }
    
    func verifyCode(verificationCode: Int,
                    completionHandler: @escaping (_ success:Bool,_ errorMessage: String?) -> Void) {
        authService.csrf(headers: headers) { [unowned self] (success, newHeaders) in
            if success {
                self.headers.merge(newHeaders ?? [:], uniquingKeysWith: { (_, k2) -> String in
                    return k2
                })
                //                print("headers \(self.headers)")
                self.regService.verifyCode(headers: self.headers, verificationCode: verificationCode, completionHandler: completionHandler)
            }
            else {
                completionHandler(false, nil)
            }
        }
    }
    
    //MARK: - card service
    func getCardList(completionHandler: @escaping (_ success:Bool, _ cards: [Card]?) -> Void) {
        cardService.getCardList(headers: headers, completionHandler: completionHandler)
    }
    
    func blockCard(withNumber num: String,
                   completionHandler: @escaping (Bool) -> Void) {
        cardService.blockCard(withNumber: num, completionHandler: completionHandler)
    }
    
    func getTransactionsStatement(forCardNumber number: String,
                                  fromDate: Date,
                                  toDate: Date,
                                  completionHandler: @escaping (_ success:Bool, _ datedTransactions: [DatedTransactions]?) -> Void) {
        TestCardService().getTransactionsStatement(forCardNumber: number,
                                                 fromDate: fromDate,
                                                 toDate: toDate,
                                                 headers: headers,
                                                 completionHandler: completionHandler)
//        cardService.getTransactionsStatement(forCardNumber: number,
//                                             fromDate: fromDate,
//                                             toDate: toDate,
//                                             headers: headers,
//                                             completionHandler: completionHandler)
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
    func getBonds(completionHandler: @escaping (_ success:Bool, _ obligations: [Bond]?) -> Void) {
         depositsService.getBonds(headers: headers, completionHandler: completionHandler)
    }
    func getLoans(completionHandler: @escaping (_ success:Bool, _ obligations: [Loan]?) -> Void) {
        loansService.getLoans(headers: headers, completionHandler: completionHandler)
    }
    //MARK: - deposits service
    func getDepos(completionHandler: @escaping (_ success:Bool, _ obligations: [Depos]?) -> Void) {
        deposService.getDepos(headers: headers, completionHandler: completionHandler)
    }
    //MARK: - check errorMessage for closing session
    func checkForClosingSession(_ errorMessage: String?) -> Bool {
        if let errorMessage = errorMessage,
            errorMessage.range(of:"Сессия не авторизована") != nil {
            logOut { (success) in
            }
            return true
        } else {
            return false
        }
    }
}
