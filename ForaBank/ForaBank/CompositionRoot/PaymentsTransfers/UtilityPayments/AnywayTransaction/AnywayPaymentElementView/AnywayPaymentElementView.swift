//
//  AnywayPaymentElementView.swift
//  ForaBank
//
//  Created by Igor Malyarov on 23.05.2024.
//

import AnywayPaymentDomain
import PaymentComponents
import SwiftUI

struct AnywayPaymentElementView<IconView: View>: View {
    
    let state: State
    let event: (Event) -> Void
    let factory: Factory
    #warning("better move config to factory")
    let config: Config
    
    var body: some View {
        
        switch state.uiComponent {
        case let .field(field):
            PaymentComponents.InfoView(
                info: field.info,
                config: config.info,
                icon: { makeIconView(field) }
            )
            
        case let .parameter(parameter):
            AnywayPaymentParameterView(
                parameter: parameter,
                event: { event(.setValue($0, for: parameter.id.parameterID)) },
                factory: factory.elementFactory
            )
            
        case let .widget(widget):
            switch widget {
            case let .otp(otp):
    #warning("replace with real components")
                HStack {
                    
                    Text("OTP: " + (otp.map { "\($0)" } ?? ""))
                    TextField(
                        "Введите код",
                        text: .init(
                            get: { otp.map { "\($0)" } ?? "" },
                            set: { event(.widget(.otp($0))) }
                        )
                    )
                }
    #warning("can't use CodeInputView - not a part  af any product (neither PaymentComponents nor any other)")
    #warning("need a wrapper with timer")
                //            CodeInputView(
                //                state: <#T##OTPInputState.Status.Input#>,
                //                event: <#T##(OTPInputEvent) -> Void#>,
                //                config: <#T##CodeInputConfig#>
                //            )
                
            case let .productPicker(productID):
                factory.makeProductSelectView(productID, { event(.widget(.product($0, $1))) })
            }
        }
    }
    
    private func makeIconView(
        _ field: AnywayPaymentDomain.AnywayPayment.Element.UIComponent.Field
    ) -> some View {
        
        factory.makeIconView(.field(field))
    }
}

extension AnywayPaymentElementView {
    
    typealias State = AnywayPaymentDomain.AnywayPayment.Element
    typealias Event = AnywayPaymentEvent
    typealias Factory = AnywayPaymentElementViewFactory<IconView>
    typealias Config = AnywayPaymentElementConfig
}

// MARK: - Adapters

private extension AnywayPaymentDomain.AnywayPayment.Element.UIComponent.Field {
    
    var info: PaymentComponents.Info {

        #warning("hardcoded style")
        return .init(id: id, title: title, value: value, style: .expanded)
    }
}

private extension  AnywayPaymentDomain.AnywayPayment.Element.UIComponent.Field {

    var id: PaymentComponents.Info.ID {
        
        switch name {
        case "amount":        return .amount
        case "brandName":     return .brandName
        case "recipientBank": return .recipientBank
        default:              return .other(name)
        }
    }
}

private extension AnywayPaymentDomain.AnywayPayment.Element.UIComponent.Parameter.ID {
    
    var parameterID: AnywayPaymentEvent.ParameterID {
        
        return .init(rawValue)
    }
}
