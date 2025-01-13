//
// SegmentedPicker_Previews.swift
//  
//
//  Created by Andryusina Nataly on 09.06.2023.
//

import SwiftUI

struct PreviewTag: Identifiable & Hashable {
    
    let title: String
    var id: String { title }
}

extension PreviewTag {
    
    static let tagA: Self = .init(title: "Aaa")
    static let tagB: Self = .init(title: "Bbb")
    static let tagC: Self = .init(title: "Ccc")
    static let tagD: Self = .init(title: "Ddd")
}

struct SegmentedPicker_Previews: PreviewProvider {
    static var previews: some View {
        
        SegmentedPicker(
            viewModel: .init(
                selectedTag: PreviewTag.tagB,
                tags: [
                    .tagA,
                    .tagB,
                    .tagC,
                    .tagD,
                ]
            ),
            tagView: { tag, isSelected in
                Text(tag.title)
                    .foregroundColor(isSelected ? .primary : .secondary)
            }
        )
        .padding()
    }
}
