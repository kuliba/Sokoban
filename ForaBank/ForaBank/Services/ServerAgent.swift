//
//  ServerAgent.swift
//  ForaBank
//
//  Created by Max Gribov on 21.12.2021.
//

import Foundation

class ServerAgent: NSObject, ServerAgentProtocol {

    private var baseURL: String { enviroment.baseURL }
    private let enviroment: Environment
  
    private lazy var session: URLSession = {
        
        let configuration = URLSessionConfiguration.default
        configuration.httpShouldSetCookies = false
        configuration.httpCookieAcceptPolicy = .never
        
        return URLSession(configuration: configuration)
        
    }()
    
    private lazy var sessionCached: URLSession = {
        
        let configuration = URLSessionConfiguration.default
        configuration.httpShouldSetCookies = false
        configuration.httpCookieAcceptPolicy = .never
        configuration.urlCache = URLCache.downloadCache
        
        return URLSession(configuration: configuration)
        
    }()
    
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder
    private var cookies: [HTTPCookie]?
    
    internal init(enviroment: Environment) {
        
        self.enviroment = enviroment
        self.encoder = JSONEncoder.serverDate
        self.decoder = JSONDecoder.serverDate
    }
    
    func executeCommand<Command>(command: Command, completion: @escaping (Result<Command.Response, ServerAgentError>) -> Void) where Command : ServerCommand {
        
        do {
            
            let request = try request(with: command)
            session.dataTask(with: request) {[unowned self] data, response, error in
                
                if let error = error {
                    
                    completion(.failure(.sessionError(error)))
                    return
                }
                
                guard let response = response as? HTTPURLResponse else {
                    
                    completion(.failure(.emptyResponse))
                    return
                }
                
                if command.cookiesProvider == true,
                    let headers = response.allHeaderFields as? [String: String],
                    let url = request.url {
                    
                    let responseCookies = HTTPCookie.cookies(withResponseHeaderFields: headers, for: url)
                    if responseCookies.count > 0 {
                        
                        self.cookies = responseCookies
                    }
                }
                
                guard let data = data else {
                    completion(.failure(.emptyResponseData))
                    return
                }

                do {
                    
                    let response = try decoder.decode(Command.Response.self, from: data)
                    completion(.success(response))
                    
                } catch {
                    
                    completion(.failure(.curruptedData(error)))
                }
     
            }.resume()
            
        } catch {
            
            completion(.failure(ServerAgentError.requestCreationError(error)))
        }
    }
    
    func executeDownloadCommand<Command>(command: Command, completion: @escaping (Result<Command.Response, ServerAgentError>) -> Void) where Command : ServerDownloadCommand {
        
        do {
            
            let request = try downloadRequest(with: command)
            sessionCached.downloadTask(with: request) { localFileURL, response, error in
                
                if let error = error {
                    
                    completion(.failure(.sessionError(error)))
                    return
                }
                
                guard let response = response else {
                    
                    completion(.failure(.emptyResponse))
                    return
                }
                
                guard let localFileURL = localFileURL else {
                    
                    completion(.failure(.emptyResponseData))
                    return
                }
  
                do {
                    
                    let data = try Data(contentsOf: localFileURL)
                    
                    // store data in cache
                    if self.sessionCached.configuration.urlCache?.cachedResponse(for: request) == nil {
                        
                        self.sessionCached.configuration.urlCache?.storeCachedResponse(CachedURLResponse(response: response, data: data), for: request)
                    }
                    
                    completion(.success(data))
                    
                } catch {
                    
                    completion(.failure(.curruptedData(error)))
                }
                
            }.resume()
            
        } catch {
            
            completion(.failure(ServerAgentError.requestCreationError(error)))
        }
    }
}

//MARK: - Request

internal extension ServerAgent {
    
    //TODO: tests
    func request<Command>(with command: Command) throws -> URLRequest where Command : ServerCommand {
        
        let url = try url(with: command.endpoint)
        
        var request = URLRequest(url: url)

        // http method
        request.httpMethod = command.method.rawValue
        
        // cookies headers
        request.httpShouldHandleCookies = false
        if let cookies = self.cookies {
           
            request.allHTTPHeaderFields = HTTPCookie.requestHeaderFields(with: cookies)
        }
        
        // headers
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // token
        if let token = command.token {
            
            request.setValue(token, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        
        // parameters
        if let parameters = command.parameters, parameters.isEmpty == false {
            
            var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)
            urlComponents?.queryItems = parameters.map{ URLQueryItem(name: $0.name, value: $0.value) }
            
            guard let updatedURL = urlComponents?.url else {
                throw ServerRequestCreationError.unableCounstructURLWithParameters
            }
            
            request.url = updatedURL
        }
        
        // body
        if let payload = command.payload {
            
            do {
                
                request.httpBody = try encoder.encode(payload)
                
            } catch {
                
                throw ServerRequestCreationError.unableEncodePayload(error)
            }
        }
        
        // timeout
        if let timeout = command.timeout {
            
            request.timeoutInterval = timeout
        }
        
        return request
    }
    
    //TODO: tests
    func downloadRequest<Command>(with command: Command) throws -> URLRequest where Command : ServerDownloadCommand {
        
        let url = try url(with: command.endpoint)
        
        var request = URLRequest(url: url)
        
        // headers
        request.httpMethod = command.method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // token
        if let token = command.token {
            
            request.setValue(token, forHTTPHeaderField: "X-XSRF-TOKEN")
        }

        // parameters
        if let parameters = command.parameters, parameters.isEmpty == false {
            
            var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)
            urlComponents?.queryItems = parameters.map{ URLQueryItem(name: $0.name, value: $0.value) }
            
            guard let updatedURL = urlComponents?.url else {
                throw ServerRequestCreationError.unableCounstructURLWithParameters
            }
            
            request.url = updatedURL
        }
        
        // body
        if let payload = command.payload {
            
            do {
                
                request.httpBody = try encoder.encode(payload)
                
            } catch {
                
                throw ServerRequestCreationError.unableEncodePayload(error)
            }
        }
        
        // timeout
        if let timeout = command.timeout {
            
            request.timeoutInterval = timeout
        }
        
        // cache policy
        request.cachePolicy = command.cachePolicy
        
        return request
    }
    
    //TODO: tests
    func url(with endpoint: String) throws -> URL {
        
        guard let url = URL(string: baseURL + endpoint) else {
            throw ServerRequestCreationError.unableConstructURL
        }
        
        return url
    }
}

//MARK: - Types

extension ServerAgent {
    
    enum Environment {
        
        case test
        case prod
        
        var baseURL: String {
            
            switch self {
            case .test:
                return "https://test.inn4b.ru/dbo/api/v3"
            case .prod:
                return "https://bg.forabank.ru/dbo/api/v4/f437e29a3a094bcfa73cea12366de95b"
            }
        }
    }
}

//MARK: - URLSessionDelegate

extension ServerAgent: URLSessionDelegate {
    
}

//MARK: - URLSessionTaskDelegate

extension ServerAgent: URLSessionTaskDelegate {
    
}

//MARK: - URLSessionDataDelegate
extension ServerAgent: URLSessionDataDelegate {
    
}
