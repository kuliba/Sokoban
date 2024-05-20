//
//  AnywayPaymentState.swift
//
//
//  Created by Igor Malyarov on 21.04.2024.
//

struct AnywayPaymentState<Icon> {
    
    let info: Info<Icon>
    var input: InputState<Icon>
    var product: Product
}

extension AnywayPaymentState: Equatable where Icon: Equatable {}
