//
//  TemplatesItemViews.swift
//  ForaBank
//
//  Created by Dmitry Martynov on 24.04.2023.
//

import SwiftUI
import Shimmer

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
                    .init(viewModel: deletingProgressViewModel)
                            
            case let .select(roundButtonViewModel):
                            
                TemplatesListView.NormalItemView
                    .init(image: viewModel.image,
                          logoImage: viewModel.logoImage,
                          title: viewModel.title,
                          subTitle: viewModel.subTitle,
                          amount: viewModel.ammount,
                          style: style)
                    .overlay13(alignment: .topLeading) {
                                   
                        TemplatesListView.SelectItemVew
                            .init(isSelected: roundButtonViewModel.isSelected)
                            .offset(x: 8, y: 14)
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



extension TemplatesListView {
    
    struct PlaceholderItemView: View {
        
        @Binding var style: TemplatesListViewModel.Style
        
        var body: some View {
            
            switch style {
            case .list:
                
                RoundedRectangle(cornerRadius: 12)
                    .foregroundColor(.mainColorsGrayMedium.opacity(0.4))
                    .frame(height: 84)
                    .shimmering(active: true, bounce: true)
                
            case .tiles:
                
                RoundedRectangle(cornerRadius: 12)
                    .foregroundColor(.mainColorsGrayMedium.opacity(0.4))
                    .frame(height: 188)
                    .shimmering(active: true, bounce: true)
            }
        }
    }
    
    struct AddNewItemView: View {
        
        let viewModel: TemplatesListViewModel.ItemViewModel
        @Binding var style: TemplatesListViewModel.Style

        var body: some View {
                
            switch style {
            case .list:
                
                HStack(spacing: 16) {
                    
                    TemplatesListView.ItemIconView(image: viewModel.image, style: style)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        
                        TemplatesListView.ItemTitleView(title: viewModel.title, style: style)
                        
                        TemplatesListView.ItemSubtitleView(subtitle: viewModel.subTitle, style: style)
                    }
                }
                .padding(.horizontal)
                .frame(height: 84)
                .onTapGesture { viewModel.tapAction(0) }
                
            case .tiles:
                
                ZStack {
                    
                    Color.mainColorsGrayLightest.cornerRadius(16)
                    
                    VStack(spacing: 0) {
                        
                        TemplatesListView.ItemIconView(image: viewModel.image, style: style)
                            .padding(.vertical, 16)
                        
                        TemplatesListView.ItemTitleView(title: viewModel.title, style: style)
                            .padding(.bottom, 4)
                        
                        TemplatesListView.ItemSubtitleView(subtitle: viewModel.subTitle, style: style)
                            .padding(.bottom, 28)
                    }
                }
                .frame(height: 188)
                .onTapGesture { viewModel.tapAction(0) }
            } //switch
            
        }
    }
}

//MARK: - TemplateItemViews components

extension TemplatesListView {
    
    struct NormalItemView: View {
        
        let image: Image?
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
                            
                            TemplatesListView.ItemTitleView(title: title, style: style)
                            
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
                    
                    VStack(spacing: 0) {
                        
                        TemplatesListView.ItemIconView(image: image,
                                                       logoImage: logoImage,
                                                       style: style)
                        .padding(.vertical, 16)
                        
                        TemplatesListView.ItemTitleView(title: title,
                                                        style: style)
                        .padding(.bottom, 4)
                        
                        
                        TemplatesListView.ItemSubtitleView(subtitle: subTitle,
                                                           style: style)
                        //.padding(.bottom, 4)
                        
                        TemplatesListView.ItemAmountView(amount: amount)
                            .padding(.bottom, 16)
                        
                    }
                }//.frame(height: 188)
            } //switch style
            
        }
    }
    
    struct SelectItemVew: View {
        
        let isSelected: Bool
        var body: some View {
           
            if isSelected {
                        
                Image.ic16Check
                    .background(Circle()
                    .foregroundColor(.iconWhite)
                    .frame(width: 24, height: 24))
                        
            } else {
                        
                Circle()
                    .foregroundColor(.iconWhite)
                    .frame(width: 24, height: 24)
            }
        }
    }
    
    struct DeletingProgressView: View {
        
        @ObservedObject var viewModel: TemplatesListViewModel.ItemViewModel.DeletingProgressViewModel
        
        var body: some View {
            
            switch viewModel.style {
            case .list:
                
                HStack(spacing: 16) {
                    
                    TemplatesListView.ItemProgressView
                        .init(viewModel: .init(progress: viewModel.progress,
                                               title: viewModel.countTitle,
                                               style: viewModel.style))
                    HStack {
                        
                        VStack(alignment: .leading, spacing: 4) {
                            
                            TemplatesListView.ItemTitleView(title: viewModel.title,
                                                            style: viewModel.style)
                            
                            TemplatesListView.ItemSubtitleView(subtitle: viewModel.subTitle,
                                                               style: viewModel.style)
                        }
                    }
                    
                    Spacer()
                    
                    TemplatesListView.ItemCancelButtonView(title: viewModel.cancelButton.title) {
                        
                        viewModel.cancelButton.action(viewModel.id)
                    }
                }
                .padding(16)
                .frame(height: 84)
                
            case .tiles:
                
                ZStack {
                    
                    Color.mainColorsGrayLightest
                        .cornerRadius(16)
                    
                    VStack(spacing: 0) {
                        
                        TemplatesListView.ItemProgressView
                            .init(viewModel: .init(progress: viewModel.progress,
                                                   title: viewModel.countTitle,
                                                   style: viewModel.style))
                            .padding(.vertical, 16)
                        
                        TemplatesListView.ItemTitleView(title: viewModel.title,
                                                        style: viewModel.style)
                        .padding(.bottom, 4)
                        
                        TemplatesListView.ItemSubtitleView(subtitle: viewModel.subTitle,
                                                           style: viewModel.style)
                        
                        TemplatesListView.ItemCancelButtonView(title: viewModel.cancelButton.title) {
                            
                            viewModel.cancelButton.action(viewModel.id)
                        }
                        .padding(.bottom, 16)
                    }
                }
                
            } //switch style
            
        }
    }
    
    struct ItemIconView: View {
        
        let image: Image?
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
                
                if let image = image {
                    
                    image
                        .resizable()
                        .renderingMode(.original)
                        .frame(width: side, height: side)
                } else {
                    
                    Circle()
                        .foregroundColor(.mainColorsGrayLightest)
                        .frame(width: side, height: side)
                }
                
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
                    .font(.textBodyMM14200())
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
                    .lineLimit(2)
                
            case .tiles:
                Text(subtitle)
                    .font(.textBodySR12160())
                    .foregroundColor(.textPlaceholder)
                    .lineLimit(3)
                    .truncationMode(.tail)
                    .padding(.horizontal)
                    .multilineTextAlignment(.center)
                    .lineSpacing(3)
                    .frame(height: 50, alignment: .top)
            }
        }
    }
    
    struct ItemAmountView: View {
        
        let amount: String
        
        var body: some View {
            
            Text(amount)
                .font(.textH4M16240())
                .foregroundColor(.textSecondary)
        }
    }
    
    struct ItemProgressView: View {
        
        @ObservedObject var viewModel: TemplatesListViewModel.ItemViewModel.ItemProgressViewModel
        
        var body: some View {
            
            ZStack {
                
                Circle()
                    .stroke(lineWidth: 2)
                    .foregroundColor(.bordersDivider)
                
                Circle()
                    .trim(from: 0, to:  1 / CGFloat(viewModel.maxCount) * CGFloat(viewModel.progress))
                    .stroke(Color.mainColorsGray,
                            style: StrokeStyle(lineWidth: 2,
                                               lineCap: CGLineCap.round))
                    .rotationEffect(Angle.degrees(-90))
                    
                Text(viewModel.title)
                    .font(.textH4M16240())
                    .foregroundColor(.textPlaceholder)
            }
            .frame(width: viewModel.width, height: viewModel.height)
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
                
                TemplatesListView.AddNewItemView(viewModel: TemplatesListViewModel.sampleItems[4],
                                                 style: .constant(.tiles))
            }
            //List Items
            List {
                
                ForEach(TemplatesListViewModel.sampleItems) { item in
                    
                    TemplatesListView.TemplateItemView(viewModel: item,
                                                       style: .constant(.list),
                                                       editMode: .constant(.inactive))
                        .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                        .listRowBackground(
                            Color.mainColorsGrayLightest.cornerRadius(16)
                                .padding(.vertical, 6)
                                .background(Color.white)
                        )
                }
                
                TemplatesListView.AddNewItemView(viewModel: TemplatesListViewModel.sampleItems[4],
                                                 style: .constant(.list))
                .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                .listRowBackground(
                    Color.mainColorsGrayLightest.cornerRadius(16)
                        .padding(.vertical, 6)
                        .background(Color.white)
                )
                
            }
            .listStyle(.plain)
            .environment(\.editMode, .constant(.inactive))
            .padding(.horizontal)
        }
    }
}
