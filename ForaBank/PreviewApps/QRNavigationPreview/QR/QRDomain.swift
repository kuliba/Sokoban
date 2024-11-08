//
//  QRDomain.swift
//  QRNavigationPreview
//
//  Created by Igor Malyarov on 29.10.2024.
//

import PayHub
import PayHubUI

typealias QRDomain = PayHubUI.QRDomain<QRNavigation, QRModel, QRResult>

typealias QRNavigation = PayHubUI.QRNavigation<MixedPicker, Payments, QRFailureDomain.Binder>

typealias QRResult = QRModelResult<Operator, Provider, QRCode, QRMapping, Source>

struct Operator: Equatable {}
struct Provider: Equatable {}

struct QRCode: Equatable {
    
    let value: String
}

struct QRMapping: Equatable {}
struct Source: Equatable {}
