//
//  NetworkManager.swift
//  ForaBank
//
//  Created by Константин Савялов on 07.06.2021.
//

import Foundation
import RealmSwift

final class NetworkManager<T: NetworkModelProtocol> {

    static func addRequest(_ requestType: RouterManager,
                           _ urlParametrs: [String: String],
                           _ requestBody: [String: AnyObject],
                           _ query: [URLQueryItem]? = nil,
                           completion: @escaping (_ model: T?, _ error: String?)->()) {
        
        var debuggedApi = [String]()
                debuggedApi.append("createC2BTransfer")
                debuggedApi.append("updateFastPaymentContract")
                debuggedApi.append("createFastPaymentContract")
                debuggedApi.append("getQRData")
                debuggedApi.append("make")
                debuggedApi.append("getOperationDetailByPaymentId")
                debuggedApi.append("createAnywayTransfer")
                debuggedApi.append("createAnywayTransferNew")
                debuggedApi.append("getOperationDetailByPaymentId")

        guard var request = requestType.request() else { return }

        let s = RouterSassionConfiguration()
        let session = s.returnSession()

        if let token = CSRFToken.token {
            request.allHTTPHeaderFields = ["X-XSRF-TOKEN": token]
        }
        
        debuggedApi.forEach { filter in
                    if (request.url?.absoluteString ?? "").contains(filter) {
                        print("NET5555", request.url?.absoluteString ?? "")
                    }
                }

        if request.httpMethod != "GET" {
            /// URL Parameters
            if var urlComponents = URLComponents(url: request.url!,
                    resolvingAgainstBaseURL: false), !urlParametrs.isEmpty {

                urlComponents.queryItems = [URLQueryItem]()

                urlParametrs.forEach({ (key, value) in
                    let queryItem = URLQueryItem(name: key,
                            value: "\(value)".addingPercentEncoding(withAllowedCharacters: .urlHostAllowed))
                    urlComponents.queryItems?.append(queryItem)
                })
                
                if query != nil {
                    query?.forEach { item in
                        urlComponents.queryItems?.append(item)
                    }
                }

                request.url = urlComponents.url
            }
            request.setValue("application/json; charset=UTF-8", forHTTPHeaderField: "Content-Type")

            if request.value(forHTTPHeaderField: "Content-Type") == nil {
                request.setValue("application/json; charset=UTF-8", forHTTPHeaderField: "Content-Type")
            }

            /// Request Body

            do {
                let jsonAsData = try JSONSerialization.data(withJSONObject: requestBody, options: [])
                request.httpBody = jsonAsData
                
                debuggedApi.forEach { filter in
                                    if (request.url?.absoluteString ?? "").contains(filter) {
                                        if let data = request.httpBody, let str = String(data: data, encoding: .utf8) {
                                            print("NET5555 Request \(str)")
                                        }
                                    }
                                }

                
                if request.value(forHTTPHeaderField: "Content-Type") == nil {
                    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                }
            } catch {
                debugPrint(NetworkError.encodingFailed)
            }

        }

        if request.httpMethod == "GET" {
            if var urlComponents = URLComponents(url: request.url!,
                    resolvingAgainstBaseURL: false), !urlParametrs.isEmpty {

                urlComponents.queryItems = [URLQueryItem]()

                urlParametrs.forEach({ (key, value) in
                    let queryItem = URLQueryItem(name: key,
                            value: "\(value)".addingPercentEncoding(withAllowedCharacters: .urlHostAllowed))
                    urlComponents.queryItems?.append(queryItem)
                })
                if query != nil {
                    query?.forEach { item in
                        urlComponents.queryItems?.append(item)
                    }
                }
                request.url = urlComponents.url
            }
        }
        
        let task = session.dataTask(with: request) { data, response, error in
            runOnMainQueue {
                if error != nil {
                    completion(nil, "Пожалуйста, проверьте ваше сетевое соединение.")
                }

                if let response = response as? HTTPURLResponse {
                    let result = handleNetworkResponse(response)
                    switch result {
                    case .success:
                        guard data != nil else {
                            completion(nil, NetworkResponse.noData.rawValue)
                            return
                        }
                    
                        let updatingTimeObject = returnRealmModel()
                        debuggedApi.forEach { filter in
                                                    if (request.url?.absoluteString ?? "").contains(filter) {
                                                        do {
                                                            if let dataUnw = data, let str = String(data: dataUnw, encoding: .utf8) {
                                                                print("NET5555 Answer \(response.url?.absoluteString ?? "") ", str)
                                                            
                                                            }
                                                        } catch {
                                                            //debugPrint(NetworkError.encodingFailed)
                                                        }
                                                    }
                                                }
                        
                        /// Сохраняем в REALM
                        let r = try? Realm()
                        do {
                            let b = r?.objects(GetSessionTimeout.self)
                            r?.beginWrite()
                            r?.delete(b!)
                            r?.add(updatingTimeObject)
                            try r?.commitWrite()
                        } catch {
                            print(error.localizedDescription)
                        }
                        do {
                            let returnValue = try T (data: data!)

                            completion(returnValue, nil)
                        } catch {
                            print(error)
                            completion(nil, NetworkResponse.unableToDecode.rawValue)
                        }
                    case .failure(let networkFailureError):
                        completion(nil, networkFailureError)
                    }
                }
            }
        }
        task.resume()

        func handleNetworkResponse(_ response: HTTPURLResponse) -> SessionResult<String>{
            switch response.statusCode {
            case 200...299: return .success
            case 400...401: return .success
            case 402...500: return .failure(NetworkResponse.authenticationError.rawValue)
            case 501...599: return .failure(NetworkResponse.badRequest.rawValue)
            case 600:       return .failure(NetworkResponse.outdated.rawValue)
            default:        return .failure(NetworkResponse.failed.rawValue)
            }
        }
    }
}

func returnRealmModel() -> GetSessionTimeout {
    let realm = try? Realm()
    guard let timeObject = realm?.objects(GetSessionTimeout.self).first else {return GetSessionTimeout()}
    let lastActionTimestamp = timeObject.lastActionTimestamp
    let maxTimeOut = timeObject.maxTimeOut
    let mustCheckTimeOut = timeObject.mustCheckTimeOut
    print("Debugging NetworkManager", mustCheckTimeOut)
    // Сохраняем текущее время
    let updatingTimeObject = GetSessionTimeout()

    updatingTimeObject.lastActionTimestamp = lastActionTimestamp
    updatingTimeObject.renewSessionTimeStamp = Date().localDate()
    updatingTimeObject.maxTimeOut = maxTimeOut
    updatingTimeObject.mustCheckTimeOut = mustCheckTimeOut

    return updatingTimeObject

}

public enum NetworkError : String, Error {
    case parametersNil = "Parameters were nil."
    case encodingFailed = "Parameter encoding failed."
    case missingURL = "URL is nil."
}

enum NetworkResponse: String {
    case success
    case authenticationError = "Сначала вам нужно пройти аутентификацию."
    case badRequest = "Неверный запрос"
    case outdated = "Запрошенный вами URL устарел."
    case failed = "Сетевой запрос не удался."
    case noData = "Ответ возвращен без данных для декодирования."
    case unableToDecode = "Мы не смогли расшифровать ответ."
}

enum SessionResult<String> {
    case success
    case failure(String)
}

