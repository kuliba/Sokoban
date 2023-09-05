//
//  TransportPaymentsView.swift
//  ForaBank
//
//  Created by Igor Malyarov on 15.06.2023.
//

import CvvPin
import SwiftUI

struct TransportPaymentsView<MosParkingView: View, ExtraView: View>: View {
    
    @ObservedObject private var viewModel: TransportPaymentsViewModel
    
    private let mosParkingView: () -> MosParkingView
    private let extraView: () -> ExtraView
    
    init(
        viewModel: TransportPaymentsViewModel,
        mosParkingView: @escaping () -> MosParkingView,
        extraView: @escaping () -> ExtraView
    ) {
        self.viewModel = viewModel
        self.mosParkingView = mosParkingView
        self.extraView = extraView
    }
    
    var body: some View {
        
        ScrollView {
            
            VStack(alignment: .leading, spacing: 0) {
                
                Transport.LatestPaymentsView(for: viewModel.latestPayments)
                
                extraView()
                
                Transport.OperatorsView(for: viewModel.viewOperators)
                    .frame(maxHeight: .infinity, alignment: .top)
            }
        }
        .padding(.top, 20)
        .background(navigationLink)
    }
    
    private var navigationLink: some View {
        
        /// - Note: `init(_ titleKey: LocalizedStringKey, isActive: Binding<Bool>, @ViewBuilder destination: () -> Destination)` is not the best API to use since it allows an impossible case where `viewModel.destination` is nil
        NavigationLink("Destination", isActive: isActive) {
            
            switch viewModel.destination {
            case .none:
                EmptyView()
                
            case .mosParking:
                mosParkingView()
                
            case let .payment(viewModel):
                PaymentsView(viewModel: viewModel)
                    .navigationBarHidden(true)
            }
        }
        .opacity(0)
        .frame(height: 0)
    }
    
    private var isActive: Binding<Bool> {
        .init(
            get: { viewModel.destination != nil },
            set: viewModel.setDestination(to:)
        )
    }
}

// MARK: - Views

enum Transport {}

extension Transport {
    
    struct LatestPaymentsView: View {
        
        private let latestPayments: PaymentsServicesLatestPaymentsSectionViewModel
        
        init(for latestPayments: PaymentsServicesLatestPaymentsSectionViewModel) {
            
            self.latestPayments = latestPayments
        }
        
        var body: some View {
            
            if !latestPayments.latestPayments.items.isEmpty {
                
                VStack(spacing: 0) {
                    
                    PaymentsServicesLatestPaymentsSectionView(
                        viewModel: latestPayments,
                        iconSize: 40
                    )
                    
                    Divider()
                        .foregroundColor(Color.bordersDivider)
                        .frame(height: 1)
                        .frame(height: 32)
                }
            }
        }
    }
    
    struct OperatorsView: View {
        
        private let viewOperators: [TransportPaymentsViewModel.ItemViewModel]
        
        init(for viewOperators: [TransportPaymentsViewModel.ItemViewModel]) {
            
            self.viewOperators = viewOperators
        }
        
        var body: some View {
            
            VStack(alignment: .leading, spacing: 0) {
                
                ForEach(
                    viewOperators,
                    content: Transport.OperatorItemView.init(viewModel:)
                )
            }
        }
    }
    
    struct OperatorItemView: View {
        
        typealias ViewModel = TransportPaymentsViewModel.ItemViewModel
        
        private let viewModel: ViewModel
        
        init(viewModel: ViewModel) {
            
            self.viewModel = viewModel
        }
        
        var body: some View {
            
            Button {
                viewModel.select(viewModel.id)
            } label: {
                HStack(alignment: .center, spacing: 20) {
                    
                    icon()
                    label()
                    Spacer()
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
        
        @ViewBuilder
        private func icon() -> some View {
            
            if let icon = viewModel.icon {
                
                icon
                    .resizable()
                    .frame(width: 40, height: 40)
                    .cornerRadius(90)
                
            } else {
                
                Circle()
                    .foregroundColor(.mainColorsGrayLightest)
                    .frame(width: 40, height: 40)
            }
        }
        
        private func label() -> some View {
            
            VStack(alignment: .leading, spacing: 4) {
                
                Text(viewModel.name)
                    .foregroundColor(Color.textSecondary)
                    .lineLimit(1)
                    .font(.textH4M16240())
                
                if let inn = viewModel.inn,
                   !inn.isEmpty {
                    
                    Text(inn)
                        .foregroundColor(Color.textPlaceholder)
                        .lineLimit(1)
                        .font(.textBodyMR14180())
                }
            }
        }
    }
}

// MARK: - Preview

struct TransportPaymentsView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        Group {
            
            transportPaymentsView(viewModel: .preview)
                .previewDisplayName("TransportPaymentsView")
            
            Group {
                Transport.LatestPaymentsView(
                    for: TransportPaymentsViewModel.preview.latestPayments
                )
                Transport.LatestPaymentsView(for: .sample)
            }
            .previewDisplayName("LatestPaymentsView")
            
            Group {
                Transport.OperatorsView(
                    for: TransportPaymentsViewModel.preview.viewOperators
                )
                Transport.OperatorsView(for: .preview)
            }
            .previewDisplayName("OperatorsView")
            
            List {
                Transport.OperatorItemView(viewModel: .noINN)
                Transport.OperatorItemView(viewModel: .withINN)
            }
            .listStyle(.plain)
            .previewDisplayName("OperatorItemView")
        }
    }
    
    private static func transportPaymentsView(
        viewModel: TransportPaymentsViewModel
    ) -> some View {
        
        TransportPaymentsView(viewModel: viewModel) {
            
            Text("MosParkingView")
            
        } extraView: {
            
            Text("This is Extra View")
                .padding()
                .background(Color.blue.opacity(0.2))
                .padding()
        }
    }
}

// MARK: - Preview Content

private extension TransportPaymentsViewModel {
    
    static let preview: TransportPaymentsViewModel = .init(
        cvvPinService: unimplemented(),
        operators: .preview,
        latestPayments: .sample,
        makePaymentsViewModel: {
            .init(
                source: $0,
                model: .emptyMock,
                closeAction: {}
            )
        },
        handleError: { _ in }
    )
}

private extension Array where Element == TransportPaymentsViewModel.ItemViewModel {
    
    static let preview: Self = [.noINN, .withINN]
}

private extension TransportPaymentsViewModel.ItemViewModel {
    
    static let noINN: TransportPaymentsViewModel.ItemViewModel = .init(
        id: "0",
        icon: .init(.ic40Transport),
        name: "Preview",
        inn: nil,
        select: { _ in }
    )
    
    static let withINN: TransportPaymentsViewModel.ItemViewModel = .init(
        id: "1",
        icon: .init(.ic40Transport),
        name: "Preview",
        inn: "123456789",
        select: { _ in }
    )
}

private extension Array where Element == OperatorGroupData.OperatorData {
    
    static let preview: Self = [.gibdd]
}

private extension OperatorGroupData.OperatorData {
    
    static let gibdd: Self = .init(
        city: nil,
        code: Purefs.iForaGibdd,
        isGroup: true,
        logotypeList: [],
        name: "Transport",
        parameterList: [
            .init(content: nil, dataType: nil, id: "", isPrint: nil, isRequired: nil, mask: nil, maxLength: nil, minLength: nil, order: nil, rawLength: 1, readOnly: nil, regExp: nil, subTitle: nil, title: "", type: nil, inputFieldType: nil, dataDictionary: nil, dataDictionaryРarent: nil, group: nil, subGroup: nil, inputMask: nil, phoneBook: nil, svgImage: nil, viewType: .input)
        ],
        parentCode: Purefs.transport,
        region: nil,
        synonymList: []
    )
}

// MARK: - CvvPinFlowDemoView

struct CvvPinFlowDemoView: View {
    
    @State private var flowState: FlowState?
    
    enum FlowState: Equatable {
        
        case error(String)
        case loading
        case flowStartedOK
        case otpOK
    }
    
    typealias StartCvvPinFlowCompletion = (Result<Void, Error>) -> Void
    typealias StartCvvPinFlow = (@escaping StartCvvPinFlowCompletion) -> Void
    
    typealias SubmitOTPResult = Result<Void, Error>
    typealias SubmitOTPCompletion = (SubmitOTPResult) -> Void
    typealias SubmitOTP = (String, @escaping SubmitOTPCompletion) -> Void
    
    private let startCvvPinFlow: StartCvvPinFlow
    private let submitOTP: SubmitOTP
    
    init(
        startCvvPinFlow: @escaping StartCvvPinFlow,
        submitOTP: @escaping SubmitOTP
    ) {
        self.startCvvPinFlow = startCvvPinFlow
        self.submitOTP = submitOTP
    }
    
    var body: some View {
        
        VStack {
            
            startCvvPinFlowButton()
            
            if case .flowStartedOK = flowState {
                
                OTPView(submitOTP: sendOTP)
            }
        }
        .animation(.easeInOut, value: flowState)
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.blue.opacity(0.04))
    }
    
    private func startCvvPinFlowButton() -> some View {
        
        Button(
            action: startCvvPinFlowButtonAction,
            label: startCvvPinFlowButtonLabel
        )
        .foregroundColor(.blue)
        .disabled(isStartCvvPinFlowButtonDisabled())
    }
    
    private func startCvvPinFlowButtonAction() {
        
        flowState = .loading
        
        startCvvPinFlow { result in
            
            switch result {
            case let .failure(error):
                self.flowState = .error(error.localizedDescription)
                
            case let .success(keyExchange):
                dump(keyExchange)
                self.flowState = .flowStartedOK
            }
        }
    }
    
    @ViewBuilder
    private func startCvvPinFlowButtonLabel() -> some View {
        
        switch flowState {
        case let .error(error):
            Text(error)
                .foregroundColor(.red)
                .font(.caption)
            
        case .loading:
            ProgressView("Starting CVV-PIN FLow...")
                .foregroundColor(.gray)
                .font(.caption)
            
        case .none:
            Text("Start CVV-PIN FLow")
            
        case .flowStartedOK:
            Text("CVV-PIN FLow Started OK. Wait for OTP")
                .foregroundColor(.green)
            
        case .otpOK:
            Text("Key exchange confirmed")
                .foregroundColor(.green)
        }
    }
    
    private func isStartCvvPinFlowButtonDisabled() -> Bool {
        
        switch flowState {
        case .none, .error, .otpOK:
            return false
        case .loading, .flowStartedOK:
            return true
        }
    }
    
    private func sendOTP(string: String) {
        
        flowState = .loading
        
        submitOTP(string) { result in
            
            switch result {
            case let .failure(error):
                flowState = .error(error.localizedDescription)
                
            case .success:
                flowState = .otpOK
            }
        }
    }
}

private struct OTPView: View {
    
    @State private var otpString = ""
    
    typealias SubmitOTP = (String) -> Void

    let submitOTP: SubmitOTP
    
    var body: some View {
        
        HStack {
            
            TextField("OTP", text: $otpString)
            
            Button("Submit") {
                
                submitOTP(otpString)
                otpString = ""
            }
            .disabled(otpString.isEmpty)
            .accentColor(.blue)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 22)
                .stroke()
                .foregroundColor(.gray.opacity(0.5))
        )
    }
}

struct CvvPinFlowDemoView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        CvvPinFlowDemoView(
            startCvvPinFlow: { _ in },
            submitOTP: { _,_  in }
        )
    }
}
