//
//  OperationTemplateView.swift
//  ForaBank
//
//  Created by Mikhail on 19.01.2022.
//

import SwiftUI
//import UniformTypeIdentifiers

struct TemplatesListView: View {
    
    @ObservedObject var viewModel: TemplatesListViewModel
   // @Namespace var namespace
    //@State var isNotMoveble = false
    
    private let columns = [GridItem(.flexible(), spacing: 16), GridItem(.flexible())]
  
    var body: some View {
        
        VStack {
                
            if let categorySelectorViewModel = viewModel.categorySelector {
                    
                OptionSelectorView(viewModel: categorySelectorViewModel)
                    .frame(height: 32)
                    .padding(.top, 16)
                    .padding(.horizontal, 20)
            }
                    
            switch viewModel.style {
            case .list:
                        
                List {
                        
                    ForEach($viewModel.items) { $item in
                                
                        switch item.kind {
                        case .regular:
                                    
                            if #available(iOS 15.0, *) {
                                        
                                TemplateItemView(viewModel: item,
                                                 style: .constant(.list),
                                                 editMode: $viewModel.editModeState)
                                    //.matchedGeometryEffect(id: "item", in: namespace)
                                    .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                                    .listRowBackground(
                                        Color.mainColorsGrayLightest.cornerRadius(16)
                                            .padding(.vertical,6)
                                            .background(Color.white)
                                    )
                                    .listRowSeparatorTint(.white)
                                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                            
                                        if let itemMenuViewModel =  viewModel.getItemMenuViewModel() {
                                                
                                            ForEach(itemMenuViewModel) { button in
                                                
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
                                        .listRowInsets(EdgeInsets(top: 6, leading: 0, bottom: 6, trailing: 0))
                                        .listRowBackground(
                                            Color.mainColorsGrayLightest.cornerRadius(16)
                                                .padding(.vertical,6)
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
                                    
                                AddNewItemView(viewModel: item, style: .constant(.list))
                                    .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                                    .listRowBackground(
                                        Color.mainColorsGrayLightest.cornerRadius(16)
                                            .padding(.vertical,6)
                                            .background(Color.white)
                                    )
                            
                                    //.matchedGeometryEffect(id: "item", in: namespace)
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
                                case .regular:
                                    
                                    TemplateItemView(viewModel: item,
                                                     style: .constant(.tiles),
                                                     editMode: $viewModel.editModeState)
                                    .contextMenu {
                                        
                                        if let itemMenuViewModel =  viewModel.getItemMenuViewModel() {
                                            
                                            ForEach(itemMenuViewModel) { button in
                                                
                                                Button(action: { button.action(item.id) }) {
                                                    Text(button.subTitle)
                                                    button.icon
                                                }
                                            }
                                        }
                                    }
                                    
                                case .add:
                                    
                                    AddNewItemView(viewModel: item, style: .constant(.tiles))

                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 24)
                    }//ScrollView
                    } //case style
              
           
            if let deletePannelViewModel = viewModel.deletePannel {
                 
                 DeletePannelView(viewModel: deletePannelViewModel)
            }
            
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
        //.transition(.identity)
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
            }
        })
    }
}
    
extension TemplatesListView {
    
    struct RenameTemplateItemView: View {
        
        @ObservedObject var viewModel: TemplatesListViewModel.RenameTemplateItemViewModel
        
        var body: some View {
            
            VStack {
                
                HStack {
                    
                    TemplatesListView.SearchTextField
                        .init(text: $viewModel.text)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    if let clearButton = viewModel.clearButton {
                        
                        Button(action: clearButton.action, label: { clearButton.icon })
                            .frame(width: 32)
                        
                    } else {
                        
                        Color(.clear).frame(width: 32)
                    }
                }
                
                Button(action: {}, label: {
                    
                    ZStack {
                        
                        
                        Color.red
                        Text("Сохранить")
                    }

                    .frame(height: 56)
                    .padding()
            
                } )
                
                    .foregroundColor(.mainColorsWhite)
                    .background(RoundedRectangle(cornerRadius: 12)
                        .background(Color.red)
                        .frame(height: 56))
                    //.frame(minWidth: .infinity)
            }
            
        }
    }
    
    struct OnboardingView: View {
        
        let viewModel: TemplatesListViewModel.OnboardingViewModel
        
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
                
                Color.init(hex: "#F8F8F8").opacity(0.82)
                    .edgesIgnoringSafeArea(.bottom)
                
                HStack {
                    
                    Text(viewModel.description)
                        .font(.textBodyMM14200())
                    
                    Spacer()
                    
                    Button {
                        viewModel.button.action()
                    } label: {
                        VStack(spacing: 4) {
                            viewModel.button.icon
                                .resizable()
                                .renderingMode(.template)
                                .frame(width: 24, height: 24)
                            Text(viewModel.button.caption)
                                .font(.textBodySR12160())
                        }
                        .foregroundColor(.black)
                    }
                    .padding(.trailing, 30)
                    .disabled(viewModel.button.isEnabled == false)
                    .opacity(viewModel.button.isEnabled ? 1.0 : 0.5)
                }
                .background(Color.init(hex: "#F8F8F8").opacity(0.82))
                .padding(20)
            }
            .frame(height: 56)
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
                .RenameTemplateItemView(viewModel: .init() )
            
            NavigationView {
                TemplatesListView(viewModel: .sampleComplete )
                    .environment(\.mainWindowSize, CGSize(width: 414, height: 800))
            }
            
            NavigationView {
                TemplatesListView(viewModel: .sampleTiles )
            }
            
            NavigationView {
                TemplatesListView(viewModel: .sampleDeleting )
            }
            
            TemplatesListView.OnboardingView(viewModel: .sample)
        }
    }
}



