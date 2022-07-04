//
//  PTSectionPaymentsViewComponent.swift
//  ForaBank
//
//  Created by Dmitry Martynov on 19.05.2022.
//

import SwiftUI
import ScrollViewProxy
import Combine

//MARK: Section ViewModel

extension PTSectionPaymentsView {
    
    class ViewModel: PaymentsTransfersSectionViewModel {
        
        @Published
        var paymentButtons: [PaymentButtonVM]

        override var type: PaymentsTransfersSectionType { .payments }
        
        struct PaymentButtonVM: Identifiable {
            var id: String { type.rawValue }
            
            let type: PaymentsType
            let action: () -> Void
        }
        
        static let allowedButtonsTypes: Set<PaymentsType> = [
            .qrPayment, .mobile, .service, .internet, .transport, .taxAndStateService
        ]
        
        override init() {
            self.paymentButtons = []
            super.init()
            self.paymentButtons = PaymentsType.allCases
                .filter { Self.allowedButtonsTypes.contains($0) }
                .map { item in PaymentButtonVM(type: item,
                                       action: { self.action.send(PTSectionPaymentsViewAction
                                                                    .ButtonTapped
                                                                    .Payment(type: item)) })
            }
        }
        
        init(paymentButtons: [PaymentButtonVM]) {
            self.paymentButtons = paymentButtons
            super.init()
        }
        
        enum PaymentsType: String, CaseIterable {
            case qrPayment, mobile, service, internet,
                 transport, taxAndStateService, socialAndGame, security, others
            
            var apearance: (title: String, imageName: String) {
                switch self {
                case .qrPayment: return (title: "Оплата по QR", imageName: "ic24BarcodeScanner2")
                case .mobile: return (title: "Мобильная связь", imageName: "ic24Smartphone")
                case .service: return (title: "Услуги ЖКХ", imageName: "ic24Bulb")
                case .internet: return (title: "Интернет, ТВ", imageName: "ic24Tv")
                case .transport: return (title: "Транспорт", imageName: "ic24Car")
                case .taxAndStateService: return (title: "Налоги и госуслуги", imageName: "ic24Emblem")
                case .socialAndGame: return (title: "Соцсети, игры, карты", imageName: "ic24Gamepad")
                case .security: return (title: "Охранные системы", imageName: "ic24Key")
                case .others: return (title: "Прочее", imageName: "ic24ShoppingCart")
                }
            }
        }
        
    }
}

//MARK: Section View

struct PTSectionPaymentsView: View {
    
    @ObservedObject
    var viewModel: ViewModel
    let pageScrollViewWidth: CGFloat = 312
    let rowsCount: Int = UIScreen.main.bounds.height > 890 ? 4 : 3
    
    @State private var scrollProxy: AmzdScrollViewProxy?
    @State private var scrollOffsetX: CGFloat = 0
    
    private func scrollToRight() {
        let itemIndex = (Int(scrollOffsetX / pageScrollViewWidth) + 1) * rowsCount
        scrollProxy?.scrollTo(itemIndex, alignment: .leading, animated: true)
    }
    
    var body: some View {
        Text(viewModel.title)
            .frame(maxWidth: .infinity, alignment: .leading)
            .font(.textH2SB20282())
            .foregroundColor(.textSecondary)
            .padding(.top, 4)
            .padding(.bottom, 14)
            .padding(.leading, 20)
      
        HStack {
            ScrollView(.horizontal, showsIndicators: false) { proxy in
                
                HStack(spacing: 64) {
                
                if #available(iOS 14.0, *) {

                    let gridItems = Array(repeating: GridItem(.fixed(48), spacing: 8),
                                          count: rowsCount)

                    LazyHGrid(rows: gridItems, spacing: 64) {
                        ForEach(viewModel.paymentButtons.indices, id: \.self) { index in

                            ButtonPayGroupView(viewModel: viewModel.paymentButtons[index])
                                                                    .scrollId(index)
                        }
                    }

                } else { //iOS13
                
                    let payButtonsCount = viewModel.paymentButtons.count
                    let columnsCount = (payButtonsCount / rowsCount)
                                     + (payButtonsCount % rowsCount == 0 ? 0 : 1)
                    
                    ForEach(0..<columnsCount, id: \.self) { column in
                        VStack {
                            ForEach(0..<rowsCount, id: \.self) { row in
                                
                                let index = rowsCount * column + row
                                if payButtonsCount > index {
                                    ButtonPayGroupView(viewModel: viewModel.paymentButtons[index])
                                                                            .scrollId(index)
                                    
                                } else { Spacer() }
                            }
                        }
                    }
                } //iOS14
                    Spacer(minLength: 1)
                }
                .onReceive(proxy.offset) { scrollOffsetX = $0.x }
                .onAppear { scrollProxy = proxy }

            }
            .frame(width: pageScrollViewWidth)
            .introspectScrollView {
                $0.isPagingEnabled = true
                $0.clipsToBounds = false
            }
        
            Color.clear
                .contentShape(Rectangle())
                .gesture(DragGesture().onEnded { _ in scrollToRight() })
                .onTapGesture { scrollToRight() }
            
        }.padding(.leading, 20)
    }
    
}

//MARK: - ButtonPayGroupView

extension PTSectionPaymentsView {
    
    struct ButtonPayGroupView: View {
        let viewModel: ViewModel.PaymentButtonVM
        
        var body: some View {
            Button(action: viewModel.action,  label: {
                ZStack(alignment: .leading) {
                    
                    Color.clear.frame(width: 248, height: 48)
                    HStack(spacing: 16) {
                        ZStack {
                            
                            Color.mainColorsGrayLightest
                                .frame(width: 48, height: 48)
                                .cornerRadius(8)
                            
                            Image(viewModel.type.apearance.imageName)
                                .resizable()
                                .frame(width: 24, height: 24)
                        }
                        Text(viewModel.type.apearance.title).font(.textH4R16240())
                    }
                }.foregroundColor(.textSecondary)
            })
        }
    }
}

//MARK: - Action PTSectionPaymentsViewAction

enum PTSectionPaymentsViewAction {

    enum ButtonTapped {

        struct Payment: Action {

            let type: PTSectionPaymentsView.ViewModel.PaymentsType
        }
    }
}

//MARK: - Preview

struct PTSectionPayGroupView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        PTSectionPaymentsView(viewModel: .init())
            .previewLayout(.fixed(width: 410, height: 280))
            .previewDisplayName("Section PayGroup")
    }
}

//MARK: - Extention View

@available(iOS, deprecated: 15.0, message: "Use the built-in APIs instead")
extension View {
    
    func background13<T: View>(alignment: Alignment = .center,
                               @ViewBuilder content: () -> T) -> some View {
        
        background(Group(content: content), alignment: alignment)
    }
    
    func overlay13<T: View>(alignment: Alignment = .center,
                            @ViewBuilder content: () -> T) -> some View {
        
        overlay(Group(content: content), alignment: alignment)
    }
}
