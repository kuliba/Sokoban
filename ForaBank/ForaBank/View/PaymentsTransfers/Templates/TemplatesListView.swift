//
//  TemplatesListView.swift
//  ForaBank
//
//  Created by Mikhail on 19.01.2022.
//  Full refactored by Dmitry Martynov 15.05.2023
//

import SwiftUI

struct TemplatesListView: View {
    
    @ObservedObject var viewModel: TemplatesListViewModel
   // @Namespace var namespace
    //@State var isNotMoveble = false
    
    private let columns = [GridItem(.flexible(), spacing: 16), GridItem(.flexible())]
  
    var body: some View {
        
        VStack {
             
            switch viewModel.state {
            case .normal, .select:
                
                if let categorySelectorViewModel = viewModel.categorySelector {
                    
                    OptionSelectorView(viewModel: categorySelectorViewModel)
                        .frame(height: 32)
                        .padding(.top, 16)
                        .padding(.horizontal)
                }
                
                switch viewModel.style {
                case .list:
                    
                    List {
                        
                        ForEach($viewModel.items) { $item in
                            
                            switch item.kind {
                            case .regular, .deleting:
                                
                                if #available(iOS 15.0, *) {
                                    
                                    TemplateItemView(viewModel: item,
                                                     style: .constant(.list),
                                                     editMode: $viewModel.editModeState)
                                    //.matchedGeometryEffect(id: "item", in: namespace)
                                    .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                                    .listRowBackground(
                                        Color.mainColorsGrayLightest.cornerRadius(16)
                                            .padding(.vertical, 6)
                                            .background(Color.white)
                                    )
                                    .listRowSeparatorTint(.white)
                                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                        
                                        if let itemsMenuViewModel =  viewModel.getItemsMenuViewModel() {
                                            
                                            ForEach(itemsMenuViewModel) { button in
                                                
                                                Button(action: { button.action(item.id) }) {
                                                    
                                                    button.icon
                                                        .renderingMode(.original)
                                                        .tint(.black)
                                                }
                                                .tint(.white)
                                            }
                                            
                                        } else {
                                            
                                            EmptyView()
                                        }
                                        
                                    } //swipe
                                    
                                    //.moveDisabled(viewModel.editModeState == .active ? false : true)
                                    
                                } else { //iOS 14
                                    
                                    TemplateItemView(viewModel: item,
                                                     style: .constant(.list),
                                                     editMode: $viewModel.editModeState)
                                    .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                                    .listRowBackground(
                                        Color.mainColorsGrayLightest.cornerRadius(16)
                                            .padding(.vertical, 6)
                                            .background(Color.white)
                                    )
                                    //.frame(height: 72, alignment: .bottomLeading)
                                    //                                            .modifier(SwipeSidesModifier(leftAction: {
                                    //
                                    //                                                itemVM.action.send(MyProductsSectionItemAction.Swiped(
                                    //                                                                    direction: .left, editMode: editMode))
                                    //                                            }, rightAction: {
                                    //
                                    //                                                itemVM.action.send(MyProductsSectionItemAction.Swiped(
                                    //                                                                    direction: .right, editMode: editMode))
                                    //                                            }))
                                    
                                } //iOS14-15
                                
                            case .add:
                                if #available(iOS 15.0, *) {
                                    
                                    AddNewItemView(viewModel: item, style: .constant(.list))
                                        .listRowInsets(EdgeInsets(top: 6, leading: 0, bottom: 0, trailing: 0))
                                        .listRowBackground(
                                            Color.mainColorsGrayLightest.cornerRadius(16)
                                                .padding(.vertical, 6)
                                                .background(Color.white)
                                        )
                                        .listRowSeparatorTint(.white)
                                }
                                //.matchedGeometryEffect(id: "item", in: namespace)
                            case .placeholder:
                                
                                PlaceholderItemView(style: .constant(.list))
                                    .listRowInsets(EdgeInsets(top: 6, leading: 0, bottom: 0, trailing: 0))
                                    .listRowBackground(
                                        Color.mainColorsGrayLightest.cornerRadius(16)
                                            .padding(.vertical, 6)
                                            .background(Color.white)
                                    )
                                
                            } //swich kind
                        }//ForEach
                        .onMove { indexes, destination in
                            guard let first = indexes.first else { return }
                            
                            viewModel.action.send(TemplatesListViewModelAction.ReorderItems
                                .ItemMoved(move: (first, destination)))
                        }
                        
                    } //List
                    .listStyle(.plain)
                    .environment(\.editMode, $viewModel.editModeState)
                    .padding(.horizontal)
                    
                // TilesView
                case .tiles:
                    
                    ScrollView {
                        
                        LazyVGrid(columns: columns, spacing: 16) {
                            
                            ForEach(viewModel.items) { item in
                                
                                switch item.kind {
                                case .regular, .deleting:
                                    
                                    TemplateItemView(viewModel: item,
                                                     style: .constant(.tiles),
                                                     editMode: $viewModel.editModeState)
                                    .contextMenu {
                                        
                                        if let itemsMenuViewModel =  viewModel.getItemsMenuViewModel() {
                                            
                                            ForEach(itemsMenuViewModel) { button in
                                                
                                                Button(action: { button.action(item.id) }) {
                                                    Text(button.subTitle)
                                                    button.icon
                                                }
                                            }
                                        }
                                    }
                                    
                                case .add:
                                    
                                    AddNewItemView(viewModel: item, style: .constant(.tiles))
                                
                                case .placeholder:
                                    
                                    PlaceholderItemView(style: .constant(.tiles))
                                    
                                } //kind swith
                                
                            
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top)
                    }//ScrollView
                } //case style
                
                
                if let deletePannelViewModel = viewModel.deletePannel {
                    
                    DeletePannelView(viewModel: deletePannelViewModel)
                }
                
            case let .emptyList(emptyTemplateListViewModel):
                
                EmptyTemplateListView(viewModel: emptyTemplateListViewModel)
                
            } //main stateSwitch
            
            NavigationLink("", isActive: $viewModel.isLinkActive) {
                
                if let link = viewModel.link  {
                    
                    switch link {
                    case .byPhone(let paymentPhoneView):
                        PaymentPhoneView(viewModel: paymentPhoneView)
                            .navigationBarBackButtonHidden(true)
                            .edgesIgnoringSafeArea(.all)

                    case .sfp(let paymentPhoneView):
                        PaymentPhoneView(viewModel: paymentPhoneView)
                            .edgesIgnoringSafeArea(.all)
                            .navigationBarBackButtonHidden(true)

                    case .direct(let paymentTemplateData):
                        CountryPaymentView(viewModel: paymentTemplateData)
                            .edgesIgnoringSafeArea(.bottom)
                            .navigationBarBackButtonHidden(true)

                    case .contactAdressless(let paymentTemplateData):
                        CountryPaymentView(viewModel: paymentTemplateData)
                            .edgesIgnoringSafeArea(.bottom)
                            .navigationBarBackButtonHidden(true)

                    case .housingAndCommunalService(let internetTVDetailsViewModel):
                        InternetTVDetailsView(viewModel: internetTVDetailsViewModel)
                            .edgesIgnoringSafeArea(.bottom)
                            .navigationBarBackButtonHidden(true)

                    case .mobile(let mobileViewModel):
                        MobilePayView(viewModel: mobileViewModel)
                            .edgesIgnoringSafeArea(.bottom)
                            .navigationBarBackButtonHidden(true)

                    case .internet(let internetTVDetailsViewModel):
                        InternetTVDetailsView(viewModel: internetTVDetailsViewModel)
                            .edgesIgnoringSafeArea(.bottom)
                            .navigationBarBackButtonHidden(true)

                    case .transport(let avtodorDetailsViewModel):
                        OperatorsView(viewModel: avtodorDetailsViewModel)
                            .edgesIgnoringSafeArea(.bottom)
                            .navigationBarBackButtonHidden(true)

                    case .externalEntity(let transferByRequisitesView):
                        TransferByRequisitesView(viewModel: transferByRequisitesView)
                            .navigationBarBackButtonHidden(true)
                            .edgesIgnoringSafeArea(.bottom)

                    case .externalIndividual(let transferByRequisitesView):
                        TransferByRequisitesView(viewModel: transferByRequisitesView)
                            .navigationBarBackButtonHidden(true)
                            .edgesIgnoringSafeArea(.bottom)
                        
                    case .betweenTheir(let meToMeViewModel):
                        MeToMeView(viewModel: meToMeViewModel)
                            .navigationBarBackButtonHidden(true)
                            .navigationBarHidden(false)
                            .edgesIgnoringSafeArea(.bottom)
                    }
                }
            }
        } //mainVStack
        .ignoresSafeArea(.container, edges: .bottom)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {

            ToolbarItem(placement: .principal) {
                    
                switch viewModel.navBarState {
                case let .regular(regViewModel):
                    if let regViewModel {
                        RegularNavBarView(viewModel: regViewModel) }
                    
                case let .search(searchViewModel):
                    if let searchViewModel {
                        SearchNavBarView(viewModel: searchViewModel) }
                
                case let .delete(deleteViewModel):
                    if let deleteViewModel {
                        TwoButtonsNavBarView(viewModel: deleteViewModel) }
                
                case let .reorder(reorderViewModel):
                    if let reorderViewModel {
                        TwoButtonsNavBarView(viewModel: reorderViewModel) }
                }
            }
            
        }
        .bottomSheet(item: $viewModel.sheet, content: { sheet in
            
            switch sheet.type {
            case let .betweenTheir(meToMeViewModel):
                
                NavigationView {
                    MeToMeView(viewModel: meToMeViewModel)
                        .navigationBarTitle("", displayMode: .inline)
                        .navigationBarBackButtonHidden(true)
                        .edgesIgnoringSafeArea(.all)
                }
                
            case let .renameItem(renameViewModel):
                
                RenameTemplateItemView(viewModel: renameViewModel)
            
            case let .productList(productListViewModel):
            
                ProductListView(viewModel: productListViewModel)
            }
        })
    }
}
    
extension TemplatesListView {
    
    struct RenameTemplateItemView: View {
        
        @ObservedObject var viewModel: TemplatesListViewModel.RenameTemplateItemViewModel
        
        var body: some View {
            
            VStack() {
                
                HStack {
                    
                    TemplatesListView.SearchTextField(text: $viewModel.text)
                    
                    if let clearButton = viewModel.clearButton {
                        
                        Spacer()
                        Button(action: clearButton.action, label: { clearButton.icon })
                            .foregroundColor(.black)
                    }
                }
                .overlay13 {
                    
                    VStack(alignment: .leading, spacing: 41) {
                        
                        Text(viewModel.textFieldLabel)
                            .font(.textBodyMR14180())
                            .foregroundColor(.textPlaceholder)
                        
                        Rectangle().frame(height: 1)
                    }
                    .offset(y: -8)
                }
                
                Spacer()
                
                Button(viewModel.saveButtonText, action: viewModel.saveButtonAction)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(viewModel.isNameNotValid ? Color.buttonPrimaryDisabled
                                                         : Color.buttonPrimary)
                    .foregroundColor(.textWhite)
                    .font(.textH3SB18240())
                    .cornerRadius(12)
                    .disabled(viewModel.isNameNotValid)
     
            }
            .frame(height: 210)
            .padding()
    
        }
    }
    
    struct ProductListView: View {
        
        @ObservedObject var viewModel: TemplatesListViewModel.ProductListViewModel
        
        var body: some View {
            
            VStack(alignment: .leading, spacing: 15) {

                Text(viewModel.title)
                    .font(.textH3SB18240())
                    .foregroundColor(.textSecondary)
                    .padding(.leading)
                
                ScrollView {
                
                    VStack(spacing: 16) {
                    
                        ForEach(viewModel.sections) { sectionVM in
                            
                            MyProductsSectionView(viewModel: sectionVM,
                                                  editMode: .constant(.inactive))
                            //.padding(.top, 16)
                        }
                    }
                }


//                    .frame(height: 72 * CGFloat(viewModel.items.count) + 30)
//                    .listStyle(.plain)
                   
                    
            } //VStack section
    
        }
    }
    
    struct EmptyTemplateListView: View {
        
        let viewModel: TemplatesListViewModel.EmptyTemplateListViewModel
        
        var body: some View {
            
            VStack(spacing: 0) {
                
                viewModel.icon
                
                Text(viewModel.title)
                    .font(Font.custom("Inter-SemiBold", size: 20))
                    .foregroundColor(.textSecondary)
                    .padding(.top, 20)
                
                Text(viewModel.message)
                    .multilineTextAlignment(.center)
                    .font(Font.custom("Inter-Medium", size: 16))
                    .foregroundColor(.textPlaceholder)
                    .lineSpacing(6)
                    .padding(.top, 16)
                    .padding(.horizontal, 50)
                
                Button {
                    
                    viewModel.button.action()
                    
                } label: {
                    
                    ZStack {
                        
                        Color(hex: "#F6F6F7")
                            .cornerRadius(8)
                        
                        Text(viewModel.button.title)
                            .font(Font.custom("Inter-Medium", size: 16))
                            .foregroundColor(.textSecondary)
                    }
                }
                .frame(height: 48)
                .padding(.top, 24)

            }.padding()
        }
    }
    
    struct DeletePannelView: View {
        
        let viewModel: TemplatesListViewModel.DeletePannelViewModel
        
        var body: some View {
            
            ZStack(alignment: .bottom) {
                
                Color(hex: "#F8F8F8").opacity(0.82)
                    .edgesIgnoringSafeArea(.bottom)
                
                HStack {
                    
                    Text(viewModel.description)
                        .font(.textH4M16240())
                        .padding(.leading, 20)
                    
                    Spacer()
                    
                    TemplatesListView
                        .PanelButtonView(viewModel: viewModel.selectAllButton)
                    
                    Spacer()
                    
                    TemplatesListView
                        .PanelButtonView(viewModel: viewModel.deleteButton)
                            .padding(.trailing, 30)
                    
                }
                .background(Color(hex: "#F8F8F8").opacity(0.82))
            }
            .frame(height: 56)
        }
    }
    
    struct PanelButtonView: View {
        
        let viewModel: TemplatesListViewModel.PanelButtonViewModel
        
        var body: some View {
        
            Button { viewModel.action()
            } label: {
                
                VStack(spacing: 4) {
                    
                    viewModel.icon
                        .resizable()
                        .renderingMode(.template)
                        .frame(width: 24, height: 24)
                    
                    Text(viewModel.title)
                        .font(.textBodyMR14180())
                }
                .foregroundColor(.black)
            }
            .disabled(viewModel.isDisable)
            .opacity(viewModel.isDisable ? 0.5 : 1.0)
        }
    }

    
    
    struct SelectItemVew: View {
        
        let isSelected: Bool
        var body: some View {
            
            HStack {
                
                VStack {
                    
                    if isSelected == true {
                        
                        ZStack {
                            
                            Image("Template Item Select Button Background")
                            Image("Template Item Select Button Checkmark")
                        }
                        
                    } else {
                        
                        Image("Template Item Select Button Background")
                    }
                    
                    Spacer()
                }
                
                Spacer()
            }
        }
    }

}



//MARK: - Helpers

struct TemplatesListView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        Group {
            
            TemplatesListView
                .ProductListView(viewModel: .init(sections: [.sample2]))
                .previewDisplayName("Product List View")
            
            TemplatesListView
                .RenameTemplateItemView(viewModel: .init(oldName: "Old Name", templateID: 1))
                .previewDisplayName("Rename View")
            
            NavigationView {
                TemplatesListView(viewModel: .sampleComplete )
                    .environment(\.mainWindowSize, CGSize(width: 414, height: 800))
                    
            }
            .previewDisplayName("TemplatesView List")
            
            NavigationView {
                TemplatesListView(viewModel: .sampleTiles )
            }
            .previewDisplayName("TemplatesView Tiles")
            
            NavigationView {
                TemplatesListView(viewModel: .sampleDeleting )
            }
            
            TemplatesListView.EmptyTemplateListView(viewModel: .sample)
                .previewDisplayName("Empty State")
        }
    }
}




