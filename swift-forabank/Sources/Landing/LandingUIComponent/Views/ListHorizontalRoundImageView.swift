//
//  ListHorizontalRoundImageView.swift
//  
//
//  Created by Andryusina Nataly on 27.08.2023.
//

import SwiftUI
import Combine

typealias ComponentLHRI = UILanding.List.HorizontalRoundImage
typealias ConfigLHRI = ComponentLHRI.Config
typealias SelectDetail = (DetailDestination?) -> Void

struct ListHorizontalRoundImageView: View {
    
    @ObservedObject var model: ViewModel
    let config: ConfigLHRI
    
    let selectDetail: SelectDetail
    
    var body: some View {
        
        ZStack {
            
            RoundedRectangle(cornerRadius: config.cornerRadius)
                .foregroundColor(config.backgroundColor)
            
            VStack(alignment: .leading, spacing: config.spacing) {
                
                model.data.title.map {
                    
                    Text($0)
                        .font(config.title.font)
                        .foregroundColor(config.title.color)
                        .padding(.leading, config.paddings.horizontal)
                }
                
                ScrollView(.horizontal, showsIndicators: false) {
                    
                    HStack {
                        
                        ForEach(model.data.list.indices, id: \.self) { index in
                            
                            let item = model.data.list[index]
                            itemView(item: item)
                                .padding(.trailing, index == model.data.list.count - 1 ? config.paddings.vStackContentHorizontal : 0)
                                .accessibilityIdentifier("HorisontalItem")
                        }
                        
                    }
                }
                .padding(.leading, config.paddings.vStackContentHorizontal)
            }
        }
        .frame(height: config.height)
        .padding(.horizontal, config.paddings.horizontal)
        .padding(.vertical, config.paddings.vertical)
        .accessibilityIdentifier("HorizontalGroup")
    }
    
    private func itemView (item: ComponentLHRI.ListItem) -> some View {
        
        ItemView(
            item: item,
            config: config,
            image: model.image(byMd5Hash: item.imageMd5Hash),
            selectDetail: selectDetail
        )
    }
}

extension ListHorizontalRoundImageView {
    
    struct SubInfoView: View {
        
        let text: String
        let config: ConfigLHRI.Subtitle
        
        var body: some View {
            
            Text(text)
                .font(config.font)
                .foregroundColor(config.color)
                .padding(.horizontal, config.padding.horizontal)
                .padding(.vertical, config.padding.vertical)
                .background(config.background)
                .cornerRadius(config.cornerRadius)
                .frame(
                    maxWidth: .infinity,
                    maxHeight: .infinity,
                    alignment: .topTrailing)
                .accessibilityIdentifier("HorisontalSubInfo")
        }
    }
}

extension ListHorizontalRoundImageView {
    
    struct ItemView: View {
        
        let item: ComponentLHRI.ListItem
        let config: ConfigLHRI
        let image: Image?
        let selectDetail: (DetailDestination?) -> Void
        
        var body: some View {
            
            Button(action: { selectDetail(item.detailDestination) }) {
                
                ZStack {
                    
                    VStack(spacing: config.item.spacing) {
                        
                        switch image {
                        case .none:
                            Color.grayLightest
                                .cornerRadius(config.item.cornerRadius)
                                .frame(width: config.item.width, height: config.item.width)
                                .accessibilityIdentifier("HorisontalItemNoImage")
                            
                        case let .some(image):
                            image
                                .resizable()
                                .cornerRadius(config.item.cornerRadius)
                                .frame(width: config.item.width, height: config.item.width)
                                .accessibilityIdentifier("HorisontalItemImage")
                        }
                        
                        item.title.map {
                            
                            Text($0)
                                .font(config.detail.font)
                                .foregroundColor(config.detail.color)
                                .accessibilityIdentifier("HorisontalItemText")
                        }
                    }
                    
                    item.subInfo.map {
                        
                        ListHorizontalRoundImageView.SubInfoView(
                            text: $0,
                            config: config.subtitle)
                            .accessibilityIdentifier("HorisontalItemSubInfo")
                    }
                }
                .fixedSize(horizontal: false, vertical: true)
            }
            .disabled(item.detail == nil)
            .frame(width: config.item.size.width, height: config.item.size.height)
        }
    }
}

extension ComponentLHRI.ListItem {
    
    var detailDestination: DetailDestination? {
        
        detail.map {
            .init(
                groupID: .init($0.groupId),
                viewID: .init($0.viewId)
            )
        }
    }
}

struct ListHorizontalRoundImageView_Previews: PreviewProvider {
    static var previews: some View {
        
        Group {
            
            NavigationView {
                
                ListHorizontalRoundImageView(
                    model: defaultValue,
                    config: .defaultValue,
                    selectDetail: { _ in }
                )
                .previewDisplayName("With title")
            }
            
            ListHorizontalRoundImageView(
                model: defaultValueWithOutTitle,
                config: .defaultValue,
                selectDetail: { _ in}
            )
            .previewDisplayName("Without title")
        }
    }
    static let defaultValue: ListHorizontalRoundImageView.ViewModel = .init(data: .defaultValue, images: .defaultValue)
    
    static let defaultValueWithOutTitle: ListHorizontalRoundImageView.ViewModel = .init(data: .defaultValueWithoutTitle, images: .defaultValue)
}
