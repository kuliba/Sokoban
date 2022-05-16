//
//  BottomSheetView.swift
//  ForaBank
//
//  Created by Дмитрий on 30.03.2022.
//

import SwiftUI
import Combine

fileprivate enum ConstantsSheet {
    static let radius: CGFloat = 16
    static let indicatorHeight: CGFloat = 6
    static let indicatorWidth: CGFloat = 60
    static let snapRatio: CGFloat = 0.25
    static let minHeightRatio: CGFloat = 0.3
}

struct BottomSheetView<Content: View>: View {
    
    @Binding var isOpen: Bool
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>


    let maxHeight: CGFloat
    let minHeight: CGFloat
    let content: Content

    @GestureState private var translation: CGFloat = 0

    private var offset: CGFloat {
        isOpen ? 0 : maxHeight - minHeight
    }

    private var indicator: some View {
        
        RoundedRectangle(cornerRadius: ConstantsSheet.radius)
            .fill(Color.mainColorsGrayLightest)
            .frame( width: ConstantsSheet.indicatorWidth, height: ConstantsSheet.indicatorHeight
            ).onTapGesture {
            self.isOpen.toggle()
        }
    }

    init(isOpen: Binding<Bool>, maxHeight: CGFloat, @ViewBuilder content: () -> Content) {
        
        self.minHeight = maxHeight * ConstantsSheet.minHeightRatio
        self.maxHeight = maxHeight
        self.content = content()
        self._isOpen = isOpen
    }

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                self.indicator.padding()
                self.content
            }
            .frame(width: geometry.size.width, height: self.maxHeight, alignment: .top)
            .background(Color.white)
            .cornerRadius(ConstantsSheet.radius)
            .frame(height: geometry.size.height, alignment: .bottom)
            .offset(y: max(self.offset + self.translation, 0))
            .animation(.interactiveSpring())
            .gesture(
                DragGesture().updating(self.$translation) { value, state, _ in
                    state = value.translation.height
                }.onEnded { value in
                    let snapDistance = self.maxHeight * ConstantsSheet.snapRatio
                    guard abs(value.translation.height) > snapDistance else {
                        return
                    }
                                        
                    action: do { self.presentationMode.wrappedValue.dismiss()
                        self.isOpen.toggle()
                    }

                }
            )
        }
        .edgesIgnoringSafeArea(.all)
    }
}

struct BottomSheetView_Previews: PreviewProvider {
    static var previews: some View {
        BottomSheetView(isOpen: .constant(false), maxHeight: 600, content: { Rectangle().fill(Color.red) })
            .edgesIgnoringSafeArea(.all)
    }
}

