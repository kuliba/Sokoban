//
//  NetworkManager.swift
//  ForaBank
//
//  Created by Sergey on 11/12/2018.
//  Copyright © 2018 BraveRobin. All rights reserved.
//

import Foundation
import Alamofire

protocol AuthServiceProtocol {
    func isSignedIn(completionHandler: @escaping (_ success:Bool) -> Void)
    func csrf(headers: HTTPHeaders, completionHandler: @escaping (_ success:Bool, _ headers: HTTPHeaders?) -> Void)
    func loginDo(headers: HTTPHeaders, login: String, password: String, completionHandler: @escaping (_ success:Bool,_ errorMessage: String?) -> Void)
    func checkVerificationCode(headers: HTTPHeaders, code: String, completionHandler: @escaping (_ success:Bool) -> Void)
    func logOut(completionHandler: @escaping (_ success:Bool) -> Void)
}

protocol CardServiceProtocol {
    func getCardList(headers: HTTPHeaders, completionHandler: @escaping (_ success:Bool, _ cards: [Card]?) -> Void)
    func blockCard(withNumber num: String, completionHandler: @escaping (_ success:Bool) -> Void)
}

class NetworkManager {
    
    // MARK: - Properties
    
    private static var sharedNetworkManager: NetworkManager = {
        let host = "https://git.briginvest.ru/dbo/api/v2/"
        
        let authService = TestAuthService()//AuthService(baseURLString: host)//
        let cardService = TestCardService()
        
        let networkManager = NetworkManager(baseURLString: host, authService: authService, cardService: cardService)
        
        // Configuration
        
        
        return networkManager
    }()
    private let authService: AuthServiceProtocol
    private let cardService: CardServiceProtocol
    private let baseURLString: String
    private var headers: HTTPHeaders = [
        "Accept": "application/json",
        "Content-Type": "application/json"
    ]
    
    // Initialization
    
    private init(baseURLString: String, authService: AuthServiceProtocol, cardService: CardServiceProtocol) {
        self.baseURLString = baseURLString
        self.authService = authService
        self.cardService = cardService
    }
    
    // MARK: - Accessors
    
    class func shared() -> NetworkManager {
        return sharedNetworkManager
    }
    
    //MARK: - auth service
    func isSignedIn(completionHandler: @escaping (_ success:Bool) -> Void) {
        authService.isSignedIn(completionHandler: completionHandler)
    }
    
    func login(login: String, password: String, completionHandler: @escaping (_ success:Bool,_ errorMessage: String?) -> Void) {
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
    
    func checkVerificationCode(code: String, completionHandler: @escaping (_ success:Bool) -> Void) {
        authService.checkVerificationCode(headers: self.headers, code: code, completionHandler: completionHandler)
    }
    
    func logOut(completionHandler: ((_ success:Bool) -> Void)? ) {
        authService.logOut { (success) in
            if completionHandler != nil {
                completionHandler!(success)
            }
        }
    }
    
    //MARK: - card service
    func getCardList(completionHandler: @escaping (_ success:Bool, _ cards: [Card]?) -> Void) {
        cardService.getCardList(headers: headers, completionHandler: completionHandler)
    }
    
    func blockCard(withNumber num: String, completionHandler: @escaping (Bool) -> Void) {
        cardService.blockCard(withNumber: num, completionHandler: completionHandler)
    }
}
