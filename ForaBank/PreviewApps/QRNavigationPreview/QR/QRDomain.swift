//
//  QRDomain.swift
//  QRNavigationPreview
//
//  Created by Igor Malyarov on 29.10.2024.
//

import PayHub
import PayHubUI

typealias QRNavigationDomain = PayHubUI.QRNavigationDomain<MixedPicker, MultiplePicker, Operator, Provider, Payments, QRCode, QRMapping, QRFailureDomain.Binder, Source>

typealias QRDomain = PayHubUI.QRDomain<QRNavigationDomain.Navigation, QRModel, QRNavigationDomain.Select>

struct Operator: Equatable {}
struct Provider: Equatable {}

struct QRCode: Equatable {
    
    let value: String
}

struct QRMapping: Equatable {}
struct Source: Equatable {}
