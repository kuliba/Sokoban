//
//  TemplatesItemViews.swift
//  ForaBank
//
//  Created by Dmitry Martynov on 24.04.2023.
//

import SwiftUI

extension TemplatesListView {
    
    struct TemplateItemView: View {
        
        @ObservedObject var viewModel: TemplatesListViewModel.ItemViewModel
        @Binding var style: TemplatesListViewModel.Style
        @Binding var editMode: EditMode
        
        var body: some View {
                        
            switch viewModel.state {
            case .normal:
                            
                TemplatesListView.NormalItemView
                    .init(image: viewModel.image,
                          logoImage: viewModel.logoImage,
                          title: viewModel.title,
                          subTitle: viewModel.subTitle,
                          amount: viewModel.ammount,
                          style: style)
                    .onTapGesture { viewModel.tapAction(viewModel.id) }
                
            case let .deleting(deletingProgressViewModel):
                            
                TemplatesListView.DeletingProgressView
                    .init(viewModel: deletingProgressViewModel,
                          title: viewModel.title,
                          subTitle: viewModel.subTitle,
                          style: style,
                          id: viewModel.id)
                            
            case let .select(roundButtonViewModel):
                            
                TemplatesListView.NormalItemView
                    .init(image: viewModel.image,
                          logoImage: viewModel.logoImage,
                          title: viewModel.title,
                          subTitle: viewModel.subTitle,
                          amount: viewModel.ammount,
                          style: style)
                    .overlay13 {
                                   
                        TemplatesListView.SelectItemVew
                            .init(isSelected: roundButtonViewModel.isSelected)
                            .offset(x: 6, y: 12)
                    }
                    .onTapGesture { roundButtonViewModel.action(viewModel.id) }
                            
            case let .delete(itemActionViewModel):
                            
                TemplatesListView.NormalItemView
                    .init(image: viewModel.image,
                          logoImage: viewModel.logoImage,
                          title: viewModel.title,
                          subTitle: viewModel.subTitle,
                          amount: viewModel.ammount,
                          style: style)
                    .offset(x: -100, y: 0)
                            
            } //switch item state
          

//            .modifier(SwipeSidesModifier(leftAction: {
//
//                guard style == .list else {
//                    return
//                }
//                viewModel.swipeLeft()
//
//            }, rightAction:viewModel.swipeRight))
        }
    }
}

//MARK: - AddNewItemView

extension TemplatesListView {
    
    struct AddNewItemView: View {
        
        let viewModel: TemplatesListViewModel.ItemViewModel
        @Binding var style: TemplatesListViewModel.Style

        var body: some View {
                
            ZStack {
                
                Color.mainColorsGrayLightest.cornerRadius(16)
                
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
                    .frame(height: 84)
                    
                case .tiles:
                    
                    VStack(spacing: 8) {
                            
                        TemplatesListView.ItemIconView(image: viewModel.image, style: style)
                            .padding(.top, 16)
                            
                        TemplatesListView.ItemTitleView(title: viewModel.title, style: style)
                            
                        TemplatesListView.ItemSubtitleView(subtitle: viewModel.subTitle, style: style)
                            .padding(.bottom, 34)
                    }
                } //switch
            }
            .onTapGesture { viewModel.tapAction(0) }
        }
    }
}

//MARK: - TemplateItemViews components

extension TemplatesListView {
    
    struct NormalItemView: View {
        
        let image: Image
        let logoImage: Image?
        let title: String
        let subTitle: String
        let amount: String
        let style: TemplatesListViewModel.Style
        
        var body: some View {
            
            switch style {
            case .list:
                
                HStack(spacing: 16) {
                    
                    TemplatesListView.ItemIconView(image: image,
                                                   logoImage: logoImage,
                                                   style: style)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        
                        HStack {
                            
                            TemplatesListView.ItemTitleView(title: title,
                                                            style: style)
                            Spacer()
                            
                            TemplatesListView.ItemAmountView(amount: amount)
                        }
                        
                        TemplatesListView.ItemSubtitleView(subtitle: subTitle,
                                                           style: style)
                    }
                }
                .padding(16)
                .frame(height: 84)
                
            case .tiles:
                
                ZStack {
                    
                    Color.mainColorsGrayLightest.cornerRadius(16)
                    
                    VStack(spacing: 8) {
                        
                        TemplatesListView.ItemIconView(image: image,
                                                       logoImage: logoImage,
                                                       style: style)
                            .padding(.top, 16)
                        
                        TemplatesListView.ItemTitleView(title: title,
                                                        style: style)
                        
                        TemplatesListView.ItemSubtitleView(subtitle: subTitle,
                                                           style: style)
                        
                        TemplatesListView.ItemAmountView(amount: amount)
                            .padding(.top, 10)
                            .padding(.bottom, 16)
                    }
                }
            } //switch style
            
        }
    }
    
    struct DeletingProgressView: View {
        
        let viewModel: TemplatesListViewModel.ItemViewModel.DeletingProgressViewModel
        let title: String
        let subTitle: String
        let style: TemplatesListViewModel.Style
        let id: Int
        
        var body: some View {
            
            switch style {
            case .list:
                
                HStack(spacing: 16) {
                    
                    TemplatesListView.ItemProgressView(progress: viewModel.progress, title: viewModel.countTitle)
                    
                    HStack {
                        
                        VStack(alignment: .leading, spacing: 4) {
                            
                            TemplatesListView.ItemTitleView(title: title, style: style)
                            
                            TemplatesListView.ItemSubtitleView(subtitle: subTitle, style: style)
                        }
                    }
                    
                    Spacer()
                    
                    TemplatesListView.ItemCancelButtonView(title: viewModel.cancelButton.title) {
                        
                        viewModel.cancelButton.action(id)
                    }
                }
                .padding(16)
                .frame(height: 84)
                
            case .tiles:
                
                ZStack {
                    
                    Color.mainColorsGrayLightest
                        .cornerRadius(16)
                    
                    VStack(spacing: 8) {
                        
                        TemplatesListView.ItemProgressView(progress: viewModel.progress,
                                                           title: viewModel.countTitle)
                        .padding(.top, 16)
                        
                        TemplatesListView.ItemTitleView(title: title, style: style)
                        
                        TemplatesListView.ItemSubtitleView(subtitle: subTitle, style: style)
                        
                        TemplatesListView.ItemCancelButtonView(title: viewModel.cancelButton.title) {
                            
                            viewModel.cancelButton.action(id)
                        }
                        .padding(.top, 10)
                        .padding(.bottom, 16)
                    }
                }
                
            } //switch style
            
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

struct TemplatesItemView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        Group {
            
            //Tiles Items
            LazyVGrid(columns: [GridItem(.flexible(), spacing: 16),
                                GridItem(.flexible())], spacing: 16) {
                
                ForEach(TemplatesListViewModel.sampleItems3) { item in
                    
                    TemplatesListView.TemplateItemView(viewModel: item,
                                     style: .constant(.tiles),
                                     editMode: .constant(.inactive))
                    .contextMenu {
                        
                        Button(action: {}) {
                            Text("Переименовать")
                            Image.ic24Edit2
                        }
                        
                        Button(action: {}) {
                            Text("Удалить")
                            Image.ic24Trash
                        }
                    }
                }
            }
            //List Items
            List {
                
                ForEach(TemplatesListViewModel.sampleItems3) { item in
                    
                    TemplatesListView.TemplateItemView(viewModel: item,
                                                       style: .constant(.list),
                                                       editMode: .constant(.inactive))
                        .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                        .listRowBackground(
                            Color.mainColorsGrayLightest.cornerRadius(16)
                                .padding(.vertical,6)
                                .background(Color.white)
                        )
                }
                
            }
            .listStyle(.plain)
            .environment(\.editMode, .constant(.inactive))
            .padding(.horizontal)
        }
    }
}
