//
//  InfoProductView.swift
//  ForaBank
//
//  Created by Дмитрий on 23.05.2022.
//

import SwiftUI

struct InfoProductView: View {
    
    @ObservedObject var viewModel: InfoProductViewModel
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    private var buttonForegroundColor: Color {
        
        viewModel.isDisableShareButton ? .textPlaceholder : .mainColorsBlack
    }
    
    var body: some View {
        
        ZStack {
            VStack(spacing: 0) {
                
                ScrollView(showsIndicators: false) {
                    
                    VStack(spacing: 20) {
                        
                        if !viewModel.list.isEmpty {
                            
                            ItemsViewOld(items: viewModel.list)
                        }
                        
                        if !viewModel.listWithAction.isEmpty {
                            
                            ItemsViewNew(
                                items: viewModel.listWithAction,
                                title: "Реквизиты счета",
                                showCheckbox: viewModel.needShowCheckbox,
                                isCheck: $viewModel.accountInfoSelected
                            )
                        }
                        
                        if let items = viewModel.additionalList {
                            
                            ItemsViewNew(
                                items: items,
                                title: "Реквизиты карты",
                                showCheckbox: viewModel.needShowCheckbox,
                                isCheck: $viewModel.cardInfoSelected
                            )
                        }
                    }
                    .padding(.top, 20)
                }
                if let buttonViewModel = viewModel.shareButton {
                    
                    Button(action: buttonViewModel.action) {
                        
                        Text(buttonViewModel.title)
                            .font(.textH3M18240())
                            .frame (height: 48,
                                    alignment: .center)
                            .frame(maxWidth:.infinity)
                            .padding(.leading, 16)
                            .padding(.trailing, 15)
                    }
                    .frame(height: 56, alignment: .center)
                    .background(Color.mainColorsGrayLightest)
                    .cornerRadius(12)
                    .foregroundColor(buttonForegroundColor)
                    .padding()
                    .disabled(viewModel.isDisableShareButton)
                }
            }
            .navigationBarTitle(Text(viewModel.title), displayMode: .inline)
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(
                leading: navigationLeadingItem,
                trailing: navigationTrailingItem
            )
            .sheet(
                isPresented: $viewModel.isShareViewPresented,
                onDismiss: viewModel.hideCheckBox,
                content: {
                    
                    ActivityView(viewModel: .init(
                        activityItems: [viewModel.itemsToString(items: viewModel.dataForShare)])
                    )
                })
            .bottomSheet(item: $viewModel.bottomSheet) { bottomSheet in
                if let sendAll = viewModel.sendAllButtonVM,
                   let sendSelected = viewModel.sendSelectedButtonVM {
                    
                    InfoProductSheet(
                        sendAll: sendAll,
                        sendSelected: sendSelected
                    )
                }
            }
            .alert(item: $viewModel.alert, content: { alertViewModel in
                Alert(with: alertViewModel)
            })
            viewModel.spinner.map { spinner in
                ZStack {
                    Color.black
                        .opacity(0.3)
                        .ignoresSafeArea()
                    
                    SpinnerRefreshView(icon: spinner.icon)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            }
        }
    }
    
    @ViewBuilder
    var navigationLeadingItem: some View {
        
        if viewModel.needShowCheckbox {
            
            Button(action: viewModel.hideCheckBox) {
                
                HStack {
                    
                    Image.ic24Close
                        .aspectRatio(contentMode: .fit)
                }
            }
        } else {
            
            Button(action: {
                
                self.presentationMode.wrappedValue.dismiss()
                self.viewModel.close()
            }) {
                HStack {
                    Image.ic24ChevronLeft
                    .frame(width: 24, height: 24)                }
            }
        }
    }
    
    var navigationTrailingItem: some View {
        
        viewModel.shareButton.map {
            Button(action: $0.action) {
                
                Image.ic24Share
                    .foregroundColor(buttonForegroundColor)
            }
            .disabled(viewModel.isDisableShareButton)
        }
    }
    
    struct ButtonView: View {
        
        let viewModel: InfoProductViewModel.ItemViewModel
        
        var body: some View {
            
            HStack(alignment: .center) {
                
                VStack(alignment: .leading, spacing: 8) {
                    
                    Text(viewModel.title)
                        .foregroundColor(.gray)
                        .font(.system(size: 12))
                    
                    Text(viewModel.subtitle)
                        .font(.system(size: 16))
                }
                
                Spacer()
                
                if let button = viewModel.button {
                    
                    Button {
                        
                        button.action()
                        
                    } label: {
                        
                        button.icon
                    }
                }
            }
        }
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
    
    static let sample: InfoProductViewModel = .init(product: productData, title: "Информация о вкладе", list: list, listWithAction: [],  additionalList: nil, shareButton: nil, model: .emptyMock)
    
    static let sampleCard: InfoProductViewModel = .init(product: productData, title: "Реквизиты счета и карты", list: [], listWithAction: .items, additionalList: .cardItems, shareButton: .init(.init(action: {})), model: .emptyMock)
    
    static let productData: ProductData = .init(id: 10002585800, productType: .card, number: "4444555566661122", numberMasked: "4444-XXXX-XXXX-1122", accountNumber: "40817810000000000001", balance: 1000123, balanceRub: nil, currency: "RUB", mainField: "Gold", additionalField: "Зарплатная", customName: "Моя карта", productName: "VISA REWARDS R-5", openDate: nil, ownerId: 10001639855, branchId: 2000, allowCredit: true, allowDebit: true, extraLargeDesign: .init(description: "string"), largeDesign: .init(description: "string"), mediumDesign: .init(description: "string"), smallDesign: .init(description: "string"), fontDesignColor: .init(description: "FFFFFF"), background: [.init(description: "FFBB36")], order: 0, isVisible: true, smallDesignMd5hash: "", smallBackgroundDesignHash: "")
    
    static let list: [InfoProductViewModel.ItemViewModel] = [.init(title: "Сумма первоначального размещения", subtitle: "1 000 000 ₽"), .init(title: "Дата открытия", subtitle: "24 августа 2021 года"), .init(title: "Дата закрытия", subtitle: "24 августа 2022 года"), .init(title: "Срок вклада", subtitle: "1 год"), .init(title: "Ставка по вкладу", subtitle: "7,04%"), .init(title: "Дата следующего начисления процентов", subtitle: "24 декабря 2021 года"), .init(title: "Сумма выплаченных процентов всего", subtitle: "17 744,66 ₽"), .init(title: "Суммы пополнений", subtitle: "2 744,66 ₽"), .init(title: "Суммы списаний", subtitle: "1 622,00 ₽"), .init(title: "Сумма начисленных процентов на дату", subtitle: "588, 90 ₽")]
}

extension Array where Element == InfoProductViewModel.ItemViewModelForList {
    
    static let items: Self = [
        .single(
            .init(
                id: .payeeName,
                title: "Получатель",
                titleForInformer: "Получатель",
                subtitle: "Константин Войцехов",
                valueForCopy: "valueForCopy",
                actionForLongPress: { _,_ in },
                actionForIcon: {}
            )
        ),
        .single(
            .init(
                id: .accountNumber,
                title: "Номер счета",
                titleForInformer: "Номер счета",
                subtitle: "408178810888 005001137",
                valueForCopy: "valueForCopy",
                actionForLongPress: { _,_ in },
                actionForIcon: {}
            )
        ),
        .single(
            .init(
                id: .bic,
                title: "БИК",
                titleForInformer: "БИК",
                subtitle: "044525341",
                valueForCopy: "valueForCopy",
                actionForLongPress: { _,_ in },
                actionForIcon: {}
            )
        ),
        .single(
            .init(
                id: .corrAccount,
                title: "Кореспондентский счет",
                titleForInformer: "Кореспондентский счет",
                subtitle: "301018103000000000341",
                valueForCopy: "valueForCopy",
                actionForLongPress: { _,_ in },
                actionForIcon: {}
            )
        ),
        .multiple(
            [
                .init(
                    id: .inn,
                    title: "ИНН",
                    titleForInformer: "ИНН",
                    subtitle: "7704113772",
                    valueForCopy: "valueForCopy",
                    actionForLongPress: { _,_ in },
                    actionForIcon: {}
                ),
                .init(
                    id: .kpp,
                    title: "КПП",
                    titleForInformer: "КПП",
                    subtitle: "770401001",
                    valueForCopy: "valueForCopy",
                    actionForLongPress: { _,_ in },
                    actionForIcon: {}
                )
            ]
        )
    ]
    
    static let cardItems: Self = [
        .single(
            .init(
                id: .holderName,
                title: "Держатель",
                titleForInformer: "Держатель",
                subtitle: "Константин Войцехов",
                valueForCopy: "valueForCopy",
                actionForLongPress: { _,_ in },
                actionForIcon: {}
            )
        ),
        .single(
            .init(
                id: .numberMasked,
                title: "Номер карты",
                titleForInformer: "Номер карты",
                subtitle: "**** **** **** 0500",
                valueForCopy: "valueForCopy",
                actionForLongPress: { _,_ in },
                actionForIcon: {}
            )
        ),
        .multiple(
            [
                .init(
                    id: .expirationDate,
                    title: "Карта действует до",
                    titleForInformer: "Срок действия карты",
                    subtitle: "01/01",
                    valueForCopy: "valueForCopy",
                    actionForLongPress: { _,_ in },
                    actionForIcon: {}
                ),
                .init(
                    id: .cvvMasked,
                    title: .cvvTitle,
                    titleForInformer: .cvvTitle,
                    subtitle: "111",
                    valueForCopy: "",
                    actionForLongPress: { _,_ in },
                    actionForIcon: {}
                )
            ]
        )
    ]
}
