//
//  PaymentProviderPickerFlowView.swift
//
//
//  Created by Igor Malyarov on 01.09.2024.
//

import PayHub
import SwiftUI

struct PaymentProviderPickerFlowView<ContentView, DestinationView, Latest, PayByInstructions, Payment, Provider, Service>: View
where ContentView: View,
      DestinationView: View {
    
    let state: State
    let event: (Event) -> Void
    let contentView: () -> ContentView
    let destinationView: (Destination) -> DestinationView
    
    var body: some View {
        
#warning("fix alert!")
        contentView()
        //.alert(item: <#T##Identifiable?#>, content: <#T##(Identifiable) -> Alert#>)
            .navigationDestination(
                destination: destination,
                dismiss: { event(.dismiss) },
                content: destinationView
            )
    }
}

extension PaymentProviderPickerFlowView {
    
    typealias State = PaymentProviderPickerFlowState<PayByInstructions, Payment, Service>
#warning("could be improved and use less generics if scope just flow events, for example Latest is not used; and Provider too(?)")
    typealias Event = PaymentProviderPickerFlowEvent<Latest, Payment, PayByInstructions, Provider, Service>
    typealias Destination = PaymentProviderPickerFlowDestination<PayByInstructions, Payment, Service>
}

private extension PaymentProviderPickerFlowView {
    
    var destination: Destination? {
        
        guard case let .destination(destination) = state.navigation
        else { return nil }
        
        return destination
    }
}

extension PaymentProviderPickerFlowDestination: Identifiable {
    
    public var id: ID {
        
        switch self {
            
        case .payByInstructions: return .payByInstructions
        case .payment:           return .payment
        case .services:          return .services
        case .servicesFailure:   return .servicesFailure
        }
    }
    
    public enum ID: Hashable {
        
        case payByInstructions
        case payment
        case services
        case servicesFailure
    }
}

// MARK: - Previews

import RxViewModel

struct PaymentProviderPickerFlowView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        flowView(.init())
    }
    
    typealias State = PaymentProviderPickerFlowState<PreviewPayByInstructions, PreviewPayment, PreviewService>
    
    private static func flowView(
        _ state: State
    ) -> some View {
        
        NavigationView {
            
            PaymentProviderPickerFlowView<Color, Text, PreviewLatest, PreviewPayByInstructions, PreviewPayment, PreviewPaymentProvider, PreviewService>(
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
        
        typealias Model = PaymentProviderPickerFlow<PreviewLatest, PreviewPayByInstructions, PreviewPayment, PreviewPaymentProvider, PreviewService>
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
                    
                    let model = $0.model
                    
                    RxWrapperView(
                        model: model,
                        makeContentView: {
                            
                            PaymentProviderPickerFlowView(
                                state: $0,
                                event: $1,
                                contentView: { contentView(event: model.event) },
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
        
        let reducer = PaymentProviderPickerFlowReducer<PreviewLatest, PreviewPayment, PreviewPayByInstructions, PreviewPaymentProvider, PreviewService>()
        let effectHandler = PaymentProviderPickerFlowEffectHandler<PreviewLatest, PreviewPayment, PreviewPayByInstructions, PreviewPaymentProvider, PreviewService>(microServices: .init(
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
                        completion(.servicesFailure)
                        
                    case .single:
                        completion(initiatePayment ? .initiatePaymentResult(.success(.init())) : .initiatePaymentResult(.failure(.server("Error initiating payment"))))
                        
                    case .list:
                        completion(.services(.init(.init(), .init())))
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
    
    private typealias Event = PaymentProviderPickerFlowEvent<PreviewLatest, PreviewPayment, PreviewPayByInstructions, PreviewPaymentProvider, PreviewService>
    
    private func contentView(
        event: @escaping (Event) -> Void
    ) -> some View {
        
        List {
            
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
                    
                    event(.loadServices(nil))
                }
                .foregroundColor(.red)
                
                Button("multi") {
                    
                    event(.loadServices(.init(.init(), .init())))
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

#Preview {
    PaymentProviderPickerFlowDemoView()
}
