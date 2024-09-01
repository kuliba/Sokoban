//
//  PaymentProviderPickerFlowView.swift
//
//
//  Created by Igor Malyarov on 01.09.2024.
//

import PayHub
import SwiftUI

struct PaymentProviderPickerFlowView<ContentView, DestinationView, Latest, PayByInstructions, Payment, Provider, Service, ServicesFailure>: View
where ContentView: View,
      DestinationView: View {
    
    let state: State
    let event: (Event) -> Void
    let contentView: () -> ContentView
    let destinationView: (Destination) -> DestinationView
    
    var body: some View {
        
        contentView()
            .alert(item: serviceFailure, content: alert)
            .navigationDestination(
                destination: destination,
                dismiss: { event(.dismiss) },
                content: destinationView
            )
    }
}

extension PaymentProviderPickerFlowView {
    
    typealias State = PaymentProviderPickerFlowState<PayByInstructions, Payment, Service, ServicesFailure>
#warning("could be improved and use less generics if scope just flow events, for example Latest is not used; and Provider too(?)")
    typealias Event = PaymentProviderPickerFlowEvent<Latest, PayByInstructions, Payment, Provider, Service, ServicesFailure>
    typealias Destination = PaymentProviderPickerFlowDestination<PayByInstructions, Payment, Service, ServicesFailure>
}

private extension PaymentProviderPickerFlowView {
    
    var serviceFailure: ServiceFailure? {
        
        guard case let .alert(serviceFailure) = state.navigation
        else { return nil }
        
        return serviceFailure
    }
    
    var destination: Destination? {
        
        guard case let .destination(destination) = state.navigation
        else { return nil }
        
        return destination
    }
    
    func alert(
        serviceFailure: ServiceFailure
    ) -> Alert {
        
        return serviceFailure.alert { event(.goToPayments) }
    }
}

extension ServiceFailure: Identifiable {
    
    public var id: String { message + String(describing: source) }
}

extension ServiceFailure {
    
    func alert(
        action: @escaping () -> Void
    ) -> SwiftUI.Alert {
        
        return .init(title: Text(title), message: Text(message), dismissButton: .default(Text("OK"), action: action))
    }
    
    private var title: String {
        
        switch source {
        case .connectivity: return ""
        case .server:       return "Ошибка"
        }
    }
}

extension PaymentProviderPickerFlowDestination: Identifiable {
    
    public var id: ID {
        
        switch self {
            
        case .payByInstructions: return .payByInstructions
        case .payment:           return .payment
        case .servicePicker:     return .servicePicker
        case .servicesFailure:   return .servicesFailure
        }
    }
    
    public enum ID: Hashable {
        
        case payByInstructions
        case payment
        case servicePicker
        case servicesFailure
    }
}

// MARK: - Previews

import RxViewModel

struct PaymentProviderPickerFlowView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        flowView(.init())
            .previewDisplayName("")
        flowView(.init(navigation: .alert(.connectivity("Error connecting to server"))))
            .previewDisplayName("connectivity")
        flowView(.init(navigation: .alert(.server("Error connecting to server"))))
            .previewDisplayName("server")
        flowView(.init(navigation: .destination(.payByInstructions(.init()))))
            .previewDisplayName("payByInstructions")
        flowView(.init(navigation: .destination(.payment(.init()))))
            .previewDisplayName("payment")
        flowView(.init(navigation: .destination(.servicePicker(.init()))))
            .previewDisplayName("services list")
        flowView(.init(navigation: .destination(.servicesFailure(.init()))))
            .previewDisplayName("servicesFailure")
        
        flowView(.init(navigation: .outside(.chat))) // can't render
            .previewDisplayName("outside(.chat)")
    }
    
    typealias State = PaymentProviderPickerFlowState<PreviewPayByInstructions, PreviewPayment, PreviewServicePicker, PreviewServicesFailure>
    
    private static func flowView(
        _ state: State
    ) -> some View {
        
        NavigationView {
            
            PaymentProviderPickerFlowView<Color, Text, PreviewLatest, PreviewPayByInstructions, PreviewPayment, PreviewPaymentProvider, PreviewServicePicker, PreviewServicesFailure>(
                state: state,
                event: { print($0) },
                contentView: { Color.green.opacity(0.2) },
                destinationView: { Text("TBD: destination view for \($0)") }
            )
        }
        .navigationViewStyle(.stack)
    }
}

struct PaymentProviderPickerFlowDemoView: View {
    
    @State private var initiatePayment = false
    @State private var servicesResponse: ServicesResponse = .failure
    @State private var destination: Destination?
    
    struct Destination: Identifiable {
        
        let id = UUID()
        let model: Model
        
        typealias Model = PaymentProviderPickerFlow<PreviewLatest, PreviewPayByInstructions, PreviewPayment, PreviewPaymentProvider, PreviewServicePicker, PreviewServicesFailure>
    }
    
    enum ServicesResponse: String, CaseIterable {
        
        case failure, single, list
    }
    
    var body: some View {
        
        NavigationView {
            
            List {
                
                Toggle("Initiate Payment", isOn: $initiatePayment)
                
                Picker("Services Response", selection: $servicesResponse) {
                    
                    ForEach(ServicesResponse.allCases, id: \.self) {
                        
                        Text($0.rawValue)
                    }
                }
                
                Button("Show Destination", action: makeDestination)
                    .foregroundColor(.blue)
                    .font(.headline)
            }
            .onFirstAppear(makeDestination)
            .listStyle(.plain)
            .navigationTitle("Setup and run")
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(
                destination: destination,
                dismiss: { destination = nil },
                content: {
                    
                    RxWrapperView(
                        model: $0.model,
                        makeContentView: { state, event in
                            
                            PaymentProviderPickerFlowView(
                                state: state,
                                event: event,
                                contentView: {
                                    
                                    contentView(state: state, event: event)
                                },
                                destinationView: {
                                    
                                    Text("TBD: destination view for \($0)")
                                        .padding()
                                }
                            )
                        }
                    )
                }
            )
        }
        .navigationViewStyle(.stack)
    }
    
    private func makeDestination() {
        
        let reducer = PaymentProviderPickerFlowReducer<PreviewLatest, PreviewPayByInstructions, PreviewPayment, PreviewPaymentProvider, PreviewServicePicker, PreviewServicesFailure>()
        let effectHandler = PaymentProviderPickerFlowEffectHandler<PreviewLatest, PreviewPayByInstructions, PreviewPayment, PreviewPaymentProvider, PreviewServicePicker, PreviewServicesFailure>(microServices: .init(
            initiatePayment: { _, completion in
                
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
                    
                    completion(initiatePayment ? .success(.init()) : .failure(.server("Error initiating payment")))
                }
            },
            makePayByInstructions: { $0(.init()) },
            processProvider: { _, completion in
                
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
                    
                    switch servicesResponse {
                    case .failure:
                        completion(.servicesResult(.servicesFailure(.init())))
                        
                    case .single:
                        completion(initiatePayment ? .initiatePaymentResult(.success(.init())) : .initiatePaymentResult(.failure(.server("Error initiating payment"))))
                        
                    case .list:
                        completion(.servicesResult(.servicePicker(.init())))
                    }
                }
            }
        ))
        
        destination = .init(model: .init(
            initialState: .init(),
            reduce: reducer.reduce(_:_:),
            handleEffect: effectHandler.handleEffect(_:_:)
        ))
    }
    
    private typealias FlowState = PaymentProviderPickerFlowState<PreviewPayByInstructions, PreviewPayment, PreviewServicePicker, PreviewServicesFailure>
    private typealias Event = PaymentProviderPickerFlowEvent<PreviewLatest, PreviewPayByInstructions, PreviewPayment, PreviewPaymentProvider, PreviewServicePicker, PreviewServicesFailure>
    
    private func contentView(
        state: FlowState,
        event: @escaping (Event) -> Void
    ) -> some View {
        
        List {
            
            switch state.navigation {
            case let .outside(outside):
                Section {
                    Text(String(describing: outside))
                        .font(.title3.bold())
                        .foregroundColor(.pink)
                } header: {
                    Text("State - Outside")
                }
            default:
                EmptyView()
            }
            
            Section {
                
                Button("failure") {
                    
                    event(.initiatePaymentResult(.failure(.server("Error initiating payment failure"))))
                }
                .foregroundColor(.red)
                
                Button("success") {
                    
                    event(.initiatePaymentResult(.success(.init())))
                }
            } header: {
                Text("Initiate Payment")
            }
            
            Section {
                
                Button("failure") {
                    
                    event(.loadServices(.servicesFailure(.init())))
                }
                .foregroundColor(.red)
                
                Button("multi") {
                    
                    event(.loadServices(.servicePicker(.init())))
                }
            } header: {
                Text("Load Services")
            }
            
            Section {
                
                Button("Pay by Instructions") {
                    
                    event(.payByInstructions(.init()))
                }
            } header: {
                Text("Pay by Instructions")
            }
            
            Section {
                
                Button("back") {
                    
                    event(.select(.back))
                }
                
                Button("chat") {
                    
                    event(.select(.chat))
                }
                
                Button("latest") {
                    
                    event(.select(.latest(.preview())))
                }
                
                Button("payByInstructions") {
                    
                    event(.select(.payByInstructions))
                }
                
                Button("provider") {
                    
                    event(.select(.provider(.init())))
                }
                
                Button("qr") {
                    
                    event(.select(.qr))
                }
            } header: {
                Text("Select")
            }
        }
    }
}

struct PreviewPayByInstructions {}
struct PreviewPayment {}
struct PreviewPaymentProvider {}
struct PreviewService {}
struct PreviewServicePicker {}
struct PreviewServicesFailure {}

#Preview {
    PaymentProviderPickerFlowDemoView()
}
