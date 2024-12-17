//
//  OnboardingPlayer.swift
//  ForaBank
//
//  Created by Dmitry Martynov on 20.10.2022.
//

import SwiftUI
import AVKit
import AVFoundation

extension OnboardingPlayerView {
    
    struct ViewModel {
            
        let player: AVPlayer
        let publisher = NotificationCenter.default.publisher(for: .AVPlayerItemDidPlayToEndTime)

        init(player: AVPlayer) {
            
            self.player = player
        }

        init?(onboardingName: String) {
              
            guard let url = Bundle.main.url(forResource: onboardingName,  withExtension: "mov")
            else { return nil }

            self.init(player: AVPlayer(url: url))
        }
    }
    
    class AVPlayerView: UIView {

        override static var layerClass: AnyClass { AVPlayerLayer.self }
        
        var player: AVPlayer? {
            get { playerLayer.player }
            set { playerLayer.player = newValue }
        }
        
        private var playerLayer: AVPlayerLayer { layer as! AVPlayerLayer }
    }

    struct OnboardingPlayerRepresentable : UIViewRepresentable {
        
        var player : AVPlayer
        
        func makeUIView(context: Context) -> AVPlayerView {
            let view = AVPlayerView()
            view.player = player
            return view
        }
        
        func updateUIView(_ View: AVPlayerView, context: Context) { }
    }
}
    
struct OnboardingPlayerView: View {
    
    let viewModel: ViewModel
    var body: some View {
            
        OnboardingPlayerRepresentable(player: viewModel.player)
            .onAppear { viewModel.player.play() }
            .onReceive(viewModel.publisher) { _ in
                viewModel.player.seek(to: .zero)
                viewModel.player.play()
            }
    }
}

struct OnboardingPlayerView_Previews: PreviewProvider {
    static var previews: some View {
        
        OnboardingPlayerView(viewModel: .init(onboardingName: "MyProductsHide3x")!)
    }
}
