//
//  DescriptorView.swift
//
//
//  Created by Igor Malyarov on 31.03.2025.
//

import SharedConfigs
import SwiftUI

enum DescriptorStatus: Equatable {
    
    case loaded(Descriptor)
    case loading, placeholder
}

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
    let placeholderColor: Color
    let placeholderCount: Int
    let spacing: CGFloat
}

extension DescriptorViewConfig {
    
    struct Header: Equatable {
        
        let height: CGFloat
        let placeholder: Placeholder
        let title: TextConfig
    }
    
    struct Item: Equatable {
        
        let height: CGFloat
        let icon: Icon
        let spacing: CGFloat
        let title: TextConfig
        let value: TextConfig
        let vSpacing: CGFloat
        let placeholder: Placeholder
    }
}

extension DescriptorViewConfig.Header {
    
    struct Placeholder: Equatable {
        
        let color: Color
        let cornerRadius: CGFloat
        let height: CGFloat
    }
}

extension DescriptorViewConfig.Item {
    
    struct Icon: Equatable {
        
        let frame: CGSize
    }
    
    struct Placeholder: Equatable {
        
        let color: Color
        let cornerRadius: CGFloat
        let titleHeight: CGFloat
        let valueHeight: CGFloat
    }
}

struct DescriptorView<IconView: View>: View {
    
    let descriptorStatus: DescriptorStatus
    let config: DescriptorViewConfig
    let makeIconView: (String) -> IconView
    
    var body: some View {
        
        VStack(spacing: config.spacing) {
            
            header(config: config.header)
                .height(config.header.height)
            
            ForEach(items, id: \.id) { itemView($0, config.item) }
        }
        .padding(config.edges)
        .background(background)
    }
}

private extension Descriptor.Item {
    
    var id: String { title + value }
}

private extension DescriptorView {
    
    private var isActive: Bool { descriptorStatus == .loading }
    
    private var background: some View {
        
        Group {
            
            switch descriptorStatus {
            case .loaded:
                config.background
                
            default:
                config.placeholderColor
                    ._shimmering(isActive: isActive)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: config.cornerRadius))
    }
    
    private var items: [Descriptor.Item] {
        
        switch descriptorStatus {
        case let .loaded(descriptor):
            return descriptor.items
            
        default:
            return .placeholder(count: config.placeholderCount)
        }
    }
    
    @ViewBuilder
    func header(
        config: DescriptorViewConfig.Header
    ) -> some View {
        
        switch descriptorStatus {
        case let .loaded(descriptor):
            descriptor.title.text(withConfig: config.title)
                .frame(maxWidth: .infinity, alignment: .leading)
            
        default:
            config.placeholder.color
                .clipShape(RoundedRectangle(cornerRadius: config.placeholder.cornerRadius))
                .height(config.placeholder.height)
                ._shimmering(isActive: isActive)
        }
    }
    
    func itemView(
        _ item: Descriptor.Item,
        _ config: DescriptorViewConfig.Item
    ) -> some View {
        
        HStack(spacing: config.spacing) {
            
            iconView(md5Hash: item.md5Hash, placeholderColor: config.placeholder.color)
                .frame(config.icon.frame)
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: config.vSpacing) {
                
                titleView(title: item.title, config: config)
                valueView(value: item.value, config: config)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .height(config.height)
    }
    
    @ViewBuilder
    func iconView(
        md5Hash: String,
        placeholderColor: Color
    ) -> some View {
        
        switch descriptorStatus {
        case .loaded:
            makeIconView(md5Hash)
            
        default:
            placeholderColor
                ._shimmering(isActive: isActive)
        }
    }
    
    @ViewBuilder
    func titleView(
        title: String,
        config: DescriptorViewConfig.Item
    ) -> some View {
        
        switch descriptorStatus {
        case .loaded:
            title.text(withConfig: config.title ,alignment: .leading)
            
        default:
            config.placeholder.color
                .clipShape(RoundedRectangle(cornerRadius: config.placeholder.cornerRadius))
                .height(config.placeholder.titleHeight)
                ._shimmering(isActive: isActive)
        }
    }
    
    @ViewBuilder
    func valueView(
        value: String,
        config: DescriptorViewConfig.Item
    ) -> some View {
        
        switch descriptorStatus {
        case .loaded:
            value.text(withConfig: config.value ,alignment: .leading)
            
        default:
            config.placeholder.color
                .clipShape(RoundedRectangle(cornerRadius: config.placeholder.cornerRadius))
                .height(config.placeholder.valueHeight)
                ._shimmering(isActive: isActive)
        }
    }
}

private extension Array where Element == Descriptor.Item {
    
    static func placeholder(
        count: Int,
        makeUniqueMD5Hash: (Int) -> String = { _ in UUID().uuidString }
    ) -> Self {
        
        (0..<count).map {
            
            return .init(md5Hash: makeUniqueMD5Hash($0), title: "", value: "")
        }
    }
}

// MARK: - Previews

struct DescriptorView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        VStack {
            
            descriptorView(.loaded(.empty))
            descriptorView(.loaded(.one))
            descriptorView(.loaded(.preview))
        }
        .previewDisplayName("loaded")
        
        VStack {
            
            descriptorView(.placeholder)
            descriptorView(.loading)
        }
        .previewDisplayName("placeholders")
    }
    
    static func descriptorView(
        _ descriptorStatus: DescriptorStatus
    ) -> some View {
        
        DescriptorView(
            descriptorStatus: descriptorStatus,
            config: .preview,
            makeIconView: { _ in Color.blue.opacity(0.6) }
        )
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
        background: .green.opacity(0.3), // Main colors/Gray lightest
        cornerRadius: 12,
        edges: .init(top: 0, leading: 16, bottom: 13, trailing: 16),
        header: .init(
            height: 46,
            placeholder: .init(
                color: .pink.opacity(0.5), // Blur/Placeholder white text
                cornerRadius: 90,
                height: 24
            ),
            title: .init(
                textFont: .title3.bold(), // ??? Nika
                textColor: .orange // Text/secondary
            )
        ),
        item: .init(
            height: 46,
            icon: .init(
                frame: .init(width: 40, height: 40)
            ),
            spacing: 16,
            title: .init(
                textFont: .footnote, // Text/Body M/R_14×18_0%
                textColor: .green // Text/placeholder
            ),
            value: .init(
                textFont: .headline, // Text/H4/M_16×24_0%
                textColor: .pink // Text/secondary
            ),
            vSpacing: 4,
            placeholder: .init(
                color: .blue.opacity(0.3), // Blur/Placeholder white text
                cornerRadius: 90,
                titleHeight: 14,
                valueHeight: 18
            )
        ),
        placeholderColor: .green.opacity(0.15), // Blur/Placeholder
        placeholderCount: 4,
        spacing: 13
    )
}
