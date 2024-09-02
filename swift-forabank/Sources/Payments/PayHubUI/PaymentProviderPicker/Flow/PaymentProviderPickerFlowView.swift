//
//  PaymentProviderPickerFlowView.swift
//
//
//  Created by Igor Malyarov on 01.09.2024.
//

import PayHub
import SwiftUI

struct PaymentProviderPickerFlowView<ContentView, DestinationView, DetailPayment, Latest, Payment, Provider, Service, ServicesFailure>: View
where ContentView: View,
      DestinationView: View {
    
    let state: State
    let event: (Event) -> Void
    let contentView: () -> ContentView
    let destinationView: (Destination) -> DestinationView
    
    var body: some View {
        
        contentView()
            .alert(item: backendFailure, content: alert)
            .navigationDestination(
                destination: destination,
                dismiss: { event(.dismiss) },
                content: destinationView
            )
    }
}

extension PaymentProviderPickerFlowView {
    
    typealias State = PaymentProviderPickerFlowState<Destination>
#warning("could be improved and use less generics if scope just flow events, for example Latest is not used; and Provider too(?)")
    typealias Event = PaymentProviderPickerFlowEvent<Destination, Latest, Provider>
    typealias Destination = PaymentProviderPickerDestination<DetailPayment, Payment, Service, ServicesFailure>
}

private extension PaymentProviderPickerFlowView {
    
    var backendFailure: BackendFailure? {
        
        guard case let .alert(backendFailure) = state.navigation
        else { return nil }
        
        return backendFailure
    }
    
    var destination: Destination? {
        
        guard case let .destination(destination) = state.navigation
        else { return nil }
        
        return destination
    }
    
    func alert(
        backendFailure: BackendFailure
    ) -> Alert {
        
        return backendFailure.alert { event(.goToPayments) }
    }
}

extension BackendFailure: Identifiable {
    
    public var id: String { message + String(describing: source) }
}

extension BackendFailure {
    
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

extension PaymentProviderPickerDestination: Identifiable {
    
    public var id: ID {
        
        switch self {
            
        case .backendFailure:  return .backendFailure
        case .detailPayment:   return .detailPayment
        case .payment:         return .payment
        case .servicePicker:   return .servicePicker
        case .servicesFailure: return .servicesFailure
        }
    }
    
    public enum ID: Hashable {
        
        case backendFailure
        case detailPayment
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
        flowView(.init(navigation: .destination(.detailPayment(.init()))))
            .previewDisplayName("detailPayment")
        flowView(.init(navigation: .destination(.payment(.init()))))
            .previewDisplayName("payment")
        flowView(.init(navigation: .destination(.servicePicker(.init()))))
            .previewDisplayName("services list")
        flowView(.init(navigation: .destination(.servicesFailure(.init()))))
            .previewDisplayName("servicesFailure")
        
        flowView(.init(navigation: .outside(.chat))) // can't render
            .previewDisplayName("outside(.chat)")
    }
    
    typealias State = PaymentProviderPickerFlowState<PaymentProviderPickerDestination<PreviewDetailPayment, PreviewPayment, PreviewServicePicker, PreviewServicesFailure>>
    
    private static func flowView(
        _ state: State
    ) -> some View {
        
        NavigationView {
            
            PaymentProviderPickerFlowView<Color, Text, PreviewDetailPayment, PreviewLatest, PreviewPayment, PreviewPaymentProvider, PreviewServicePicker, PreviewServicesFailure>(
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
        
        typealias Model = PaymentProviderPickerFlow<PreviewDetailPayment, PreviewLatest, PreviewPayment, PreviewPaymentProvider, PreviewService, PreviewServicePicker, PreviewServicesFailure>
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
        
        let reducer = PaymentProviderPickerFlowReducer<PreviewDestination, PreviewLatest, PreviewPaymentProvider>()
        let effectHandler = PaymentProviderPickerFlowEffectHandler<PreviewDestination, PreviewLatest, PreviewPaymentProvider>(microServices: .init(
            initiatePayment: { _, completion in
                
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
                    
                    completion(initiatePayment ? .payment(.init()) : .backendFailure(.server("Error initiating payment")))
                }
            },
            makeDetailPayment: { $0(.detailPayment(.init())) },
            processProvider: { _, completion in
                
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
                    
                    switch servicesResponse {
                    case .failure:
                        completion(.servicesFailure(.init()))
                        
                    case .single:
                        completion(initiatePayment ? .payment(.init()) : .backendFailure(.server("Error initiating payment")))
                        
                    case .list:
                        completion(.servicePicker(.init()))
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
    
    private typealias PreviewDestination = PaymentProviderPickerDestination<PreviewDetailPayment, PreviewPayment, PreviewServicePicker, PreviewServicesFailure>
    private typealias FlowState = PaymentProviderPickerFlowState<PreviewDestination>
    private typealias Event = PaymentProviderPickerFlowEvent<PreviewDestination, PreviewLatest, PreviewPaymentProvider>
    
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
                    
                    event(.alert(.server("Error initiating payment failure")))
                }
                .foregroundColor(.red)
                
                Button("success") {
                    
                    event(.destination(.payment(.init())))
                }
            } header: {
                Text("Initiate Payment")
            }
            
            Section {
                
                Button("failure") {
                    
                    event(.destination(.servicesFailure(.init())))
                }
                .foregroundColor(.red)
                
                Button("multi") {
                    
                    event(.destination(.servicePicker(.init())))
                }
            } header: {
                Text("Load Services")
            }
            
            Section {
                
                Button("Pay by Instructions") {
                    
                    event(.destination(.detailPayment(.init())))
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
                
                Button("detailPayment") {
                    
                    event(.select(.detailPayment))
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

struct PreviewDetailPayment {}
struct PreviewPayment {}
struct PreviewPaymentProvider {}
struct PreviewService {}
struct PreviewServicePicker {}
struct PreviewServicesFailure {}

#Preview {
    PaymentProviderPickerFlowDemoView()
}
