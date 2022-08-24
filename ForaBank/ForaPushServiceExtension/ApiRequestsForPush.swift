//
//  ApiRequestsForPush.swift
//  ForaBank
//
//  Created by Роман Воробьев on 05.05.2022.
//

import Foundation


class ApiRequestsForPush {
    
    static func changeNotificationStatus(eventId: String, cloudId: String, status: String, completion: @escaping (_ success: Bool, _ error: String?) -> ()) {
        let body = ["eventId": eventId,
                    "cloudId": cloudId,
                    "status": status] as [String: AnyObject]
        
        NetworkManagerExt<MakeTransferDecodableModel>.addRequest(.changeNotificationStatus, [:], body) { model, error in
            if error != nil {
                completion(false, error)
            }
            guard let model = model else {
                return
            }
            if model.statusCode == 0 {
                completion(true, nil)
            } else {
                guard let error = model.errorMessage else {
                    return
                }
                completion(false, error)
            }
        }
    }
}


class NetworkManagerExt<T: NetworkModelProtocol> {
    
    static func addRequest(_ requestType: RouterManager,
                           _ urlParametrs: [String: String],
                           _ requestBody: [String: AnyObject],
                           completion: @escaping (_ model: T?, _ error: String?)->()) {
        
        var debuggedApi = [String]()
        debuggedApi.append("changeNotificationStatus")
        
        guard var request = requestType.request() else { return }
        
        let s = RouterSassionConfiguration()
        let session = s.returnSession()
        
        if let token = CSRFToken.token {
            request.allHTTPHeaderFields = ["X-XSRF-TOKEN": token]
        }
        
        debuggedApi.forEach { filter in
            if (request.url?.absoluteString ?? "").contains(filter) {

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
                
                request.url = urlComponents.url
            }
            request.setValue("application/json; charset=UTF-8", forHTTPHeaderField: "Content-Type")
            
            if request.value(forHTTPHeaderField: "Content-Type") == nil {
                request.setValue("application/json; charset=UTF-8", forHTTPHeaderField: "Content-Type")
            }
            
            do {
                let jsonAsData = try JSONSerialization.data(withJSONObject: requestBody, options: [])
                request.httpBody = jsonAsData
                
                debuggedApi.forEach { filter in
                    if (request.url?.absoluteString ?? "").contains(filter) {
                        if let data = request.httpBody, let str = String(data: data, encoding: .utf8) {

                        }
                    }
                }
                
                
                if request.value(forHTTPHeaderField: "Content-Type") == nil {
                    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                }
            } catch {
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
                            completion(nil, NetworkResponseExt.noData.rawValue)
                            return
                        }
                        debuggedApi.forEach { filter in
                            if (request.url?.absoluteString ?? "").contains(filter) {
                                do {
                                    if let dataUnw = data, let str = String(data: dataUnw, encoding: .utf8) {
                                        
                                    }
                                } catch {
                                }
                            }
                        }
                        do {
                            let returnValue = try T (data: data!)
                            completion(returnValue, nil)
                        } catch {
                            completion(nil, NetworkResponseExt.unableToDecode.rawValue)
                        }
                    case .failure(let networkFailureError):
                        completion(nil, networkFailureError)
                    }
                }
            }
        }
        task.resume()
        
        func handleNetworkResponse(_ response: HTTPURLResponse) -> SessionResultExt<String>{
            switch response.statusCode {
            case 200...299: return .success
            case 400...401: return .success
            case 402...500: return .failure(NetworkResponseExt.authenticationError.rawValue)
            case 501...599: return .failure(NetworkResponseExt.badRequest.rawValue)
            case 600:       return .failure(NetworkResponseExt.outdated.rawValue)
            default:        return .failure(NetworkResponseExt.failed.rawValue)
            }
        }
    }
}

public enum NetworkErrorExt : String, Error {
    case parametersNil = "Parameters were nil."
    case encodingFailed = "Parameter encoding failed."
    case missingURL = "URL is nil."
}

enum NetworkResponseExt: String {
    case success
    case authenticationError = "Сначала вам нужно пройти аутентификацию."
    case badRequest = "Неверный запрос"
    case outdated = "Запрошенный вами URL устарел."
    case failed = "Сетевой запрос не удался."
    case noData = "Ответ возвращен без данных для декодирования."
    case unableToDecode = "Мы не смогли расшифровать ответ."
}

enum SessionResultExt<String> {
    case success
    case failure(String)
}
