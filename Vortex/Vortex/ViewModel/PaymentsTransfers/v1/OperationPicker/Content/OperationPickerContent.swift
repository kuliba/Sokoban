//
//  OperationPickerContent.swift
//  Vortex
//
//  Created by Igor Malyarov on 22.08.2024.
//

import Foundation
import PayHub
import LatestPaymentsBackendV3
import PayHubUI
import RemoteServices
import RxViewModel

typealias Latest = RemoteServices.ResponseMapper.LatestPayment

extension Latest: Identifiable {
    
    public var id: Int {
        
        switch self {
        case let .service(service):     return service.date
        case let .withPhone(withPhone): return withPhone.date
        }
    }
}
