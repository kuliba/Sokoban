import Foundation

enum ServerType {
    case test
    case production
}

class Host {
    
    static let shared: Host = Host()

    public var serverType: ServerType?

    public var apiBaseURL: String {
        switch serverType {
        case .test:
            return testApiBaseURL
        case .production:
            return productionApiBaseURL
        case .none:
        return testApiBaseURL
        }
    }

//    private let testApiBaseURL: String = "https://bg.forabank.ru/dbo/api/v3/f437e29a3a094bcfa73cea12366de95b/"
    public let testApiBaseURL: String = "https://git.briginvest.ru/dbo/api/v2/"

    public let productionApiBaseURL: String = "https://bg.forabank.ru/dbo/api/v3/f437e29a3a094bcfa73cea12366de95b/"
    

}


//class TestEnviroment {
//    
//        
//        
//}

//enum testEnviroment{
//    case "test"
//    case "production"
//}
