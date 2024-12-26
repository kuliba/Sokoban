//
//  RootViewModelFactory+updateAlerts.swift
//  Vortex
//
//  Created by Igor Malyarov on 02.12.2024.
//

import RemoteServices
import Combine

extension RootViewModelFactory {
    
    func updateClientInformAlerts() -> AnyCancellable {
        
        model.sessionState
            .map(\.isActive)
            .filter { $0 }
            .combineLatest( model.clientInformAlertManager.updatePermissionPublisher.filter { $0 })
            .sink { [weak self] _, _ in self?.updateAlerts() }
    }
}

extension RootViewModelFactory {
    
    @inlinable
    func updateAlerts() {
                
        let _createGetNotAuthorizedZoneClientInformData = nanoServiceComposer.compose(
            createRequest: RequestFactory.createGetNotAuthorizedZoneClientInformDataRequest,
            mapResponse: RemoteServices.ResponseMapper.mapGetNotAuthorizedZoneClientInformDataResponse
        )
        
        let createGetNotAuthorizedZoneClientInformData = { (completion: @escaping (ClientInformAlerts?) -> Void) in
            _createGetNotAuthorizedZoneClientInformData(()) {
                
                completion($0.alerts)
                _ = _createGetNotAuthorizedZoneClientInformData
            }
        }
        
        createGetNotAuthorizedZoneClientInformData {
            
            if let alerts = $0 {
                
                self.logger.log(level: .info, category: .network, message: "notifications \(alerts)", file: #file, line: #line)
                
                self.model.clientInformAlertManager.update(alerts: alerts)
            } else {
                
                self.logger.log(level: .error, category: .network, message: "failed to fetch NOTauthorizedZoneClientInformData", file: #file, line: #line)
            }
            
            _ = createGetNotAuthorizedZoneClientInformData
        }
    }
}

// MARK: - Adapters

extension SessionState {
    
    var isActive: Bool {
        
        guard case .active = self else { return false }
        
        return true
    }
}

extension Result where Success ==  RemoteServices.ResponseMapper.GetNotAuthorizedZoneClientInformDataResponse {
    
    var alerts: ClientInformAlerts? {
        
        try? self.map(\.alerts).get()
    }
}

private extension RemoteServices.ResponseMapper.GetNotAuthorizedZoneClientInformDataResponse {
    
    var alerts: ClientInformAlerts? {
        
        var alerts = ClientInformAlerts(id: .init(), informAlerts: [], updateAlert: nil)
        
        list.forEach {
            
            if $0.update == nil && $0.authBlocking == false {
                
                alerts.informAlerts.append(
                    .init(
                        id: .init(),
                        title: $0.title,
                        text: $0.text
                    )
                )
            }
        }
        
        if let alert = list.first(where: { $0.authBlocking || $0.update != nil }) {
            
            let actionType: ClientInformActionType
            
            if alert.authBlocking {
                actionType = .authBlocking
            } else {
                
                guard let typeString = alert.update?.type,
                      let action = ClientInformActionType(updateType: typeString)
                else { return nil }
                
                actionType = action
            }
            
            alerts.updateAlert = .init(
                id: .init(),
                title: alert.title,
                text: alert.text,
                link: alert.update?.link,
                version: alert.update?.version,
                actionType: actionType
            )}
        
        return alerts
    }
}
