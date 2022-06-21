//
//  PageIndicatorComponent.swift
//  BottomSheetView
//
//  Created by Pavel Samsonov on 09.06.2022.
//

import SwiftUI

// MARK: - View

struct PageIndicatorView: View {

    @Binding var currentIndex: Int

    let pageCount: Int
    let itemSize: CGFloat

    init(pageCount: Int, currentIndex: Binding<Int>, sizeItem: CGFloat = 6) {

        self.pageCount = pageCount
        _currentIndex = currentIndex
        self.itemSize = sizeItem
    }

    var body: some View {

        HStack {
            ForEach(0..<pageCount){ index in
                Circle()
                    .foregroundColor(currentIndex == index ? .mainColorsGray : .mainColorsGrayLightest)
                    .animation(.spring())
                    .frame(width: itemSize, height: itemSize)
            }
        }
    }
}

// MARK: - Previews

struct PageIndicatorComponent_Previews: PreviewProvider {
    static var previews: some View {
        PageIndicatorView(pageCount: 5, currentIndex: .constant(0))
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
