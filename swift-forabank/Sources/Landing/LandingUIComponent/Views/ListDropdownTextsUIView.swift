//
//  SwiftUIView.swift
//  
//
//  Created by Andrew Kurdin on 2023-09-09.
//

import SwiftUI

struct ListDropdownTextsUIView: View {
    
    @State private var selectedItem: UILanding.List.DropDownTexts.Item?
    private let model: UILanding.List.DropDownTexts
    private let config: UILanding.List.DropDownTexts.Config
    
    init(
        model: UILanding.List.DropDownTexts,
        config: UILanding.List.DropDownTexts.Config
    ) {
        self.model = model
        self.config = config
    }
    
    public var body: some View {
        
        VStack(spacing: 0){
            ScrollView(showsIndicators: false) {
                ListView(model: model, config: config, selectedItem: $selectedItem)
            }
        }
        .padding(.horizontal, config.paddings.horizontal)
        .padding(.vertical, config.paddings.vertical)
    }
}

extension ListDropdownTextsUIView {
    
    struct ListView: View {
        
        let model: UILanding.List.DropDownTexts
        let config: UILanding.List.DropDownTexts.Config
        
        @Binding var selectedItem: UILanding.List.DropDownTexts.Item?
        
        var body: some View {
            
            VStack(spacing: 0) {
                headerView
                
                ForEach(model.list, content: itemView)
            }
            .frame(maxWidth: .infinity)
            .background(config.backgroundColor)
            .cornerRadius(config.cornerRadius)
        }
        
        private var headerView: some View {
            
            VStack(alignment: .leading) {
                if let title = model.title, !title.isEmpty {
                    Text(title.rawValue)
                        .font(config.fonts.title)
                        .foregroundColor(config.colors.title)
                        .frame(height: config.heights.title)
                        .padding(.top, config.paddings.titleTop)
                        .padding(.horizontal, config.paddings.titleHorizontal)
                        .accessibilityIdentifier("ListDropdownTitle")
                    
                    config.divider
                        .frame(height: 0.5)
                }
            }
        }
        
        @ViewBuilder
        private func itemView(item: UILanding.List.DropDownTexts.Item) -> some View {
            
            VStack(alignment: .leading, spacing: 0) {
                
                HStack {
                    Text(item.title)
                        .font(config.fonts.itemTitle)
                        .foregroundColor(config.colors.itemTitle)
                        .accessibilityIdentifier("ListDropdownItemTitle")
                    
                    Spacer()
                    
                    config.chevronDownImage
                        .rotationEffect(selectedItem == item ? .degrees(180) : .degrees(0))
                        .accessibilityIdentifier("ListDropdownItemChevronDown")
                }
                .frame(height: config.heights.item)
                .onTapGesture {
                    withAnimation {
                        selectedItem = selectedItem == item ? nil : item
                    }
                }
                
                if selectedItem == item {
                    Text(item.description)
                        .font(config.fonts.itemDescription)
                        .foregroundColor(config.colors.itemDescription)
                        .padding(.bottom, config.paddings.itemVertical)
                        .multilineTextAlignment(.leading)
                }
            }
            .padding(.horizontal, config.paddings.itemHorizontal)
            
            config.divider
                .frame(height: 0.5)
        }
    }
}

struct ListDropdownTextsUIView_Previews: PreviewProvider {
    static var previews: some View {
        ListDropdownTextsUIView(
            model: .defaultDropDownTextsDataList,
            config: .defaultDropDownTextsConfig)
    }
}
