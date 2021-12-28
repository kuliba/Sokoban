//
//  RouterSassionConfiguration.swift
//  ForaBank
//
//  Created by Константин Савялов on 07.06.2021.
//

import Foundation

final class RouterSassionConfiguration: NSObject, URLSessionDelegate {
    
    var session: URLSession?
    
    func returnSession () -> URLSession {
        
        session = URLSession.shared
            // Логическое значение, определяющее, следует ли устанавливать соединения по сотовой сети.
        session?.configuration.allowsCellularAccess = true
            // Интервал времени ожидания, используемый при ожидании дополнительных данных.
        session?.configuration.timeoutIntervalForRequest = 180
            // Максимальное количество времени, которое может потребоваться для запроса ресурса.
        session?.configuration.timeoutIntervalForResource = 180
            // Логическое значение, которое указывает, должен ли сеанс ждать, пока подключение станет доступным, или немедленно завершиться неудачей.
            if #available(iOS 11.0, *) {
                session?.configuration.waitsForConnectivity = false
            } else {
                // Fallback on earlier versions
            }
            // Логическое значение, которое указывает, должны ли TCP-соединения оставаться открытыми, когда приложение переходит в фоновый режим.
            if #available(iOS 9.0, *) {
                session?.configuration.shouldUseExtendedBackgroundIdleMode = false
            } else {
                // Fallback on earlier versions
            }
            /* Тип сервиса, который определяет политику многопутевого соединения TCP для передачи данных через Wi-Fi и сотовые интерфейсы.
            Ключ handover - многопутевая служба TCP, обеспечивающая бесшовную передачу обслуживания между Wi-Fi и сотовой связью, чтобы сохранить соединение.*/
            if #available(iOS 11.0, *) {
                session?.configuration.multipathServiceType = .handover
            } else {
                // Fallback on earlier versions
            }
            // Это свойство определяет, должны ли задачи в сеансах, основанных на этой конфигурации, использовать конвейерную передачу HTTP
        session?.configuration.httpShouldUsePipelining = true
            // Система определяет, что соединение является «дорогим», на основе характера сетевого интерфейса и других факторов. Логическое значение, которое указывает, могут ли подключения использовать сетевой интерфейс, который система считает дорогим.
            if #available(iOS 13.0, *) {
                session?.configuration.allowsExpensiveNetworkAccess = true
            } else {
                // Fallback on earlier versions
            }
           //  Логическое значение, которое указывает, могут ли соединения использовать сеть, когда пользователь указал режим малого потребления трафика.
            if #available(iOS 13.0, *) {
                session?.configuration.allowsConstrainedNetworkAccess = true
            } else {
                // Fallback on earlier versions
            }
        return session!
        }
    
    override init() {
        super.init()
    }
}
