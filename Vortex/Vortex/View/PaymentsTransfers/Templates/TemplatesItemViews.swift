//
//  TemplatesItemViews.swift
//  ForaBank
//
//  Created by Dmitry Martynov on 24.04.2023.
//

import SwiftUI
import UIPrimitives

extension TemplatesListView {
    
    struct TemplateItemView: View {
        
        @ObservedObject var viewModel: TemplatesListViewModel.ItemViewModel
        @Binding var style: TemplatesListViewModel.Style
        @Binding var editMode: EditMode
        
        var body: some View {
                        
            switch viewModel.state {
            case .normal, .processing:
                            
                TemplatesListView.NormalItemView
                    .init(avatar: viewModel.avatar,
                          topImage: viewModel.topImage,
                          title: viewModel.title,
                          subTitle: viewModel.subTitle,
                          amount: viewModel.amount,
                          style: style, editMode: $editMode)
                    .shimmering(active: viewModel.state.isProcessing, bounce: true)
                    .onTapGesture {
                        if !viewModel.state.isProcessing {
                            viewModel.tapAction(viewModel.id)
                        }
                    }
                
            case let .deleting(deletingProgressViewModel):
                            
                TemplatesListView.DeletingProgressView
                    .init(viewModel: deletingProgressViewModel)
                            
            case let .select(roundButtonViewModel):
                            
                TemplatesListView.NormalItemView
                    .init(avatar: viewModel.avatar,
                          topImage: viewModel.topImage,
                          title: viewModel.title,
                          subTitle: viewModel.subTitle,
                          amount: viewModel.amount,
                          style: style, editMode: .constant(.inactive))
                    .overlay13(alignment: .topLeading) {
                                   
                        TemplatesListView.SelectItemVew
                            .init(isSelected: roundButtonViewModel.isSelected)
                            .offset(x: 8, y: 14)
                    }
                    .onTapGesture { roundButtonViewModel.action(viewModel.id) }
                            
            case let .delete(itemActionViewModel):
                            
                TemplatesListView.NormalItemView
                    .init(avatar: viewModel.avatar,
                          topImage: viewModel.topImage,
                          title: viewModel.title,
                          subTitle: viewModel.subTitle,
                          amount: viewModel.amount,
                          style: style, editMode: .constant(.inactive))
                    .offset(x: -100, y: 0)
                            
            } //switch item state
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
                    .frame(height: 72)
                
            case .tiles:
                
                RoundedRectangle(cornerRadius: 12)
                    .foregroundColor(.mainColorsGrayMedium.opacity(0.4))
                    .frame(height: 188)
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
                    
                    TemplatesListView.ItemIconView(avatar: viewModel.avatar,
                                                   topImage: viewModel.topImage,
                                                   style: style)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        
                        TemplatesListView.ItemTitleView(title: viewModel.title, style: style)
                        
                        TemplatesListView.ItemSubtitleView(subtitle: viewModel.subTitle, style: style)
                    }
                }
                .padding(.horizontal)
                .frame(height: 72)
                .contentShape(Rectangle())
                .onTapGesture { viewModel.tapAction(0) }
                
            case .tiles:
                
                ZStack {
                    
                    Color.mainColorsGrayLightest.cornerRadius(16)
                    
                    VStack(spacing: 0) {
                        
                        TemplatesListView.ItemIconView(avatar: viewModel.avatar,
                                                       topImage: viewModel.topImage,
                                                       style: style)
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

extension TemplatesListView.NormalItemView {
    
    struct ItemPaddings: ViewModifier {
        
        @Binding var editMode: EditMode
        
        func body(content: Content) -> some View {
            
            if #available(iOS 16.0, *) {
                content
                    .padding(.horizontal)
            } else {
                content
                    .padding(.leading, editMode == .active ? 0 : 16 )
                    .padding(.trailing, 16)
            }
        }
    }
}

//MARK: - TemplateItemViews components

extension TemplatesListView {
    
    struct NormalItemView: View {
        
        let avatar: TemplatesListViewModel.ItemViewModel.Avatar
        let topImage: Image?
        let title: String
        let subTitle: String
        let amount: String
        let style: TemplatesListViewModel.Style
        @Binding var editMode: EditMode
        
        var body: some View {
            
            switch style {
            case .list:
                
                HStack(spacing: 16) {
                    
                    TemplatesListView.ItemIconView(avatar: avatar,
                                                   topImage: topImage,
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
                .modifier(Self.ItemPaddings(editMode: $editMode))
                .frame(height: 84)
                
            case .tiles:
                
                ZStack {
                    
                    Color.mainColorsGrayLightest.cornerRadius(16)
                    
                    VStack(spacing: 0) {
                        
                        TemplatesListView.ItemIconView(avatar: avatar,
                                                       topImage: topImage,
                                                       style: style)
                            .padding(.vertical, 16)
                        
                        TemplatesListView.ItemTitleView(title: title,
                                                        style: style)
                            .padding(.bottom, 4)
                        
                        
                        TemplatesListView.ItemSubtitleView(subtitle: subTitle,
                                                           style: style)
                        
                        TemplatesListView.ItemAmountView(amount: amount)
                            .padding(.bottom, 16)
                        
                    }
                }
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
                    .disabled(viewModel.isDisableCancelButton)
                }
                .padding(16)
                .frame(height: 84)
                .shimmering(active: viewModel.isDisableCancelButton, bounce: true)
                
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
        
        let avatar: TemplatesListViewModel.ItemViewModel.Avatar
        let topImage: Image?
        let style: TemplatesListViewModel.Style
        
        private var side: (main: CGFloat, top: CGFloat) {
            
            switch style {
            case .list: return (40, 20)
            case .tiles: return (56, 24)
            }
        }
 
        var body: some View {
            
            ZStack(alignment: .topTrailing)  {
                
                switch avatar {
                case let .image(image):
                    
                    image
                        .renderingMode(.original)
                        .resizable()
                        .scaledToFit()
                        .clipShape(Circle())
                        .frame(height: side.main)
                    
                case let .text(text):
                    
                    Circle()
                        .fill(Color.mainColorsGrayMedium.opacity(0.4))
                        .frame(width: side.main, height: side.main)
                        .overlay13 {
                            Text(text)
                                .font(.textH4M16240())
                                .foregroundColor(.textPlaceholder)
                        }
                
                case .placeholder:
                    
                    Circle()
                        .fill(Color.mainColorsGrayMedium.opacity(0.4))
                        .frame(width: side.main, height: side.main)
                        .shimmering(bounce: true)
                }
                
                if let topImage = topImage {
                    
                    topImage
                        .renderingMode(.original)
                        .resizable()
                        .clipShape(Circle())
                        .frame(width: side.top, height: side.top)
                        .offset(x: 9, y: -2)
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
                        .listRowInsets(EdgeInsets(top: 6, leading: 0, bottom: 6, trailing: 0))
                        .listRowBackground(TemplatesListView.BackgroundListView())
                }
            }
            .listStyle(.plain)
            .environment(\.editMode, .constant(.inactive))
            .padding(.horizontal)
        }
    }
}
