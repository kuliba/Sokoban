//
//  SwipeActionView.swift
//  ForaBank
//
//  Created by Dmitry Martynov on 23.09.2022.
//

import SwiftUI

struct SwipeActionButton: View, Identifiable {
    static let width: CGFloat = 100

    let id = UUID()
    let text: Text?
    let icon: Image?
    let action: () -> Void
    let tint: Color?

    init(text: Text? = nil,
         icon: Image? = nil,
         action: @escaping () -> Void,
         tint: Color? = nil) {
    
        self.text = text
        self.icon = icon
        self.action = action
        self.tint = tint ?? .gray
    }
    
    var body: some View {
            
        ZStack {
            tint
            VStack {
                icon?.foregroundColor(.white)
                if icon == nil {
                    text?.foregroundColor(.white)
                }
            }
            .frame(width: SwipeActionButton.width)
        }
    }
}

@available(iOS 13.0, *)
struct SwipeActionView: ViewModifier {
  
    private static let minSwipeableWidth = SwipeActionButton.width * 0.8
    
    let leading: [SwipeActionButton]
    let allowsFullSwipeLeading: Bool
    let trailing: [SwipeActionButton]
    let allowsFullSwipeTrailing: Bool
    
    private let totalLeadingWidth: CGFloat!
    private let totalTrailingWidth: CGFloat!
    
    @State private var offset: CGFloat = 0
    @State private var prevOffset: CGFloat = 0
    
    init(leading: [SwipeActionButton] = [],
         allowsFullSwipeLeading: Bool = false,
         trailing: [SwipeActionButton] = [],
         allowsFullSwipeTrailing: Bool = false) {
        self.leading = leading
        self.allowsFullSwipeLeading = allowsFullSwipeLeading && !leading.isEmpty
        self.trailing = trailing
        self.allowsFullSwipeTrailing = allowsFullSwipeTrailing && !trailing.isEmpty
        totalLeadingWidth = SwipeActionButton.width * CGFloat(leading.count)
        totalTrailingWidth = SwipeActionButton.width * CGFloat(trailing.count)
    }
    
    func body(content: Content) -> some View {
      
        GeometryReader { geo in
            
            HStack(spacing: 0) {
              
                if offset > 0 {
                    
                    if fullSwipeEnabled(edge: .leading, width: geo.size.width) {
                        button(for: leading.first)
                            .frame(width: offset, height: geo.size.height)
                    } else {
                      
                        ForEach(leading) { actionView in
                            button(for: actionView)
                                .frame(width: individualButtonWidth(edge: .leading),
                                       height: geo.size.height)
                        }
                    }
                }
              
                content
                    
                    //.padding(.horizontal, 16)
                    .frame(width: geo.size.width, height: geo.size.height, alignment: .leading)
                    .offset(x: (offset > 0) ? 0 : offset)
                    
                if offset < 0 {
                    Group {
                      
                        if fullSwipeEnabled(edge: .trailing, width: geo.size.width) {
                            button(for: trailing.last)
                                .frame(width: -offset, height: geo.size.height)
                        } else {
                           
                            ForEach(trailing) { actionView in
                                button(for: actionView)
                                    .frame(width: individualButtonWidth(edge: .trailing),
                                           height: geo.size.height)
                            }
                        }
                    }
                    .offset(x: offset)
                }
            }
            .animation(.spring(), value: offset)
            .contentShape(Rectangle())
            .gesture(DragGesture(minimumDistance: 15,
                                 coordinateSpace: .local)
                        .onChanged { gesture in
        
                guard gesture.translation.height > -30 && gesture.translation.height < 30 else { return }
                
                var total = gesture.translation.width + prevOffset
                if !allowsFullSwipeLeading {
                    total = min(total, totalLeadingWidth)
                }
                if !allowsFullSwipeTrailing {
                    total = max(total, -totalTrailingWidth)
                }
                offset = total
            }
                        .onEnded { _ in
                
                if offset > SwipeActionView.minSwipeableWidth && !leading.isEmpty {
                    if !checkAndHandleFullSwipe(for: leading, edge: .leading, width: geo.size.width) {
                        offset = totalLeadingWidth
                    }
                } else if offset < -SwipeActionView.minSwipeableWidth && !trailing.isEmpty {
                    if !checkAndHandleFullSwipe(for: trailing, edge: .trailing, width: -geo.size.width) {
                        offset = -totalTrailingWidth
                    }
                } else {
                    offset = 0
                }
                prevOffset = offset
            })
        } //geo
        
     
        .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
    }
    
    private func fullSwipeEnabled(edge: Edge, width: CGFloat) -> Bool {
        let threshold = abs(width) / 2
        switch (edge) {
        case .leading:
            return allowsFullSwipeLeading && offset > threshold
        case .trailing:
            return allowsFullSwipeTrailing && -offset > threshold
        }
    }
    
    private func button(for button: SwipeActionButton?) -> some View {
        button?
            .onTapGesture {
                button?.action()
                offset = 0
                prevOffset = 0
            }
    }
    
    private func individualButtonWidth(edge: Edge) -> CGFloat {
        switch edge {
        case .leading:
            return (offset > 0) ? (offset / CGFloat(leading.count)) : 0
        case .trailing:
            return (offset < 0) ? (abs(offset) / CGFloat(trailing.count)) : 0
        }
    }
    
    private func checkAndHandleFullSwipe(for collection: [SwipeActionButton],
                                         edge: Edge,
                                         width: CGFloat) -> Bool {
        if fullSwipeEnabled(edge: edge, width: width) {
            offset = width * CGFloat(collection.count) * 1.2
            ((edge == .leading) ? collection.first : collection.last)?.action()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                offset = 0
                prevOffset = 0
            }
            return true
        } else {
            return false
        }
    }
    
    private enum Edge {
        case leading, trailing
    }
}

extension View {
    func swipeActions13(leading: [SwipeActionButton] = [],
                      allowsFullSwipeLeading: Bool = false,
                      trailing: [SwipeActionButton] = [],
                      allowsFullSwipeTrailing: Bool = false) -> some View {
        modifier(SwipeActionView(leading: leading,
                                 allowsFullSwipeLeading: allowsFullSwipeLeading,
                                 trailing: trailing,
                                 allowsFullSwipeTrailing: allowsFullSwipeTrailing))
    }
}

struct CustomSwipeActionTest: View {
 var body: some View {
  List(1..<19) {
    Text("List view item at row \($0)")
          .foregroundColor(.green)
     
    .swipeActions13(leading: [
       SwipeActionButton(text: Text("Text"), action: {
           print("Text")
       }),
       SwipeActionButton(icon: Image(systemName: "flag"), action: {
           print("Flag")
       }, tint: .green)
     ],
     allowsFullSwipeLeading: true,
     trailing: [
       SwipeActionButton(text: Text("Read"),
                         icon: Image(systemName: "envelope.open"),
                         action: {
           print("Read")
       }, tint: .blue),
       SwipeActionButton(icon: Image(systemName: "trash"), action: {
           print("Trash")
       }, tint: .red)
     ],
     allowsFullSwipeTrailing: true)
    
  }.listStyle(.plain)
         .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
         .listRowBackground(Color.barsTabbar)
 }
}

struct SwipeActionView_Previews: PreviewProvider {
    
    static var previews: some View {
        CustomSwipeActionTest()
            .previewLayout(.sizeThatFits)
    }
}
