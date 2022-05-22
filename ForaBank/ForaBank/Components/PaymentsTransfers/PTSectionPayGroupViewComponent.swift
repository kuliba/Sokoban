//
//  PTSectionPayGroupViewComponent.swift
//  ForaBank
//
//  Created by Dmitry Martynov on 19.05.2022.
//

import SwiftUI
import ScrollViewProxy
import Combine

//MARK: Section ViewModel

extension PTSectionPayGroupView {
    
    class ViewModel: PaymentsTransfersSectionViewModel {
     
        @Published
        var payGroupButtons: [PayGroupButtonVM]

        override var type: PaymentsTransfersSectionType { .payGroup }
        let const = ViewSettingsConst()
        
        struct PayGroupButtonVM: Identifiable {
            var id: String { title }
            
            let title: String
            let image: String
            let action: () -> Void
        }
        
        override init() {
            self.payGroupButtons = Self.payGroupButtonsData
            super.init()
        }
        
        init(payGroupButtons: [PayGroupButtonVM]) {
            self.payGroupButtons = payGroupButtons
            super.init()
        }
        
        static let payGroupButtonsData: [PayGroupButtonVM] = {
            [
            .init(title: "Оплата по QR", image: "ic24BarcodeScanner2", action: {}),
            .init(title: "Мобильная связь", image: "ic24Smartphone", action: {}),
            .init(title: "Услуги ЖКХ", image: "ic24Bulb", action: {}),
            .init(title: "Интернет, ТВ", image: "ic24Tv", action: {}),
            .init(title: "Штрафы", image: "ic24Car", action: {}),
            .init(title: "Госуслуги", image: "ic24Emblem", action: {}),
            .init(title: "Соцсети, игры, карты", image: "ic24Gamepad", action: {}),
            .init(title: "Охранные системы", image: "ic24Key", action: {}),
            .init(title: "Прочее", image: "ic24ShoppingCart", action: {})
            ]
        }()
    }
}

//MARK: Section View

struct PTSectionPayGroupView: View {
    
    @ObservedObject
    var viewModel: ViewModel
    var heightBlock: CGFloat
    
    @State private var rowsCount: Int = UIScreen.main.bounds.height > 890 ? 4 : 3
    @State private var scrollProxy: AmzdScrollViewProxy?
    @State private var scrollOffsetX: CGFloat = 0
    
    private func scrollToRight() {
        let itemIndex = (Int(scrollOffsetX / viewModel.const.pageScrollViewWidth) + 1) * rowsCount
        scrollProxy?.scrollTo(itemIndex, alignment: .leading, animated: true)
    }
    
    var body: some View {
        Text(viewModel.title)
            .frame(maxWidth: .infinity, alignment: .leading)
            .font(.textH2SB20282())
            .foregroundColor(.textSecondary)
            .padding(.top, 30)
            .padding(.bottom, 14)
            .padding(.leading, 20)
      
        HStack {
            ScrollView(.horizontal, showsIndicators: false) { proxy in
                
                HStack(spacing: 64) {
                
                if #available(iOS 14.0, *) {

                    let gridItems = Array(repeating: GridItem(.fixed(48), spacing: 8),
                                          count: rowsCount)

                    LazyHGrid(rows: gridItems, spacing: 64) {
                        ForEach(viewModel.payGroupButtons.indices, id: \.self) { index in

                            ButtonPayGroupView(viewModel: viewModel.payGroupButtons[index])
                                .scrollId(index)
                        }
                    }

                } else {
                
                    let payButtonsCount = viewModel.payGroupButtons.count
                    let columnsCount = (payButtonsCount / rowsCount)
                                     + (payButtonsCount % rowsCount == 0 ? 0 : 1)
                    
                    ForEach(0..<columnsCount, id: \.self) { column in
                        VStack {
                            ForEach(0..<rowsCount, id: \.self) { row in
                                
                                let index = rowsCount * column + row
                                if payButtonsCount > index {
                                    ButtonPayGroupView(viewModel: viewModel.payGroupButtons[index])
                                            .scrollId(index)
                                    
                                } else { Spacer() }
                            }
                        }
                        .onAppear {
                            let scrollHeight = heightBlock - viewModel.const.fixHeightBlok
                            let calcRowsCount = Int(round(10 * scrollHeight) / (10 * viewModel.const.payRowHeight))
                            
                            if calcRowsCount > 3 {
                                rowsCount = calcRowsCount
                            } else {
                                rowsCount = viewModel.const.payRowCountIfZeroHeight
                            }
                        }
                    }
                } //iOS14
                    Spacer(minLength: 1)
                }
                .onReceive(proxy.offset) { scrollOffsetX = $0.x }
                .onAppear { scrollProxy = proxy }

            }
            .frame(width: viewModel.const.pageScrollViewWidth)
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

extension PTSectionPayGroupView {
    
    struct ButtonPayGroupView: View {
        let viewModel: ViewModel.PayGroupButtonVM
        
        var body: some View {
            Button(action: viewModel.action,  label: {
                ZStack(alignment: .leading) {
                    
                    Color.clear.frame(width: 248, height: 48)
                    HStack(spacing: 16) {
                        ZStack {
                            
                            Color.mainColorsGrayLightest
                                .frame(width: 48, height: 48)
                                .cornerRadius(8)
                            
                            Image(viewModel.image)
                                .resizable()
                                .frame(width: 24, height: 24)
                        }
                        Text(viewModel.title).font(.textH4R16240())
                    }
                }.foregroundColor(.textSecondary)
            })
        }
    }
}

//MARK: - Constant

extension PTSectionPayGroupView.ViewModel {
    
    struct ViewSettingsConst { //allSizeWithoutSafeAreaInsets with paddings
        
        let searchViewHeight: CGFloat = 48
        let tabBarHeight: CGFloat = 56
        
        let paymentsBlockHeight: CGFloat = (32 + 32 + 96)
        let transfersBlockHeight: CGFloat = (44 + 24 + 104)
        let payBlockTitleHeight: CGFloat = (44 + 24)
        var fixHeightBlok: CGFloat {
                    paymentsBlockHeight
                  + transfersBlockHeight
                  + payBlockTitleHeight
                  + 45 
        }
        
        let payRowHeight: CGFloat = (48 + 12)
        let pageScrollViewWidth: CGFloat = 312
        let payRowCountIfZeroHeight = 3
        
    }
}

//MARK: - Preview

struct PTSectionPayGroupView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        PTSectionPayGroupView(viewModel: .init(), heightBlock: 100)
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
