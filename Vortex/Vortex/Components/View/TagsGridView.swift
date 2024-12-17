//
//  TagsGridView.swift
//  ForaBank
//
//  Created by Max Gribov on 07.04.2022.
//

import SwiftUI

public struct TagsGridView<Data: Collection, Content: View>: View where Data.Element: Hashable {
    
    let data: Data
    let spacing: CGFloat
    let alignment: HorizontalAlignment
    let content: (Data.Element) -> Content
    
    @State private var availableWidth: CGFloat = 0
    
    public init(
        data: Data,
        spacing: CGFloat,
        alignment: HorizontalAlignment,
        content: @escaping (Data.Element) -> Content
    ) {
        self.data = data
        self.spacing = spacing
        self.alignment = alignment
        self.content = content
    }
    
    public var body: some View {
        
        ZStack(
            alignment: Alignment(
                horizontal: alignment,
                vertical: .center)
        ) {
            Color.clear
                .frame( height: 1)
                .reportWidth()
            
            InnerGridView(
                availableWidth: availableWidth,
                data: data,
                spacing: spacing,
                alignment: alignment,
                content: content
            )
        }
        .onPreferenceChange(WidthPreferenceKey.self) { width in
            
            DispatchQueue.main.async {
                
                availableWidth = width
            }
        }
    }
}

private struct WidthPreferenceKey: PreferenceKey {
    
    static var defaultValue: CGFloat = .zero
    
    static func reduce(
        value: inout CGFloat,
        nextValue: () -> CGFloat
    ) {
        value += nextValue()
    }
}

private extension View {
    
    func reportWidth() -> some View {
        
        self.background(
            GeometryReader { proxy in
                
                Color.clear
                    .preference(
                        key: WidthPreferenceKey.self,
                        value: proxy.size.width
                    )
            }
        )
    }
}

private struct InnerGridView<Data: Collection, Content: View>: View where Data.Element: Hashable {
    
    let availableWidth: CGFloat
    let data: Data
    let spacing: CGFloat
    let alignment: HorizontalAlignment
    let content: (Data.Element) -> Content
    
    @State var sizes: [Int: CGSize] = [:]
    
    var body: some View {
        
        VStack(alignment: alignment, spacing: spacing) {
            
            ForEach(computeRows(), id: \.self) { rowElements in
                
                HStack(spacing: spacing) {
                    
                    ForEach(rowElements, id: \.self) { element in
                        
                        content(element)
                            .fixedSize()
                            .reportSize(element.hashValue)
                    }
                }
            }
        }
        .onPreferenceChange(SizesPreferenceKey.self) { sizes in
            
            DispatchQueue.main.async { self.sizes = sizes }
        }
    }
    
    func computeRows() -> [[Data.Element]] {
        
        var rows: [[Data.Element]] = [[]]
        var currentRow = 0
        var remainingWidth = availableWidth
        
        for element in data {
            
            let elementSize = sizes[element.hashValue, default: CGSize(width: availableWidth, height: 1)]
            
            if remainingWidth - (elementSize.width + spacing) >= 0 {
                
                rows[currentRow].append(element)
                
            } else {
                
                currentRow = currentRow + 1
                rows.append([element])
                remainingWidth = availableWidth
            }
            
            remainingWidth = remainingWidth - (elementSize.width + spacing)
        }
        
        return rows
    }
}

private extension View {
    
    func reportSize(_ hash: Int) -> some View {
        
        background(
            GeometryReader { geometry in
                
                Color.clear
                    .preference(
                        key: SizesPreferenceKey.self,
                        value: [hash: geometry.size]
                    )
            }
        )
    }
}

private struct SizesPreferenceKey: PreferenceKey {
    
    static var defaultValue: [Int: CGSize] = [:]
    
    static func reduce(
        value: inout [Int : CGSize],
        nextValue: () -> [Int : CGSize]
    ) {
        value.merge(nextValue(), uniquingKeysWith: { (current, _) in current })
    }
}

#warning("this is a broken solution but it is reused in the codebase")
public extension View {
    
    func readSize(onChange: @escaping (CGSize) -> Void) -> some View {
        
        background(
            
            GeometryReader { geometry in
                
                Color.clear
                    .preference(key: SizePreferenceKey.self,
                                value: geometry.size)
            }
        )
        .onPreferenceChange(SizePreferenceKey.self, perform: onChange)
    }
}

private struct SizePreferenceKey: PreferenceKey {
    
    static var defaultValue: CGSize = .zero
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) { }
}
