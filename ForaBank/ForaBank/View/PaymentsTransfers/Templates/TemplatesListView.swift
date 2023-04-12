//
//  OperationTemplateView.swift
//  ForaBank
//
//  Created by Mikhail on 19.01.2022.
//

import SwiftUI

struct TemplatesListView: View {
    
    @ObservedObject var viewModel: TemplatesListViewModel
    @State var searchText: String = ""
    
    @available(iOS 14.0, *)
    var columns: [GridItem] {
        switch viewModel.style {
        case .list:
            return [GridItem(.flexible(minimum:72))]
        case .tiles:
            return [GridItem(.flexible(), spacing: 16),GridItem(.flexible())]
        }
    }
    
    var body: some View {
        
        Group {
            
            if let onboardingViewModel = viewModel.onboarding {
                
                OnboardingView(viewModel: onboardingViewModel)
                
            } else {
                
                ZStack {
                    
                    VStack {
                        
                        if let categorySelectorViewModel = viewModel.categorySelector {
                            
                            OptionSelectorView(viewModel: categorySelectorViewModel)
                                .frame(height: 32)
                                .padding(.top, 16)
                                .padding(.horizontal, 20)
                        }

                        ScrollView {
                            if #available(iOS 14, *) {
                                
                                LazyVGrid(columns: columns, spacing: 16) {
                                    ForEach(viewModel.items) { itemViewModel in
                                        
                                        switch itemViewModel.kind {
                                        case .regular:
                                            TemplateItemView(viewModel: itemViewModel,
                                                             style: $viewModel.style)

                                        case .add:
                                            AddNewItemView(viewModel: itemViewModel, style: $viewModel.style)
                                        }
                                    }
                                }
                                .padding(.horizontal, 20)
                                .padding(.top, 24)
                                
                            } else { //iOS <14
                                
                                VStack(spacing: 12) {
                                    ForEach(viewModel.items) { itemViewModel in
                                       
                                        switch itemViewModel.kind {
                                        case .regular:
                                            TemplateItemViewLegacy(viewModel: itemViewModel, style: $viewModel.style)

                                        case .add:
                                            AddNewItemViewLegacy(viewModel: itemViewModel, style: $viewModel.style)
                                        }
                                    }
                                }
                                .padding(.horizontal, 20)
                                .padding(.top, 24)
                            }
                        } //ScrollView
                        
                        
                        if let deletePannelViewModel = viewModel.deletePannel {
                            
                            DeletePannelView(viewModel: deletePannelViewModel)
                        }
                    } //VStack
                    
                    if let contextMenuViewModel = viewModel.contextMenu {
                        
                        ZStack(alignment: .topTrailing) {
                            
                            Color.init(white: 1.0, opacity: 0.01)
                                .onTapGesture {
                                    
                                    viewModel.closeContextMenu()
                                }
                            
                            ContextMenuView(viewModel: contextMenuViewModel)
                                .frame(width: 260)
                        }
                    }
                }
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
        }
        .transition(.identity)
        .navigationBarTitle(Text(viewModel.title), displayMode: .inline)
        .navigationBarBackButtonHidden(true)
        
//        .navigationBarItems(
//            leading:
//
//
//
//                    Button(action: viewModel.navButtonBack.action, label: {
//                        viewModel.navButtonBack.icon
//                            .renderingMode(.template)
//                            .foregroundColor(.iconBlack)
//                    })
//
//
//
//             ,
//            trailing:
//                HStack {
//                    ForEach(viewModel.navButtonsRight) { element in
//                        Button {
//                            element.action()
//                        } label: {
//                            element.icon
//                                .renderingMode(.template)
//                                .foregroundColor(Color.init(hex: "1C1C1C"))
//                        }
//                    }
//                }
//    )
        .toolbar {

            TemplatesListToolbar(state: viewModel.navBarState,
                                 searchText: $searchText)
        }
 

        .onChange(of: searchText, perform: { newValue in
            print("mdy \(newValue)")
        })

        .bottomSheet(item: $viewModel.sheet, content: { sheet in
            
            switch sheet.type {
            case .betweenTheir(let meToMeViewModel):
                NavigationView {
                    MeToMeView(viewModel: meToMeViewModel)
                        .navigationBarTitle("", displayMode: .inline)
                        .navigationBarBackButtonHidden(true)
                        .edgesIgnoringSafeArea(.all)
                }
            }
        })
    }
}

//MARK: - Views

extension TemplatesListView {
    
    struct TemplatesListToolbar: ToolbarContent {
        
        let state: TemplatesListViewModel.NavBarState
        @Binding var searchText: String

        var body: some ToolbarContent {
               
                ToolbarItem(placement: .navigationBarLeading) {

                    if case .regular(let viewModel) = state {
                        
                        HStack {
                            Button(action: {},
                                   label: {
                                viewModel.backButton.icon
                                    .renderingMode(.template)
                                    .foregroundColor(.iconBlack)
                            })
                            Spacer()
                            Text("d")
                            Menu {
                                
                                Button(action: {}) {
                                    Label("Create a file", systemImage: "doc")
                                }
                                
                                Button(action: {}) {
                                    Label("Create a folder", systemImage: "folder")
                                }
                                
                                Button(action: {}) {
                                    Label("Remove old files", systemImage: "trash")
                                        .foregroundColor(.red)
                                }
                            }
                        label: {
                            Label("Add", systemImage: "plus")
                        }
                        }
                        
                    }
                }
                
                ToolbarItem(placement: .principal) {
                    
                    if case .search(let viewModel) = state {
                        
                        HStack {
                            Image(systemName: "sun.min.fill")
                            
                            TextField("Имя шаблона", text: $searchText)
                            
                            Button(action: {}, label: { Image.ic24Close })
                            Button("Отмена", action: {} )
                        }
                    }
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

//MARK: - AddNewItemView

@available(iOS 14.0, *)
extension TemplatesListView {
    
    struct AddNewItemView: View {
        
        let viewModel: TemplatesListViewModel.ItemViewModel
        @Binding var style: TemplatesListViewModel.Style
        @Namespace var namespace

        var body: some View {
            
            ZStack {
                
                TemplatesListView.ItemBackgroundView()
                
                switch style {
                case .list:
                    
                    HStack {
                        
                        TemplatesListView.ItemIconView(image: viewModel.image, style: style)
                            .matchedGeometryEffect(id: "icon", in: namespace)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            
                            TemplatesListView.ItemTitleView(title: viewModel.title, style: style)
                                .matchedGeometryEffect(id: "title", in: namespace)
                            
                            TemplatesListView.ItemSubtitleView(subtitle: viewModel.subTitle, style: style)
                                .matchedGeometryEffect(id: "subtitle", in: namespace)
                        }
                        
                        Spacer()
                    }
                    .padding(16)
                    .frame(height: 72)

                case .tiles:
                    
                    VStack(spacing: 8) {
                        
                        TemplatesListView.ItemIconView(image: viewModel.image, style: style)
                            .padding(.top, 16)
                            .matchedGeometryEffect(id: "icon", in: namespace)
                        
                        TemplatesListView.ItemTitleView(title: viewModel.title, style: style)
                            .matchedGeometryEffect(id: "title", in: namespace)
                        
                        TemplatesListView.ItemSubtitleView(subtitle: viewModel.subTitle, style: style)
                            .matchedGeometryEffect(id: "subtitle", in: namespace)
                            .padding(.bottom, 34)
                    }
                }
            }
            .onTapGesture {
                
                viewModel.tapAction(0)
            }
        }
    }
}

//MARK: - TemplateItemView

@available(iOS 14.0, *)
extension TemplatesListView {
    
    //TODO: - extract to separate file
    struct TemplateItemView: View {
        
        @ObservedObject var viewModel: TemplatesListViewModel.ItemViewModel
        @Binding var style: TemplatesListViewModel.Style
        @Namespace var namespace
        
        private var roundButtonViewModel: TemplatesListViewModel.ItemViewModel.ToggleRoundButtonViewModel? {
            
            guard case .select(let roundButtonViewModel) = viewModel.state else {
                return nil
            }
            
            return roundButtonViewModel
        }
        
        private var deleteButtonViewModel: TemplatesListViewModel.ItemViewModel.DeleteButtonViewModel? {
            
            guard case .delete(let deleteButtonViewModel) = viewModel.state else {
                return nil
            }
            
            return deleteButtonViewModel
        }
        
        private var deletingProgressViewModel: TemplatesListViewModel.ItemViewModel.DeletingProgressViewModel? {
            
            guard case .deleting(let deletingProgressViewModel) = viewModel.state else {
                return nil
            }
            
            return deletingProgressViewModel
        }
        
        var mainViewOffset: CGFloat {
            
            switch viewModel.state {
            case .delete: return -130
            default: return 0
            }
        }
        
        var body: some View {
            
            ZStack {
                
                // bottom view
                TemplatesListView.ItemBottomView {
                    
                    deleteButtonViewModel?.action(viewModel.id)
                }
                
                // main view
                ZStack {
                    
                    // background
                    TemplatesListView.ItemBackgroundView()
                    
                    switch style {
                    case .list:
                        
                        HStack(spacing: 16) {
                            
                            if let deletingProgressViewModel = deletingProgressViewModel {
                                
                                // progress
                                TemplatesListView.ItemProgressView(progress: deletingProgressViewModel.progress, title: deletingProgressViewModel.countTitle)
                                    .matchedGeometryEffect(id: "icon", in: namespace)
                                
                                HStack {
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        
                                        // title
                                        TemplatesListView.ItemTitleView(title: viewModel.title, style: style)
                                            .matchedGeometryEffect(id: "title", in: namespace)
                                        
                                        // subtitle
                                        TemplatesListView.ItemSubtitleView(subtitle: viewModel.subTitle, style: style)
                                            .matchedGeometryEffect(id: "subtitle", in: namespace)
                                    }
                                }
                                
                                Spacer()
                                
                                // cancel button
                                TemplatesListView.ItemCancelButtonView(title: deletingProgressViewModel.cancelButton.title) {
                                    
                                    deletingProgressViewModel.cancelButton.action(viewModel.id)
                                }
                                .matchedGeometryEffect(id: "amount", in: namespace)
                                
                            } else {
                                
                                // icon
                                TemplatesListView.ItemIconView(image: viewModel.image, logoImage: viewModel.logoImage, style: style)
                                    .matchedGeometryEffect(id: "icon", in: namespace)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    
                                    HStack {
                                        
                                        // title
                                        TemplatesListView.ItemTitleView(title: viewModel.title, style: style)
                                            .matchedGeometryEffect(id: "title", in: namespace)
                                        
                                        Spacer()
                                        
                                        // amount
                                        TemplatesListView.ItemAmountView(amount: viewModel.ammount)
                                            .matchedGeometryEffect(id: "amount", in: namespace)
                                    }
                                    
                                    // subtitle
                                    TemplatesListView.ItemSubtitleView(subtitle: viewModel.subTitle, style: style)
                                        .matchedGeometryEffect(id: "subtitle", in: namespace)
                                }
                            }
                        }
                        .padding(16)
                        .frame(height: 72)
                        
                    case .tiles:
                        
                        VStack(spacing: 8) {
                            
                            if let deletingProgressViewModel = deletingProgressViewModel {
                                
                                // progress
                                TemplatesListView.ItemProgressView(progress: deletingProgressViewModel.progress, title: deletingProgressViewModel.countTitle)
                                    .padding(.top, 16)
                                    .matchedGeometryEffect(id: "icon", in: namespace)
                                
                            } else {
                                
                                // icon
                                TemplatesListView.ItemIconView(image: viewModel.image, logoImage: viewModel.logoImage, style: style)
                                    .padding(.top, 16)
                                    .matchedGeometryEffect(id: "icon", in: namespace)
                            }
                            
                            // title
                            TemplatesListView.ItemTitleView(title: viewModel.title, style: style)
                                .matchedGeometryEffect(id: "title", in: namespace)
                            
                            // subtitle
                            TemplatesListView.ItemSubtitleView(subtitle: viewModel.subTitle, style: style)
                                .matchedGeometryEffect(id: "subtitle", in: namespace)
                            
                            if let deletingProgressViewModel = deletingProgressViewModel {

                                // cancel button
                                TemplatesListView.ItemCancelButtonView(title: deletingProgressViewModel.cancelButton.title) {
                                    
                                    deletingProgressViewModel.cancelButton.action(viewModel.id)
                                }
                                .padding(.top, 10)
                                .padding(.bottom, 16)
                                .matchedGeometryEffect(id: "amount", in: namespace)
                                
                            } else {

                                // amount
                                TemplatesListView.ItemAmountView(amount: viewModel.ammount)
                                    .padding(.top, 10)
                                    .padding(.bottom, 16)
                                    .matchedGeometryEffect(id: "amount", in: namespace)
                            }
                        }
                    }
                    
                    // round selection indicator
                    if let  roundButtonViewModel = roundButtonViewModel {
                        
                        TemplatesListView.SelectItemVew(isSelected: roundButtonViewModel.isSelected)
                            .offset(.init(width: 8, height: 8))
                    }
                }
                .offset(.init(width: mainViewOffset, height: 0))
                .onTapGesture {
                    
                    if let  roundButtonViewModel = roundButtonViewModel {
                        
                        roundButtonViewModel.action(viewModel.id)
                        
                    } else {
                        
                        viewModel.tapAction(viewModel.id)
                    }
                }
            }
            .modifier(SwipeSidesModifier(leftAction: {
                
                guard style == .list else {
                    return
                }
                viewModel.swipeLeft()
                
            }, rightAction:viewModel.swipeRight))
        }
    }
}

//MARK: - TemplateItemViewLegacy

extension TemplatesListView {
    
    //TODO: drop iOS 13 and remove it
    struct TemplateItemViewLegacy: View {
        
        @ObservedObject var viewModel: TemplatesListViewModel.ItemViewModel
        @Binding var style: TemplatesListViewModel.Style

        private var roundButtonViewModel: TemplatesListViewModel.ItemViewModel.ToggleRoundButtonViewModel? {
            
            guard case .select(let roundButtonViewModel) = viewModel.state else {
                return nil
            }
            
            return roundButtonViewModel
        }
        
        private var deleteButtonViewModel: TemplatesListViewModel.ItemViewModel.DeleteButtonViewModel? {
            
            guard case .delete(let deleteButtonViewModel) = viewModel.state else {
                return nil
            }
            
            return deleteButtonViewModel
        }
        
        private var deletingProgressViewModel: TemplatesListViewModel.ItemViewModel.DeletingProgressViewModel? {
            
            guard case .deleting(let deletingProgressViewModel) = viewModel.state else {
                return nil
            }
            
            return deletingProgressViewModel
        }
        
        var mainViewOffset: CGFloat {
            
            switch viewModel.state {
            case .delete: return -130
            default: return 0
            }
        }
        
        var body: some View {
            
            ZStack {
                
                // bottom view
                TemplatesListView.ItemBottomView {
                    
                    deleteButtonViewModel?.action(viewModel.id)
                }
                
                // main view
                ZStack {
                    
                    // background
                    TemplatesListView.ItemBackgroundView()
                    
                    HStack(spacing: 16) {
                        
                        if let deletingProgressViewModel = deletingProgressViewModel {
                            
                            // progress
                            TemplatesListView.ItemProgressView(progress: deletingProgressViewModel.progress, title: deletingProgressViewModel.countTitle)
                            
                            HStack {
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    
                                    // title
                                    TemplatesListView.ItemTitleView(title: viewModel.title, style: style)
                                    
                                    // subtitle
                                    TemplatesListView.ItemSubtitleView(subtitle: viewModel.subTitle, style: style)
                                }
                            }
                            
                            Spacer()
                            
                            // cancel button
                            TemplatesListView.ItemCancelButtonView(title: deletingProgressViewModel.cancelButton.title) {
                                
                                deletingProgressViewModel.cancelButton.action(viewModel.id)
                            }
                            
                        } else {
                            
                            // icon
                            TemplatesListView.ItemIconView(image: viewModel.image, logoImage: viewModel.logoImage, style: style)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                
                                HStack {
                                    
                                    // title
                                    TemplatesListView.ItemTitleView(title: viewModel.title, style: style)
                                    
                                    Spacer()
                                    
                                    // amount
                                    TemplatesListView.ItemAmountView(amount: viewModel.ammount)
                                }
                                
                                // subtitle
                                TemplatesListView.ItemSubtitleView(subtitle: viewModel.subTitle, style: style)
                            }
                        }
                    }
                    .padding(16)
                    .frame(height: 72)
                    
                    // round selection indicator
                    if let  roundButtonViewModel = roundButtonViewModel {
                        
                        TemplatesListView.SelectItemVew(isSelected: roundButtonViewModel.isSelected)
                            .offset(.init(width: 8, height: 8))
                    }
                }
                .offset(.init(width: mainViewOffset, height: 0))
                .onTapGesture {
                    
                    if let  roundButtonViewModel = roundButtonViewModel {
                        
                        roundButtonViewModel.action(viewModel.id)
                        
                    } else {
                        
                        viewModel.tapAction(viewModel.id)
                    }
                }
            }
            .modifier(SwipeSidesModifier(leftAction: {
                
                guard style == .list else {
                    return
                }
                viewModel.swipeLeft()
                
            }, rightAction:viewModel.swipeRight))
        }
    }
}

//MARK: - AddNewItemViewLegacy

extension TemplatesListView {
    
    //TODO: drop iOS 13 and remove it
    struct AddNewItemViewLegacy: View {
        
        let viewModel: TemplatesListViewModel.ItemViewModel
        @Binding var style: TemplatesListViewModel.Style

        var body: some View {
            
            ZStack {
                
                TemplatesListView.ItemBackgroundView()
                
                switch style {
                case .list:
                    
                    HStack {
                        
                        TemplatesListView.ItemIconView(image: viewModel.image, style: style)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            
                            TemplatesListView.ItemTitleView(title: viewModel.title, style: style)
                            
                            TemplatesListView.ItemSubtitleView(subtitle: viewModel.subTitle, style: style)
                        }
                        
                        Spacer()
                    }
                    .padding(16)
                    .frame(height: 72)

                case .tiles:
                    
                    VStack(spacing: 8) {
                        
                        TemplatesListView.ItemIconView(image: viewModel.image, style: style)
                            .padding(.top, 16)
                        
                        TemplatesListView.ItemTitleView(title: viewModel.title, style: style)
                        
                        TemplatesListView.ItemSubtitleView(subtitle: viewModel.subTitle, style: style)
                            .padding(.bottom, 34)
                    }
                }
            }
            .onTapGesture {
                
                viewModel.tapAction(0)
            }
        }
    }
}

//MARK: - TemplateItemView components

extension TemplatesListView {
    
    struct ItemBackgroundView: View {
        
        var body: some View {
            
            Color(hex: "F6F6F7")
                .cornerRadius(16)
        }
    }
    
    struct ItemIconView: View {
        
        let image: Image
        var logoImage: Image? = nil
        var style: TemplatesListViewModel.Style = .list
        
        private var side: CGFloat {
            
            switch style {
            case .list: return 40
            case .tiles: return 56
            }
        }
 
        var body: some View {
            
            ZStack(alignment: .topTrailing) {
                
                image
                    .resizable()
                    .frame(width: side, height: side)
                
                if let logoImage = logoImage {
                    
                    logoImage
                        .resizable()
                        .frame(width: 24, height: 24)
                        .offset(.init(width: 8, height: 0))
                }
            }
        }
    }
    
    struct ItemTitleView: View {
        
        let title: String
        var style: TemplatesListViewModel.Style = .list
        
        var body: some View {
            
            switch style {
            case .list:
                Text(title)
                    .font(Font.custom("Inter-Medium", size: 16))
                    .foregroundColor(.textSecondary)
                    .lineLimit(1)
                
            case .tiles:
                Text(title)
                    .font(.textBodyMM14200())
                    .foregroundColor(.textSecondary)
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .padding(.horizontal)
            }
        }
    }
    
    struct ItemSubtitleView: View {
        
        let subtitle: String
        var style: TemplatesListViewModel.Style = .list
        
        var body: some View {
            
            switch style {
            case .list:
                Text(subtitle)
                    .font(.textBodySR12160())
                    .foregroundColor(.textPlaceholder)
                    .lineLimit(1)
                
            case .tiles:
                Text(subtitle)
                    .font(.textBodySR12160())
                    .foregroundColor(.textPlaceholder)
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .padding(.horizontal)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }
        }
    }
    
    struct ItemAmountView: View {
        
        let amount: String
        
        var body: some View {
            
            Text(amount)
                .font(Font.custom("Inter-Medium", size: 16))
                .foregroundColor(.textSecondary)
        }
    }
    
    struct ItemBottomView: View {
        
        let action: () -> Void
        
        var body: some View {
            
            Group {
               
                // bottom view background
                Color.black.cornerRadius(17)
                
                // delete button
                HStack {
                    
                    Spacer()
                    
                    Button {
                        
                        action()
                        
                    } label: {
                        
                        VStack(spacing: 4) {
                            
                            Image("trash_empty")
                                .resizable()
                                .renderingMode(.template)
                                .frame(width: 24, height: 24)
                            
                            Text("Удалить")
                                .font(.textBodySM12160())
                        }
                        .foregroundColor(.white)
                    }
                    .padding(.trailing, 35)
                }
                .frame(height: 72)
            }
        }
    }
    
    struct ItemProgressView: View {
        
        let progress: Double
        let title: String
        var style: TemplatesListViewModel.Style = .list
        
        private var height: CGFloat {
            
            switch style {
            case .list: return 40
            case .tiles: return 56
            }
        }
        
        private var width: CGFloat {
            
            switch style {
            case .list: return 40
            case .tiles: return 56
            }
        }
        
        var body: some View {
            
            ZStack {
                
                CircleProgressView(progress: .constant(progress), color: Color(hex: "#999999"), backgroundColor: Color(hex: "#EAEBEB"))
                    .frame(width: width, height: height)
                
                Text(title)
                    .font(Font.custom("Inter-Medium", size: 16))
                    .foregroundColor(.textPlaceholder)
            }
        }
    }
    
    struct ItemCancelButtonView: View {
        
        let title: String
        let action: () -> Void
        
        var body: some View {
            
            Button {
                
                action()
                
            } label: {
                
                Text(title)
                    .font(.textBodyMM14200())
                    .foregroundColor(.textSecondary)
            }
        }
    }
}

//MARK: - Helpers

struct TemplatesListView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        Group {
            
            NavigationView {
                TemplatesListView(viewModel: .sampleComplete )
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

struct ToolbarFindView: View {
    
    @State var searchString: String = ""
    
    var body: some View {
       
        HStack {
            Image(systemName: "sun.min.fill")
            
            TextField("Имя шаблона", text: $searchString)
            
            
            Text("Title").font(.headline)
        }
    }
}
