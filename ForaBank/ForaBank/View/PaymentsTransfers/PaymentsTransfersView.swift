//
//  Payments&TransfersView.swift
//  ForaBank
//
//  Created by Dmitry Martynov on 09.05.2022.
//

import SwiftUI

struct PaymentsTransfersView: View {
    
    @State private var rowsCount: Int = 3
    
    @ObservedObject
    var viewModel: PaymentsTransfersViewModel
    
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
                  + tabBarHeight
        }
        
        let payRowHeight: CGFloat = (48 + 4)
        let pageScrollViewWidth: CGFloat = 312
        let payRowCountIfZeroHeight = 3
    }
    
    private let const = ViewSettingsConst()
    
    var body: some View {
        
        ZStack(alignment: .top) {
        VStack() {
            
            Color.clear.frame(height: const.searchViewHeight) // mock SearchView
        
        GeometryReader { grProxy in
            ScrollView(.vertical, showsIndicators: false) {
            
                Text(viewModel.latestPaymentsSectionTitle) //LatestPayments
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .font(.textH1SB24322())
                    .foregroundColor(.textSecondary)
                    .padding(.vertical, 16)
                    .padding(.leading, 20)
                
                ScrollView(.horizontal,showsIndicators: false) {
                    HStack(spacing: 4) {
                        ForEach(viewModel.latestPaymentsButtons) { item in
                           
                            LatestPaymentButtonView(viewModel: item)
                        }
                        Spacer()
                    }
                    
                }.padding(.leading, 8)
            
                Text(viewModel.transfersSectionTitle) //Transfers
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .font(.textH2SB20282())
                    .foregroundColor(.textSecondary)
                    .padding(.top, 30)
                    .padding(.bottom, 14)
                    .padding(.leading, 20)
            
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                
                        ForEach(viewModel.transferButtons) { buttonVM in
                            TransferButtonView(viewModel: buttonVM)
                        }
                        Spacer(minLength: 15)
                    }
                }.padding(.leading, 20)
                
                Text(viewModel.paySectionTitle) //Pay
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
                    .frame(width: const.pageScrollViewWidth)
                    .introspectScrollView {
                        $0.isPagingEnabled = true
                        $0.clipsToBounds = false
                    }
                    .onAppear {
                        let scrollHeight = grProxy.size.height - const.fixHeightBlok
                        let calcRowsCount = Int(round(10 * scrollHeight) / (10 * const.payRowHeight))
                        
                        if calcRowsCount > 0 {
                            rowsCount = calcRowsCount
                        } else {
                            rowsCount = const.payRowCountIfZeroHeight
                        }
                    }
                    Spacer()
                }.padding(.leading, 20)
                
            } //mainVerticalScrollView
        } //geometry
        
            if #available(iOS 14.0, *) {
                Rectangle()
                    .ignoresSafeArea()
                    .foregroundColor(.mainColorsGrayLightest)
                    .frame(height: const.tabBarHeight)
 
            } else {
                Color.mainColorsGrayLightest.frame(height: const.tabBarHeight)
            } //mock TabBarView

        } //mainVStack
        
            if #available(iOS 14.0, *) {
                Color.mainColorsGrayLightest
                    .frame(height: const.searchViewHeight)
                    .ignoresSafeArea()
                    .overlay(TopSearchViewMock())
            } else {
                Color.mainColorsGrayLightest
                    .frame(height: const.searchViewHeight)
                    .overlay(TopSearchViewMock())
            } //mock topSearchView
                
        } //mainZStack
        
    }
}

extension PaymentsTransfersView {

//MARK: - LatestPaymentButtonView
    
    struct LatestPaymentButtonView: View {
        let viewModel: PaymentsTransfersViewModel.LatestPaymentButtonVM
        
        var body: some View {
            Button(action: {}, label: {
                VStack(alignment: .center, spacing: 8) {
                    ZStack {
                        
                        Circle()
                            .fill(Color.mainColorsGrayLightest)
                            .frame(height: 56)
                            .overlay13 {
                                
                                switch viewModel.image {
                                case let .image(image):
                                   
                                    image
                                        .resizable()
                                        .scaledToFit()
                                        .clipShape(Circle())
                                        .frame(height: 56)
                                    
                                case let .text(text):
                                   
                                    Text(text)
                                        .font(.textH4M16240())
                                        .foregroundColor(.textPlaceholder)
                                    
                                case let .icon(icon, color):
                                    
                                    icon
                                        .resizable()
                                        .frame(width: 24, height: 24)
                                        .foregroundColor(color)
                                }
                            }
                    }
                    .overlay13(alignment: .topTrailing) {
                        if let topIcon = viewModel.topIcon {
                            topIcon
                                .resizable()
                                .frame(width: 24, height: 24)
                        }
                    }
                    
                    Text(viewModel.description)
                        .font(.textBodySR12160())
                        .lineLimit(2)
                        .foregroundColor(.textSecondary)
                        .frame(width: 80, height: 32, alignment: .center)
                        .multilineTextAlignment(.center)
                }
            })
        }
    }

//MARK: - TransferButtonView

    struct TransferButtonView: View {
        let viewModel: PaymentsTransfersViewModel.TransferButtonVM
        
        var body: some View {
            ZStack(alignment: .bottom){
                
                RoundedRectangle(cornerRadius: 12)
                    .frame(width: 80, height: 60)
                    .shadow(color: .mainColorsBlackMedium.opacity(0.4), radius: 12, y: 6)
                
                Button(action: viewModel.action, label: {
                    ZStack {
                        VStack(spacing: 16) {
                        
                            Image(viewModel.image)
                                .resizable()
                                .renderingMode(.original)
                                .frame(width: 48, height: 48)
                                .padding(.top, 10)
                        
                            HStack {
                                Text(viewModel.title)
                                    .font(.textBodyMR14200())
                                    .foregroundColor(.white)
                                    .multilineTextAlignment(.leading)
                                    .padding(.leading, 12)
                                Spacer()
                            }
                        
                        }.frame(width: 104)
                    }
                })
                .frame(width: 104, height: 124)
                .background(Color.mainColorsBlackMedium)
                .cornerRadius(12)
            }

        }
    }

//MARK: - ButtonPayGroupView

    struct ButtonPayGroupView: View {
        let viewModel: PaymentsTransfersViewModel.PayGroupButtonVM
        
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
 
//MARK: - ViewMock

    struct TopSearchViewMock: View {
        var body: some View {
            
            HStack {
                Image("ic24Search")
                Text("Название категории, ИНН")
                    .font(.textBodyMR14200())
                    .foregroundColor(Color(hex: "#999999"))
                Spacer()
                Image("ic24BarcodeScanner2")
            }
            .padding(18)
            .background(Color.mainColorsGrayLightest)
            
        }
    }

}

//MARK: - Preview

struct Payments_TransfersView_Previews: PreviewProvider {
    static var previews: some View {
        PaymentsTransfersView(viewModel: .sample)
            .previewDevice(PreviewDevice(rawValue: "x 15.4"))
            .previewDisplayName("iPhone X")
        
        PaymentsTransfersView(viewModel: .sample)
            .previewDevice(PreviewDevice(rawValue: "iPhone 13 Pro Max"))
            .previewDisplayName("iPhone 13 Pro Max")
        
        PaymentsTransfersView(viewModel: .sample)
            .previewDevice("iPhone SE (3rd generation)")
            .previewDisplayName("iPhone SE (3rd generation)")
        
        PaymentsTransfersView(viewModel: .sample)
            .previewDevice("iPhone 13 mini")
            .previewDisplayName("iPhone 13 mini")
        
        PaymentsTransfersView(viewModel: .sample)
            .previewDevice("5se 15.4")
            .previewDisplayName("iPhone 5 SE")
            
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



