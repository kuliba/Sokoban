//
//  ToggleView.swift
//  ForaBank
//
//  Created by Pavel Samsonov on 27.05.2022.
//

import SwiftUI

struct ToggleView: View {

    @Binding var isOn: Bool

    let trackSize: CGSize
    let thumbSize: CGSize
    let thumbOffset: CGFloat

    init(isOn: Binding<Bool>,
         trackSize: CGSize = .init(width: 48, height: 24),
         thumbSize: CGSize = .init(width: 12, height: 12),
         thumbOffset: CGFloat = 12) {

        _isOn = isOn
        self.trackSize = trackSize
        self.thumbSize = thumbSize
        self.thumbOffset = thumbOffset
    }

    var body: some View {

        ZStack {

            TrackView(isOn: $isOn, trackSize: trackSize)
            ThumbView(isOn: $isOn, thumbSize: thumbSize, thumbOffset: thumbOffset)

        }.onTapGesture {
            withAnimation {
                isOn.toggle()
            }
        }
    }
}

extension ToggleView {

    struct TrackView: View {

        @Binding var isOn: Bool
        let trackSize: CGSize

        init(isOn: Binding<Bool>, trackSize: CGSize) {

            _isOn = isOn
            self.trackSize = trackSize
        }

        var trackColor: Color {
            isOn ? .systemColorActive : .mainColorsGray
        }

        var body: some View {

            Capsule()
                .stroke(trackColor, lineWidth: 1)
                .frame(width: trackSize.width, height: trackSize.height)
        }
    }

    struct ThumbView: View {

        @Binding var isOn: Bool

        let thumbSize: CGSize
        let thumbOffset: CGFloat

        init(isOn: Binding<Bool>, thumbSize: CGSize, thumbOffset: CGFloat) {

            _isOn = isOn
            self.thumbSize = thumbSize
            self.thumbOffset = thumbOffset
        }

        var thumbColor: Color {
            isOn ? .systemColorActive : .mainColorsGray
        }

        var thumbOffsetX: CGFloat {
            isOn ? thumbOffset : -thumbOffset
        }

        var body: some View {

            Circle()
                .foregroundColor(thumbColor)
                .frame(width: thumbSize.width, height: thumbSize.height)
                .offset(x: thumbOffsetX)
        }
    }
}

//MARK: - Preview

struct PreviewToggleView: View {

    @State var isOn: Bool = true

    var body: some View {

        ZStack {
            ToggleView(isOn: $isOn)
        }
    }
}

struct ToggleView_Previews: PreviewProvider {
    static var previews: some View {
        PreviewToggleView()
            .frame(width: 375, height: 64)
            .padding()
    }
}
