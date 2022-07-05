//
//  Model+Version.swift
//  ForaBank
//
//  Created by Дмитрий on 29.06.2022.
//

import Foundation

//MARK: - Actions

extension ModelAction {
    
    enum AppVersion {
          
        struct Request: Action {}

        struct Response: Action {

            let result: Result<AppInfo, Error>
        }
    }
}


//MARK: - Handlers

extension Model {
    
    func handleVersionAppStore() {
        
        guard let identifier = Bundle.main.infoDictionary?["CFBundleIdentifier"] as? String,
              let url = URL(string: "http://itunes.apple.com/lookup?bundleId=\(identifier)") else {
                action.send(ModelAction.AppVersion.Response(result: .failure(ModelActionVersionError.unableCreateRequest)))
             return
         }
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in

            do {
                if let error = error { throw error }
                guard let data = data else { throw ModelActionVersionError.invalidResponse }
                let result = try JSONDecoder().decode(AppInfoLookupResult.self, from: data)
                guard let info = result.results.first else { throw ModelActionVersionError.invalidResponse }
                
                self.action.send(ModelAction.AppVersion.Response(result: .success(info)))
                
            } catch {
                
                self.action.send(ModelAction.AppVersion.Response(result: .failure(error)))
            }
        }
        task.resume()
    }
}

enum ModelActionVersionError: Error {
    case unableCreateRequest, invalidResponse
}

