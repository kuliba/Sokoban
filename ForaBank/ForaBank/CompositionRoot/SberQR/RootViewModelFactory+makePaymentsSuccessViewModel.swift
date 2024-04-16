//
//  RootViewModelFactory+makePaymentsSuccessViewModel.swift
//  ForaBank
//
//  Created by Igor Malyarov on 11.12.2023.
//

import SberQR

extension RootViewModelFactory {
    
    static func makePaymentsSuccessViewModel(
        model: Model
    ) -> QRViewModelFactory.MakePaymentsSuccessViewModel {
        
        return { .init(paymentSuccess: $0.success, model) }
    }
}

// MARK: - Adapter

private extension CreateSberQRPaymentResponse {
    
    var success: Payments.Success {
        
        var parameters = parameters.map(\.representable)
        parameters.append(Payments.ParameterSuccessMode(mode: .sberQR))
        
        #warning("using not SberQR specific `service: .c2b, source: .qr`")
        let operation = Payments.Operation(
            service: .c2b,
            source: .qr,
            steps: [
                .init(
                    parameters: parameters,
                    front: .init(visible: [], isCompleted: true),
                    back: .init(
                        stage: .local,
                        required: parameters.map(\.id),
                        processed: nil
                    )
                )
            ],
            visible: []
        )
        
        return .init(
            operation: operation,
            parameters: parameters
        )
    }
}

private extension CreateSberQRPaymentResponse.Parameter {
    
    var representable: PaymentsParameterRepresentable {
        
        switch self {
        case let .button(button):
            return button.parameterButton
            
            // printFormType
        case let .dataString(dataString):
            return dataString.parameterDataValue
            
            // paymentOperationDetailId
        case let .dataLong(dataLong):
            return dataLong.parameterDataValue
            
        case let .successStatusIcon(successStatusIcon):
            return successStatusIcon.parameterSuccessStatus
            
        case let .successText(successText):
            return successText.parameterSuccessText
            
        case let .subscriber(subscriber):
            return subscriber.parameterSubscriber
            
        case let .successOptionButton(successOptionButton):
            return successOptionButton.options
        }
    }
}

private typealias Parameter = CreateSberQRPaymentResponse.Parameter

private extension Parameter.Button {
    
    var parameterButton: Payments.ParameterButton {
        
        .init(
            title: value,
            style: buttonStyle,
            acton: buttonAction
        )
    }
    
    var buttonAction: Payments.ParameterButton.Action {
        
        switch action {
        case .main: return .main
        }
    }
    
    var buttonStyle: Payments.ParameterButton.Style {
        
        switch color {
        case .red: return .primary
        }
    }
}

private extension CreateSberQRPaymentIDs.DataStringID {
 
    var rawID: String {
        
        switch self {
        case .printFormType: return "printFormType"
        }
    }
}
    
private extension Parameter.DataString {
    
    var parameterDataValue: Payments.ParameterDataValue {
        
        .init(parameter: .init(id: id.rawID, value: "\(value)"))
    }
}
    
private extension Parameter.DataLong {
    
    var parameterDataValue: Payments.ParameterDataValue {
        
        switch id {
        case .paymentOperationDetailId:
            let identifier: Payments.Parameter.Identifier = .successOperationDetailID
            
            return .init(parameter: .init(
                id: identifier.rawValue,
                value: "\(value)"
            ))
        }
    }
}

private extension Parameter.SuccessStatusIcon {
    
    var parameterSuccessStatus: Payments.ParameterSuccessStatus {
        
        .init(status: status)
    }
}

private extension Parameter.SuccessStatusIcon {
    
    var status: Payments.ParameterSuccessStatus.Status {
        
        switch value {
        case .complete:   return .success
        case .inProgress, .suspended: return .accepted
        case .rejected:   return .error
        }
    }
}

private extension Parameter.SuccessText {
    
    var parameterSuccessText: Payments.ParameterSuccessText {
        
        .init(value: value, style: style.textStyle)
    }
}

private extension SberQR.Parameters.Style {
    
    var textStyle: Payments.ParameterSuccessText.Style {
        
        switch self {
        case .amount: return .amount
        case .title: return .title
            // TODO: split CreateSberQRPaymentResponse.Parameter.Style to remove impossible style
        case .small: return .title
        }
    }
}

private extension CreateSberQRPaymentIDs.SubscriberID {
    
    var rawID: String {
        
        switch self {
        case .brandName: return "brandName"
        }
    }
}

private extension Parameter.Subscriber {
    
    var parameterSubscriber: Payments.ParameterSubscriber {
        
        .init(
            .init(id: id.rawID, value: value),
            icon: icon,
            description: description,
            style: subscriberStyle
        )
    }
    
    var description: String? {
    
        subscriptionPurpose.map { String(describing: $0) }
    }
    
    var subscriberStyle: Payments.ParameterSubscriber.Style {
        
        // TODO: split CreateSberQRPaymentResponse.Parameter.Style to remove impossible style
        switch style {
        case .amount: return .small
        case .title:  return .small
        case .small:  return .small
        }
    }
}

private extension Parameter.SuccessOptionButtons {
    
    var options: Payments.ParameterSuccessOptionButtons {
        
        .init(
            options: values.map(\.option),
            templateID: nil,
            meToMePayment: nil,
            operation: nil
        )
    }
}

private extension Parameter.SuccessOptionButtons.Value {
    
    var option: Payments.ParameterSuccessOptionButtons.Option {
        
        switch self {
        case .details:  return .details
        case .document: return .document
        }
    }
}

extension SberQR.Parameters.Placement {
    
    var buttonPlacement: Payments.Parameter.Placement {
        
        switch self {
        case .bottom: return .bottom
        }
    }
}
