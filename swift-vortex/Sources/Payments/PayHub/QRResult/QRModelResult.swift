//
//  QRModelResult.swift
//
//
//  Created by Igor Malyarov on 29.10.2024.
//

import VortexTools
import Foundation

public typealias QRModelResult<Operator, Provider, QRCode, QRMapping, Source> = QRResult<QRCode, QRMappedResult<Operator, Provider, QRCode, QRMapping, Source>>
