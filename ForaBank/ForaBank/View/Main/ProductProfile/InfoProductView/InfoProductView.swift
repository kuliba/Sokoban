//
//  InfoProductView.swift
//  ForaBank
//
//  Created by Дмитрий on 23.05.2022.
//

import SwiftUI

struct InfoProductView: View {
    
    @ObservedObject var viewModel: InfoProductViewModel
    
    var body: some View {
        
        ZStack(alignment: .bottom) {
            
            ScrollView(showsIndicators: false) {
                
                VStack(alignment: .leading, spacing: 24) {
                    
                    ForEach(viewModel.list, id: \.self) { item in
                        
                        HStack {
                            
                            VStack(alignment: .leading, spacing: 8) {
                                
                                Text(item.title)
                                    .foregroundColor(.gray)
                                    .font(.system(size: 12))
                                
                                Text(item.subtitle)
                                    .font(.system(size: 16))
                            }
                            
                            Spacer()
                            
                        }
                    }
                }
                .padding(.top, 28)
                .padding(.horizontal, 20)
                .frame(alignment: .leading)
                
                if let additionalListViewModel = viewModel.additionalList {
                    
                    VStack(alignment: .leading, spacing: 24) {
                        
                        Divider()
                        
                        ForEach(additionalListViewModel, id: \.self) { item in
                            
                            VStack(alignment: .leading, spacing: 8) {
                                
                                Text(item.title)
                                    .foregroundColor(.gray)
                                    .font(.system(size: 12))
                                
                                Text(item.subtitle)
                                    .font(.system(size: 16))
                            }
                        }
                    }
                    .padding(.top, 20)
                    .padding(.horizontal, 20)
                    .frame(alignment: .leading)
                }
                
            }
            
            if let buttonViewModel = viewModel.shareButton {
                
                Button(action: { buttonViewModel.action() }) {
                    
                    Text(buttonViewModel.title)
                }
                .frame(width: 336, height: 48, alignment: .center)
                .background(Color.mainColorsGrayLightest)
                .cornerRadius(8)
                .foregroundColor(Color.mainColorsBlack)
                
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarTitle(Text(viewModel.title), displayMode: .inline)
        .navigationBarItems(trailing:
                                
                                Button(action: { viewModel.shareButton?.action() }) {
            Image.ic24Share
                .foregroundColor(Color.mainColorsBlack)
        })
        .sheet(isPresented: $viewModel.isShareViewPresented, onDismiss: {
        }, content: {
            ActivityViewController(itemsToShare: viewModel.list)
        })
    }
}

struct InfoProductView_Previews: PreviewProvider {
    static var previews: some View {
        
        NavigationView {
            
            InfoProductView(viewModel: .sample)
        }
        
        NavigationView {
            
            InfoProductView(viewModel: .sampleCard)
        }
    }
}

extension InfoProductViewModel {
    
    static let sample: InfoProductViewModel = .init(product: productData, title: "Информация о вкладе", list: list, additionalList: nil, shareButton: nil, model: .emptyMock)
    
    static let sampleCard: InfoProductViewModel = .init(product: productData, title: "Реквизиты счета карты", list: listCard, additionalList: additionalList, shareButton: .init(.init(action: {})), model: .emptyMock)
    
    static let productData: ProductData = .init(id: 10002585800, productType: .card, number: "4444555566661122", numberMasked: "4444-XXXX-XXXX-1122", accountNumber: "40817810000000000001", balance: 1000123, balanceRub: nil, currency: "RUB", mainField: "Gold", additionalField: "Зарплатная", customName: "Моя карта", productName: "VISA REWARDS R-5", openDate: nil, ownerId: 10001639855, branchId: 2000, allowCredit: true, allowDebit: true, extraLargeDesign: .init(description: "string"), largeDesign: .init(description: "string"), mediumDesign: .init(description: "string"), smallDesign: .init(description: "string"), fontDesignColor: .init(description: "FFFFFF"), background: [.init(description: "FFBB36")])
    
    static let list: [InfoProductViewModel.ItemViewModel] = [.init(title: "Сумма первоначального размещения", subtitle: "1 000 000 ₽"), .init(title: "Дата открытия", subtitle: "24 августа 2021 года"), .init(title: "Дата закрытия", subtitle: "24 августа 2022 года"), .init(title: "Срок вклада", subtitle: "1 год"), .init(title: "Ставка по вкладу", subtitle: "7,04%"), .init(title: "Дата следующего начисления процентов", subtitle: "24 декабря 2021 года"), .init(title: "Сумма выплаченных процентов всего", subtitle: "17 744,66 ₽"), .init(title: "Суммы пополнений", subtitle: "2 744,66 ₽"), .init(title: "Суммы списаний", subtitle: "1 622,00 ₽"), .init(title: "Сумма начисленных процентов на дату", subtitle: "588, 90 ₽")]
    
    static let listCard: [InfoProductViewModel.ItemViewModel] = [.init(title: "Получатель", subtitle: "Константин Войцехов"), .init(title: "Номер счета", subtitle: "408178810888 005001137"), .init(title: "БИК", subtitle: "044525341"), .init(title: "Кореспондентский счет", subtitle: "301018103000000000341"), .init(title: "ИНН", subtitle: "7704113772"), .init(title: "КПП", subtitle: "770401001")]
    
    static let additionalList: [InfoProductViewModel.ItemViewModel] = [.init(title: "Держатель карты", subtitle: "KONSTANTIN VOYZEKHOV"), .init(title: "Номер карты", subtitle: "4897 43** **** 7654"), .init(title: "Карта дейстует до", subtitle: "12/23")]
}
