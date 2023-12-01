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
    
    public init(data: Data,
                spacing: CGFloat,
                alignment: HorizontalAlignment,
                content: @escaping (Data.Element) -> Content) {
        
        self.data = data
        self.spacing = spacing
        self.alignment = alignment
        self.content = content
    }
    
    public var body: some View {
        
        ZStack(alignment: Alignment(horizontal: alignment,
                                    vertical: .center)) {
            Color.clear
                .frame( height: 1)
                .readSize { size in
                    availableWidth = size.width
                }
            
            InnerGridView(availableWidth: availableWidth,
                          data: data,
                          spacing: spacing,
                          alignment: alignment,
                          content: content)
        }
    }
}

private struct InnerGridView<Data: Collection, Content: View>: View where Data.Element: Hashable {
    
    let availableWidth: CGFloat
    let data: Data
    let spacing: CGFloat
    let alignment: HorizontalAlignment
    let content: (Data.Element) -> Content
    
    @State var elementsSize: [Data.Element: CGSize] = [:]
    
    var body: some View {
        
        VStack(alignment: alignment, spacing: spacing) {
            
            ForEach(computeRows(), id: \.self) { rowElements in
                
                HStack(spacing: spacing) {
                    
                    ForEach(rowElements, id: \.self) { element in
                        
                        content(element)
                            .fixedSize()
                            .readSize { size in
                                elementsSize[element] = size
                            }
                    }
                }
            }
        }
    }
    
    func computeRows() -> [[Data.Element]] {
        
        var rows: [[Data.Element]] = [[]]
        var currentRow = 0
        var remainingWidth = availableWidth
        
        for element in data {
            
            let elementSize = elementsSize[element, default: CGSize(width: availableWidth, height: 1)]
            
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

public extension View {
    
    func readSize(onChange: @escaping (CGSize) -> Void) -> some View {
        
        background(
            
            GeometryReader { geometry in
                
                Color.clear
                    .preference(key: SizePreferenceKey.self,
                                value: geometry.size)
            }
        )
        .onPreferenceChange(SizePreferenceKey.self) { size in
            
            DispatchQueue.main.async { onChange(size) }
        }
    }
}

private struct SizePreferenceKey: PreferenceKey {
    
    static var defaultValue: CGSize = .zero
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) { }
}
