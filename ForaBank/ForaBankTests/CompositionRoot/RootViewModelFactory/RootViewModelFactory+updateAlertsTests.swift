//
//  RootViewModelFactory+updateAlertsTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 02.12.2024.
//

import Combine
@testable import ForaBank
import XCTest

final class RootViewModelFactory_updateAlertsTests: RootViewModelFactoryTests {
    
    func test_shouldCallWithRequest() {
        
        let (sut, httpClient, _) = makeSUT()
        
        sut.updateAlerts()
        
        XCTAssertNoDiff(
            httpClient.requests.map(\.url?.lastPathComponent),
            ["getNotAuthorizedZoneClientInformData"]
        )
    }
    
    func test_shouldNotUpdateValuesOnFailure() {
        
        let alertManagerSpy = AlertManagerSpy()
        let (sut, httpClient, _) = makeSUT(model: .mockWithEmptyExcept(
            clientInformAlertManager: alertManagerSpy
        ))
        XCTAssertNoDiff(alertManagerSpy.updates.map(noID), [])
        
        sut.updateAlerts()
        httpClient.complete(with: .failure(anyNSError()))
        
        XCTAssertNoDiff(alertManagerSpy.updates.map(noID), [])
    }
    
    func test_shouldUpdateValuesOnSuccess() {
        
        let alertManagerSpy = AlertManagerSpy()
        let (sut, httpClient, _) = makeSUT(model: .mockWithEmptyExcept(
            clientInformAlertManager: alertManagerSpy
        ))
        XCTAssertNoDiff(alertManagerSpy.updates.map(noID), [])
        
        sut.updateAlerts()
        httpClient.complete(with: .success((makeValidData(), anyHTTPURLResponse())))
                
        XCTAssertNoDiff(alertManagerSpy.updates.map(noID), [
            .init(
                informAlerts: [],
                updateAlert: .init(
                    title: "Ой сломалось",
                    text: "Мы уже знаем о проблеме и работаем над её исправлением. Попробуйте зайти позже, а пока можете посмотреть наши продукты",
                    link: <#T##String?#>,
                    version: <#T##String?#>,
                    actionType: <#T##NoIDClientInformAlerts.UpdateAlert.ClientInformActionType#>
                )
            )
        ])
        _ = sut
    }
    
    // MARK: - Helpers
    
    private func makeValidData() -> Data {
        
        .init(String.notAuthorized.utf8)
    }
    
    private func noID(
        _ alerts: ClientInformAlerts
    ) -> NoIDClientInformAlerts {
        
        return .init(
            informAlerts: alerts.informAlerts.map(map),
            updateAlert: alerts.updateAlert.map(map)
        )
    }
    
    private func map(
        _ alert: ClientInformAlerts.InformAlert
    ) -> NoIDClientInformAlerts.InformAlert {
        
        return .init(title: alert.title, text: alert.text)
    }
    
    private func map(
        _ alert: ClientInformAlerts.UpdateAlert
    ) -> NoIDClientInformAlerts.UpdateAlert {
        
        return .init(title: alert.title, text: alert.text, link: alert.link, version: alert.version, actionType: map(alert.actionType))
    }
    
    private func map(
        _ actionType: ClientInformActionType
    ) -> NoIDClientInformAlerts.UpdateAlert.ClientInformActionType {
        
        switch actionType {
        case .required:     return .required
        case .optional:     return .optional
        case .authBlocking: return .authBlocking
        }
    }
    
    private struct NoIDClientInformAlerts: Equatable {
        
        let informAlerts: [InformAlert]
        let updateAlert: UpdateAlert?
        
        struct InformAlert: Equatable {
            
            let title: String
            let text: String
        }
        struct UpdateAlert: Equatable {
            
            let title: String
            let text: String
            let link: String?
            let version: String?
            let actionType: ClientInformActionType
            
            enum ClientInformActionType {
                
                case required
                case optional
                case authBlocking
            }
        }
    }
}

// MARK: - Helpers

private extension String {
    
    static let notAuthorized = """
{
    "statusCode": 0,
    "errorMessage": null,
    "data": {
        "serial": "1bebd140bc2660211fbba306105479ae",
        "notAuthorized": [
            {
                "authBlocking": true,
                "title": "Ой сломалось",
                "text": "Мы уже знаем о проблеме и работаем над её исправлением. Попробуйте зайти позже, а пока можете посмотреть наши продукты"
            },
            {
                "authBlocking": false,
                "title": "Внимание!",
                "text": "Вышло новое обновление! Обновитесь скорее!",
                "update": {
                    "action": "optional",
                    "platform": "iOS",
                    "version": "7.12.15",
                    "link": "LINK"
                }
            }
        ]
    }
}
"""
}
