//
// URLHostType.swift
//  ForaBank
//
//  Created by Константин Савялов on 07.06.2021.
//

import Foundation

/// Перечисление, члены которого определяют выбор сервера адреса
enum URLHost {
    
    static func getHost() -> String {
        Config.host
    }
    
    enum URLHostType: String  {
        
        /// Для тестовых запросов используется этот хост
        case release = "bg.forabank.ru/dbo/api/v4/f437e29a3a094bcfa73cea12366de95b"
        
        /// Для релизных запросов используется этот хост
        case qa = "pl.forabank.ru/dbo/api/v3"
    }
}
