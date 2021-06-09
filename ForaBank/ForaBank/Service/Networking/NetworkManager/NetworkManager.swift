//
//  NetworkManager.swift
//  ForaBank
//
//  Created by Константин Савялов on 07.06.2021.
//

import Foundation

final class NetworkManager<T: NetworkModelProtocol>{
    
    static func addRequest(_ requestType: RouterManager,
                           _ urlParametrs: [String: String],
                            _ requestBody: [String: String],
                            completion: @escaping (_ movie: T?,_ error: String?)->()) {
        
        guard var request = requestType.request() else { return }
 
        let session = RouterSassionConfiguration.returnSession()
        
     //   request.allHTTPHeaderFields = addHeader    +++++++++Singlton
        
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
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")

        if request.value(forHTTPHeaderField: "Content-Type") == nil {
            request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        }

        /// Request Body
        do {
            let jsonAsData = try JSONSerialization.data(withJSONObject: requestBody, options: [])
            request.httpBody = jsonAsData
            
            if request.value(forHTTPHeaderField: "Content-Type") == nil {
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            }
        } catch {
            debugPrint(NetworkError.encodingFailed)
        }
        
        }
        
        let task = session.dataTask(with: request) { data, response, error in
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
        task.resume()
        
        func handleNetworkResponse(_ response: HTTPURLResponse) -> SessionResult<String>{
           switch response.statusCode {
           case 200...299: return .success
           case 401...500: return .failure(NetworkResponse.authenticationError.rawValue)
           case 501...599: return .failure(NetworkResponse.badRequest.rawValue)
           case 600: return .failure(NetworkResponse.outdated.rawValue)
           default: return .failure(NetworkResponse.failed.rawValue)
           }
       }
    }
    
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
