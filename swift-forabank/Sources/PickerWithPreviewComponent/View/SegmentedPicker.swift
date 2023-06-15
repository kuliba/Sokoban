//
//  SegmentedPicker.swift
//  CustomSegmentedPicker
//
//  Created by Igor Malyarov on 05.03.2023.
//

import SwiftUI

struct SegmentedPicker<Tag, TagView>: View
where Tag: Identifiable & Hashable,
      TagView: View {
    
    @ObservedObject private var viewModel: ViewModel
    
    let tagView: (Tag, Bool) -> TagView
    
    init(
        viewModel: ViewModel,
        tagView: @escaping (Tag, Bool) -> TagView
    ) {
        
        self.viewModel = viewModel
        self.tagView = tagView
    }
    
    var body: some View {
        
        SegmentedPickerStateView(
            selectedTag: viewModel.selectedTag,
            tags: viewModel.tags,
            select: viewModel.select(tag:),
            tagView: tagView
        )
    }
}

struct SegmentedPickerStateView<Tag: Identifiable & Equatable, TagView: View>: View {
    
    let selectedTag: Tag
    let tags: [Tag]
    
    let select: (Tag) -> Void
    
    let tagView: (Tag, Bool) -> TagView
    
    @Namespace private var namespace
    
    var body: some View {
        
        ZStack {
            
            Rectangle()
                .fill(Color.gray.opacity(0.2))
                .cornerRadius(4, corners: [.topRight, .bottomRight])
            
            HStack(spacing: 0) {
                
                ForEach(tags, content: tagView)
            }
            .frame(height: 28)
        }
        .frame(height: 32)
    }
}

extension SegmentedPickerStateView {
    
    @ViewBuilder
    private func tagView(tag: Tag) -> some View {
        
        let isSelected = selectedTag == tag
        ZStack {
            
            if isSelected {
                
                Rectangle()
                    .fill(.white)
                    .cornerRadius(4)
                    .matchedGeometryEffect(
                        id: "selection",
                        in: namespace,
                        properties: [.frame, .position, .size],
                        anchor: .center,
                        isSource: isSelected
                    )
            } else {
                
                Rectangle()
                    .fill(.clear)
                    .cornerRadius(4)
                    .matchedGeometryEffect(
                        id: "selection",
                        in: namespace,
                        properties: [.frame, .position, .size],
                        anchor: .center,
                        isSource: isSelected
                    )
            }
            
            tagView(tag, isSelected)
                .id(tag.id)
                .padding(.vertical, 2)
                .cornerRadius(4)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 2)
        .animation(.default, value: selectedTag)
        .onTapGesture {
            
            select(tag)
        }
    }
}

extension SegmentedPicker {
    
    final class ViewModel: ObservableObject {
        
        @Published private(set) var selectedTag: Tag
        
        let tags: [Tag]
        
        init(selectedTag: Tag, tags: [Tag]) {
            
            self.selectedTag = selectedTag
            self.tags = tags
        }
        
        func select(tag: Tag) {
            
            self.selectedTag = tag
        }
    }
}

struct RoundedCorner: Shape {
    
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

extension View {
    
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        
        clipShape( RoundedCorner(radius: radius, corners: corners) )
    }
}
