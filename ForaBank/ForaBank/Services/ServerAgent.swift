//
//  ServerAgent.swift
//  ForaBank
//
//  Created by Max Gribov on 21.12.2021.
//

import Foundation

class ServerAgent: ServerAgentProtocol {

    private let context: Context
    private var baseURL: String { context.env.baseURL }
    
    internal init(context: Context) {
        
        self.context = context
    }
    
    func executeCommand<Command>(command: Command, completion: @escaping (Result<Command.Response, ServerAgentError>) -> Void) where Command : ServerCommand {
        
        do {
            
            let request = try request(with: command)
            context.session.dataTask(with: request) {[unowned self] data, _, error in
                
                if let error = error {
                    
                    completion(.failure(.sessionError(error)))
                    return
                }
                
                guard let data = data else {
                    
                    //TODO: handle serever response ststus if no data
                    completion(.failure(.emptyResponseData))
                    return
                }
                
                do {
                    
                    let response = try context.decoder.decode(Command.Response.self, from: data)
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
            context.session.downloadTask(with: request) { localFileURL, _, error in
                
                if let error = error {
                    
                    completion(.failure(.sessionError(error)))
                    return
                }
                
                guard let localFileURL = localFileURL else {
                    
                    //TODO: handle serever response ststus if no localFileURL
                    completion(.failure(.emptyResponseData))
                    return
                }
  
                do {
                    
                    let data = try Data(contentsOf: localFileURL)
                    completion(.success(data))
                    
                } catch {
                    
                    completion(.failure(.curruptedData(error)))
                }
            }
            
        } catch {
            
            completion(.failure(ServerAgentError.requestCreationError(error)))
        }
    }
}

//MARK: - Internal

internal extension ServerAgent {
    
    //TODO: tests
    func request<Command>(with command: Command) throws -> URLRequest where Command : ServerCommand {
        
        let url = try url(with: command.endpoint)
        
        var request = URLRequest(url: url)
        request.httpMethod = command.method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // token
        request.setValue(command.token, forHTTPHeaderField: "X-XSRF-TOKEN")
        
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
                
                request.httpBody = try context.encoder.encode(payload)
                
            } catch {
                
                throw ServerRequestCreationError.unableEncodePayload(error)
            }
        }
        
        return request
    }
    
    //TODO: tests
    func downloadRequest<Command>(with command: Command) throws -> URLRequest where Command : ServerDownloadCommand {
        
        let url = try url(with: command.endpoint)
        
        var request = URLRequest(url: url)
        request.httpMethod = command.method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // token
        request.setValue(command.token, forHTTPHeaderField: "X-XSRF-TOKEN")

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
                
                request.httpBody = try context.encoder.encode(payload)
                
            } catch {
                
                throw ServerRequestCreationError.unableEncodePayload(error)
            }
        }
        
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

//MARK: - Context

extension ServerAgent {
    
    class Context {
        
        let env: Environment
        let session: URLSession
        let encoder: JSONEncoder
        let decoder: JSONDecoder
        
        init(for env: Environment) {
            
            self.env = env
            //TODO: configure session
            self.session = URLSession.shared
            self.encoder = JSONEncoder()
            self.decoder = JSONDecoder()
        }
    }
    
    enum Environment {
        
        case test
        case prod
        
        var baseURL: String {
            
            switch self {
            case .test:
                return "https://git.briginvest.ru/dbo/api/v3"
            case .prod:
                return "https://bg.forabank.ru/dbo/api/v4/f437e29a3a094bcfa73cea12366de95b"
            }
        }
    }
}
