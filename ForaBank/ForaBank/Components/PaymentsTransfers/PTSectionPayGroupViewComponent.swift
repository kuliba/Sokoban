//
//  PTSectionPayGroupViewComponent.swift
//  ForaBank
//
//  Created by Dmitry Martynov on 19.05.2022.
//

import SwiftUI
import Introspect

//MARK: Section ViewModel

extension PTSectionPayGroupView {
    
    class SectionViewModel: PaymentsTransfersSectionViewModel {
     
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
    var viewModel: SectionViewModel
    @State private var rowsCount: Int = 3
    var heightBlock: CGFloat
    
    var body: some View {
        Text(viewModel.title)
            .frame(maxWidth: .infinity, alignment: .leading)
            .font(.textH2SB20282())
            .foregroundColor(.textSecondary)
            .padding(.top, 30)
            .padding(.bottom, 14)
            .padding(.leading, 20)
      
        HStack {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 64) {
                
                    let PayButtonsCount = viewModel.payGroupButtons.count
                    let columnsCount = (PayButtonsCount / rowsCount)
                                     + (PayButtonsCount % rowsCount == 0 ? 0 : 1)
                    
                    ForEach(0..<columnsCount, id: \.self) { column in
                        VStack {
                            ForEach(0..<rowsCount, id: \.self) { row in
                              
                                if PayButtonsCount > (rowsCount * column + row) {
                                    ButtonPayGroupView(viewModel:
                                        viewModel.payGroupButtons[rowsCount * column + row])
                                } else { Spacer() }
                            }
                        }
                    }
                    Spacer(minLength: 1)
                }
            }
            .frame(width: viewModel.const.pageScrollViewWidth)
            .introspectScrollView {
                $0.isPagingEnabled = true
                $0.clipsToBounds = false
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
            Spacer()
        }.padding(.leading, 20)
    }
    
}

//MARK: - ButtonPayGroupView

extension PTSectionPayGroupView {
    
    struct ButtonPayGroupView: View {
        let viewModel: SectionViewModel.PayGroupButtonVM
        
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

extension PTSectionPayGroupView.SectionViewModel {
    
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
                  + 45 // 34)
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
            .previewLayout(.fixed(width: 370, height: 180))
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
