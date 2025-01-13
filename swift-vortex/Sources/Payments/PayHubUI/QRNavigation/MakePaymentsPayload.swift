//
//  MakePaymentsPayload.swift
//  
//
//  Created by Igor Malyarov on 16.11.2024.
//

import Foundation

public enum MakePaymentsPayload<QRCode, Source> {
    
    case c2bSubscribe(URL)
    case c2b(URL)
    case details(QRCode) // MainViewModelAction.Show.Requisites
    case source(Source)
}

extension MakePaymentsPayload: Equatable where QRCode: Equatable, Source: Equatable {}
