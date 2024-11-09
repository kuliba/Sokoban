//
//  QRBinderView.swift
//  QRNavigationPreview
//
//  Created by Igor Malyarov on 29.10.2024.
//

import RxViewModel
import SwiftUI

struct QRBinderView: View {
    
    let binder: QRDomain.Binder
    
    var body: some View {
        
        RxWrapperView(model: binder.flow) { state, event in
            
            content
                .navigationDestination(
                    destination: state.destination,
                    dismiss: { event(.dismiss) },
                    content: {
                        
                        switch $0 {
                        case let .failure(.sberQR(url)):
                            Text("SberQR Failure with \"\(url.absoluteString)\"")
                            
                        case let .mixedPicker(mixedPicker):
                            MixedPickerView(model: mixedPicker)
                            
                        case let .multiplePicker(multiplePicker):
                            MultiplePickerView(model: multiplePicker)
                            
                        case let .operatorModel(operatorModel):
                            OperatorModelView(model: operatorModel)
                            
                        case let .payments(payments):
                            PaymentsView(model: payments)
                            
                        case let .qrFailure(qrFailure):
                            QRFailureBinderView(binder: qrFailure)
                            
                        case let .servicePicker(servicePicker):
                            ServicePickerView(model: servicePicker)
                        }
                    }
                )
        }
    }
    
    private var content: some View {
        
        ZStack(alignment: .bottom) {
            
            ZStack(alignment: .top) {
                
                Color.clear
                
                QRContentView(model: binder.content)
                    .navigationTitle("QR Scanner")
            }
            
            Button("Cancel* - see print") {
                
                binder.content.close()
                print("dismiss: in the app QRModelWrapper has state case `cancelled` - which should be observed")
            }
            .foregroundColor(.red)
        }
    }
}

extension QRDomain.FlowDomain.State {
    
    var destination: Destination? {
        
        switch navigation {
        case .none, .outside:
            return nil
            
        case let .qrNavigation(qrNavigation):
            switch qrNavigation {
            case let .failure(.sberQR(url)):
                return .failure(.sberQR(url))
                
            case let .mixedPicker(node):
                return .mixedPicker(node.model)
                
            case let .multiplePicker(node):
                return .multiplePicker(node.model)
                
            case let .operatorModel(operatorModel):
                return .operatorModel(operatorModel)
                
            case let .payments(node):
                return .payments(node.model)
                
            case let .qrFailure(node):
                return .qrFailure(node.model)
                
            case let .servicePicker(node):
                return .servicePicker(node.model)
            }
        }
    }
    
    enum Destination {
        
        case failure(Failure)
        case mixedPicker(MixedPicker)
        case multiplePicker(MultiplePicker)
        case operatorModel(OperatorModel)
        case payments(Payments)
        case qrFailure(QRFailureDomain.Binder)
        case servicePicker(ServicePicker)
        
        enum Failure: Equatable {
            
            case sberQR(URL)
        }
    }
}

extension QRDomain.FlowDomain.State.Destination: Identifiable {
    
    var id: ID {
        
        switch self {
        case let .failure(.sberQR(url)):
            return .failure(.sberQR(url))
            
        case let .mixedPicker(mixedPicker):
            return .mixedPicker(.init(mixedPicker))
            
        case let .multiplePicker(multiplePicker):
            return .multiplePicker(.init(multiplePicker))
            
        case let .operatorModel(operatorModel):
            return .operatorModel(.init(operatorModel))
            
        case let .payments(payments):
            return .payments(.init(payments))
            
        case let .qrFailure(qrFailure):
            return .qrFailure(.init(qrFailure))
            
        case let .servicePicker(servicePicker):
            return .servicePicker(.init(servicePicker))
        }
    }
    
    enum ID: Hashable {
        
        case failure(Failure)
        case mixedPicker(ObjectIdentifier)
        case multiplePicker(ObjectIdentifier)
        case operatorModel(ObjectIdentifier)
        case payments(ObjectIdentifier)
        case qrFailure(ObjectIdentifier)
        case servicePicker(ObjectIdentifier)
        
        enum Failure: Hashable {
            
            case sberQR(URL)
        }
    }
}
