//
//  AnywayInfoView.swift
//  ForaBank
//
//  Created by Igor Malyarov on 03.07.2024.
//

import SwiftUI

struct AnywayInfoView: View {
    
    let fields: [Info.Field]
    let config: Config
    
    var body: some View {
        
        VStack(spacing: 13) {
            
            ForEach(fields, content: fieldView)
        }
    }
}

extension AnywayInfoView {
    
    typealias Info = AnywayElementModel.Widget.Info
    typealias Config = AnywayInfoViewConfig
}

extension AnywayElementModel.Widget.Info.Field: Identifiable {
    
    var id: ID {
        
        switch self {
        case .amount: return .amount
        case .fee:    return .fee
        case .total:  return .total
        }
    }
    
    enum ID: Hashable {
        
        case amount, fee, total
    }
}

private extension AnywayInfoView {
    
    func fieldView(
        field: Info.Field
    ) -> some View {
        
        switch field {
        case let .amount(amount):
            fieldView(title: "Сумма перевода", value: amount)
            
        case let .fee(fee):
            fieldView(title: "Комиссия", value: fee)
            
        case let .total(total):
            fieldView(title: "Сумма списания", value: total)
        }
    }
    
    func fieldView(
        title: String,
        value: String
    ) -> some View {
        
        HStack {
            
            title.text(withConfig: config.title)
            value.text(withConfig: config.value)
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
    }
}
