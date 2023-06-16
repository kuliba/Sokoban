//
//  TransportPaymentsView.swift
//  ForaBank
//
//  Created by Igor Malyarov on 15.06.2023.
//

import SwiftUI

struct TransportPaymentsView: View {
    
    @ObservedObject private var viewModel: TransportPaymentsViewModel
    
    init(viewModel: TransportPaymentsViewModel) {
        
        self.viewModel = viewModel
    }
    
    var body: some View {
        
        ScrollView {
            
            VStack(alignment: .leading, spacing: 0) {
                
                LatestPaymentsView(for: viewModel.latestPayments)
                
                OperatorsView(for: viewModel.viewOperators)
                    .frame(maxHeight: .infinity, alignment: .top)
            }
        }
        .padding(.top, 20)
        .background(navigationLink)
        .navigationBar(with: viewModel.navigationBar)
    }
    
    private var navigationLink: some View {
        
        NavigationLink("Destination", isActive: isActive) {
            
            destination(link: viewModel.link)
        }
        .opacity(0)
        .frame(height: 0)
    }
    
    private var isActive: Binding<Bool> {
        .init(
            get: { viewModel.link != nil },
            set: viewModel.setLink(to:)
        )
    }
    
    @ViewBuilder
    private func destination(
        link: TransportPaymentsViewModel.Link?
    ) -> some View {
        
        switch link {
        case .none:
            EmptyView()
            
        case let .avtodor(action):
            AvtodorCrutchView(viewModel: .init(), action: action)
                .navigationBarTitle("Автодор Платные дороги", displayMode: .inline)
            //.navigationBarHidden(true)
            
        case .payments(let viewModel):
            PaymentsView(viewModel: viewModel)
                .navigationBarHidden(true)
        }
    }
}

// MARK: - Views

extension TransportPaymentsView {
    
    struct LatestPaymentsView: View {
        
        private let latestPayments: PaymentsServicesLatestPaymentsSectionViewModel
        
        init(for latestPayments: PaymentsServicesLatestPaymentsSectionViewModel) {
            
            self.latestPayments = latestPayments
        }
        
        var body: some View {
            
            VStack {
                
                if !latestPayments.latestPayments.items.isEmpty {
                    
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
                    // to help Xcode preview
                    content: TransportPaymentsView.OperatorItemView.init(viewModel:)
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
            
            TransportPaymentsView(viewModel: .preview)
                .previewDisplayName("TransportPaymentsView")
            
            Group {
                TransportPaymentsView.LatestPaymentsView(
                    for: TransportPaymentsViewModel.preview.latestPayments
                )
                TransportPaymentsView.LatestPaymentsView(for: .sample)
            }
            .previewDisplayName("LatestPaymentsView")
            
            Group {
                TransportPaymentsView.OperatorsView(
                    for: TransportPaymentsViewModel.preview.viewOperators
                )
                TransportPaymentsView.OperatorsView(for: .preview)
            }
            .previewDisplayName("OperatorsView")
            
            List {
                TransportPaymentsView.OperatorItemView(viewModel: .noINN)
                TransportPaymentsView.OperatorItemView(viewModel: .withINN)
            }
            .listStyle(.plain)
            .previewDisplayName("OperatorItemView")
        }
    }
}

// MARK: - Preview Content

private extension TransportPaymentsViewModel {
    
    static let preview: TransportPaymentsViewModel = .init(
        operators: .preview,
        latestPayments: .sample,
        navigationBar: .init(title: "Transport"),
        makePaymentsViewModel: {
            .init(
                source: $0,
                model: .emptyMock,
                closeAction: {}
            )
        }
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
