//
//  AuthTransfersView.swift
//  ForaBank
//
//  Created by Pavel Samsonov on 23.11.2022.
//  Refactor by Dmitry Martynov on 26.12.2022
//

import SwiftUI

struct AuthTransfersView: View {
    
    @ObservedObject var viewModel: AuthTransfersViewModel
    
    var body: some View {
        
        ZStack {
            
            TransfersImageView(viewModel: viewModel)
            
            ScrollView(.vertical, showsIndicators: false) {
             
                    VStack(spacing: 24) {
                        
                        TransfersTitleView(viewModel: viewModel)
                            .padding(.vertical, 32)
                        
                        ForEach(viewModel.sections) { section in
                            
                            switch section {
                            case let coverViewModel as TransfersCoverView.ViewModel:
                                TransfersCoverView(viewModel: coverViewModel)
                                
                            case let directionsViewModel as TransfersDirectionsView.ViewModel:
                                TransfersDirectionsView(viewModel: directionsViewModel)
                                
                            case let infoViewModel as TransfersInfoView.ViewModel:
                                TransfersInfoView(viewModel: infoViewModel)
                                
                            case let promoViewModel as TransfersBannersView.ViewModel:
                                TransfersBannersView(viewModel: promoViewModel)
                                
                            case let countriesViewModel as TransfersCountriesView.ViewModel:
                                TransfersCountriesView(viewModel: countriesViewModel)
                                
                            case let advantagesViewModel as TransfersAdvantagesView.ViewModel:
                                TransfersAdvantagesView(viewModel: advantagesViewModel)
                                
                            case let questionsViewModel as TransfersQuestionsView.ViewModel:
                                TransfersQuestionsView(viewModel: questionsViewModel).scrollId(9)
                                
                            case let supportViewModel as TransfersSupportView.ViewModel:
                                TransfersSupportView(viewModel: supportViewModel).scrollId(10)
                                
                            default:
                                Color.clear
                            }
                        }
                        
                        Text(viewModel.legalTitle)
                            .font(.textBodySR12160())
                            .foregroundColor(.mainColorsGray)
                        
                    }
                    .padding(.horizontal)
                    .padding(.bottom)
                    .background(GeometryReader {
                                    Color.clear.preference(key: ViewOffsetKey.self,
                                        value: -$0.frame(in: .named("scroll")).origin.y)
                                })
                    .onPreferenceChange(ViewOffsetKey.self) {
                        
                        viewModel.navigation.opacity = $0 / 150
                    }
                
            }
            .coordinateSpace(name: "scroll")
            .navigationBar(with: viewModel.navigation)
        
        }.bottomSheet(item: $viewModel.bottomSheet) { sheet in
            
            switch sheet.type {
            case let .directions(viewModel):
                TransfersDetailView(viewModel: viewModel)
                
            case let .promoMig(viewModel):
                TransfersPromoDetailView(viewModel: viewModel)
             
            case let .promoDeposit(viewModel):
                TransfersPromoDepositView(viewModel: viewModel)
            }
        }
    }
}

extension AuthTransfersView {
    
    struct ViewOffsetKey: PreferenceKey {
        typealias Value = CGFloat
        static var defaultValue = CGFloat.zero
        static func reduce(value: inout Value, nextValue: () -> Value) {
            value += nextValue()
        }
    }
    
    struct TransfersImageView: View {
        
        @ObservedObject var viewModel: AuthTransfersViewModel
        
        var body: some View {
            
            VStack {
                
                viewModel.iconName
                    .renderingMode(.original)
                    .opacity(viewModel.opacity)
                
                Spacer()
                
            }
            .padding(.top, viewModel.padding)
            .edgesIgnoringSafeArea(.top)
        }
    }
    
    struct TransfersTitleView: View {
        
        @ObservedObject var viewModel: AuthTransfersViewModel
        
        var body: some View {
            
            VStack {
                
                HStack {
                    
                    VStack(alignment: .leading) {
                        
                        Text(viewModel.title)
                            .font(.marketingH0L40X480())
                            .foregroundColor(.mainColorsBlack)
                        
                        Text(viewModel.subTitle)
                            .font(.marketingH0B40X480())
                            .foregroundColor(.mainColorsBlack)
                    }
                    
                    Spacer()
                    
                }
            }
        }
    }
}

struct AuthTransfersView_Previews: PreviewProvider {
    
    static var previews: some View {
        AuthTransfersView(viewModel: .sample)
    }
}
