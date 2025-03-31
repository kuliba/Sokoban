//
//  DescriptorView.swift
//
//
//  Created by Igor Malyarov on 31.03.2025.
//

import SharedConfigs
import SwiftUI

struct Descriptor: Equatable {
    
    let items: [Item] // TODO: improve with non-empty?
    let title: String
}

extension Descriptor {
    
    struct Item: Equatable {
        
        let md5Hash: String
        let title: String
        let value: String
    }
}

struct DescriptorViewConfig: Equatable {
    
    let background: Color
    let cornerRadius: CGFloat
    let edges: EdgeInsets
    let header: Header
    let item: Item
    let spacing: CGFloat
}

extension DescriptorViewConfig {
    
    struct Header: Equatable {
        
        let height: CGFloat
        let title: TextConfig
    }
    
    struct Item: Equatable {
        
        let height: CGFloat
        let icon: Icon
        let spacing: CGFloat
        let title: TextConfig
        let value: TextConfig
        let vSpacing: CGFloat
        
    }
}

extension DescriptorViewConfig.Item {
    
    struct Icon: Equatable {
        
        let frame: CGSize
    }
}

struct DescriptorView<IconView: View>: View {
    
    let descriptor: Descriptor
    let config: DescriptorViewConfig
    let iconView: (String) -> IconView
    
    var body: some View {
        
        VStack(spacing: config.spacing) {
            
            header(config: config.header)
            
            ForEach(descriptor.items, id: \.id) { itemView($0, config.item) }
        }
        .padding(config.edges)
        .background(config.background, in: RoundedRectangle(cornerRadius: config.cornerRadius))
    }
}

private extension Descriptor.Item {
    
    var id: String { title + value }
}

private extension DescriptorView {
    
    func header(
        config: DescriptorViewConfig.Header
    ) -> some View {
        
        descriptor.title.text(withConfig: config.title)
            .frame(maxWidth: .infinity, alignment: .leading)
            .height(config.height)
    }
    
    func itemView(
        _ item: Descriptor.Item,
        _ config: DescriptorViewConfig.Item
    ) -> some View {
        
        HStack(spacing: config.spacing) {
            
            iconView(item.md5Hash)
                .frame(config.icon.frame)
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: config.vSpacing) {
                
                item.title.text(withConfig: config.title ,alignment: .leading)
                
                item.value.text(withConfig: config.value ,alignment: .leading)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .height(config.height)
    }
}

// MARK: - Previews

struct DescriptorView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        VStack {
            
            descriptorView(.empty)
            descriptorView(.one)
            descriptorView(.preview)
        }
    }
    
    static func descriptorView(
        _ descriptor: Descriptor
    ) -> some View {
        
        DescriptorView(descriptor: descriptor, config: .preview) { _ in
            
            Color.blue.opacity(0.6)
        }
        .padding()
    }
}

extension Descriptor {
    
    static let empty: Self = .init(
        items: [],
        title: "Empty Offer"
    )
    
    static let one: Self = .init(
        items: [.preview1],
        title: "Offer with One"
    )
    
    static let preview: Self = .init(
        items: [.preview1, .preview2, .preview3],
        title: "Irresistible Offer"
    )
}

extension Descriptor.Item {
    
    static let preview1: Self = .init(md5Hash: "", title: "Item 1", value: "Value 1")
    static let preview2: Self = .init(md5Hash: "", title: "Item 2", value: "Value 2")
    static let preview3: Self = .init(md5Hash: "", title: "Item 3", value: "Value 3")
}


extension DescriptorViewConfig {
    
    static let preview: Self = .init(
        background: .gray.opacity(0.1), // Main colors/Gray lightest
        cornerRadius: 12,
        edges: .init(top: 0, leading: 16, bottom: 13, trailing: 16),
        header: .init(
            height: 46,
            title: .init(
                textFont: .title3.bold(), // ??? Nika
                textColor: .orange // Text/secondary
            )
        ),
        item: .init(
            height: 46,
            icon: .init(frame: .init(width: 40, height: 40)),
            spacing: 16,
            title: .init(
                textFont: .footnote, // Text/Body M/R_14×18_0%
                textColor: .green // Text/placeholder
            ),
            value: .init(
                textFont: .headline, // Text/H4/M_16×24_0%
                textColor: .pink // Text/secondary
            ),
            vSpacing: 4
        ),
        spacing: 13
    )
}

