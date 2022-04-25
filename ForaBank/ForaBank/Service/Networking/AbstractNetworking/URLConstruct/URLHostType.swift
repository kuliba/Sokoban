//
//  URLHostType.swift
//  ForaBank
//
//  Created by Константин Савялов on 07.06.2021.
//

import Foundation

/// Перечисление, члены которого определяют выбор сервера адреса
class URLHost {
    
    func getHost() -> String {
        var host = "bg.forabank.ru/dbo/api/v4/f437e29a3a094bcfa73cea12366de95b"
//        #if DEBUG
//        host = "test.inn4b.ru/dbo/api/v3"
////        host = "git.briginvest.ru/dbo/api/v3"
//        #endif
        return host
    }
    
    enum URLHostType: String  {
        
        /// Для тестовых запросов используется этот хост
        case release  = "bg.forabank.ru/dbo/api/v4/f437e29a3a094bcfa73cea12366de95b"
        
        /// Для релизных запросов используется этот хост
        case qa = "test.inn4b.ru/dbo/api/v3"
    }
}
