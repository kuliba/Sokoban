//
//  PlacesListView.swift
//  ForaBank
//
//  Created by Max Gribov on 30.03.2022.
//

import SwiftUI

struct PlacesListView: View {
    
    @ObservedObject var viewModel: PlacesListViewModel
    
    var body: some View {
        
        ZStack {
            
            Color.white
                .edgesIgnoringSafeArea(.all)
            
            VStack(alignment: .leading, spacing: 16) {
                
                ScrollView {
                    
                    LazyVStack(spacing: 12) {
                        
                        ForEach(viewModel.items) { itemViewModel in
                            
                            PlacesListView.ItemView(viewModel: itemViewModel)
                        }
                    }
                }
            }
            .padding(.top, 80)
            .padding(.horizontal, 20)
        }
    }
}

extension PlacesListView {
    
    struct ItemView: View {
        
        let viewModel: PlacesListViewModel.ItemViewModel

        var body: some View {
            
            HStack(spacing: 0) {
                
                VStack(alignment: .leading, spacing: 8) {
                    
                    Text(viewModel.name)
                        .font(.textH4SB16240())
                        .multilineTextAlignment(.leading)
                        .foregroundColor(.mainColorsBlack)
                    
                    Text(viewModel.address)
                        .font(.textBodyMR14200())
                        .multilineTextAlignment(.leading)
                        .foregroundColor(.mainColorsGray)
                        .padding(.top, 8)
                    
                    if let metro = viewModel.metro {
                        
                        TagsGridView(data: metro, spacing: 8, alignment: .leading) { station in
                            
                            PlacesListView.MetroStationView(viewModel: station)
                        }
                    }
                    
                    HStack(alignment: .bottom) {
                        
                        Text(viewModel.schedule)
                            .font(.textBodyMR14200())
                            .foregroundColor(.mainColorsBlack)
                        
                        Spacer()
                        
                        if let distance = viewModel.distance {
                            
                            HStack {
                                
                                Image.ic24Navigation
                                    .renderingMode(.template)
                                    .resizable()
                                    .frame(width: 12, height: 12)
                                    .foregroundColor(.mainColorsGray)
                                
                                Text(distance)
                                    .font(.textBodyMR14200())
                                    .foregroundColor(.mainColorsGray)
                            }
                        }
                    }
                    
                }.padding(16)
                
                Spacer()
            }
            .background(RoundedRectangle(cornerRadius: 16).foregroundColor(.mainColorsGrayLightest))
            .onTapGesture {
                
                viewModel.action()
            }
        }
    }
    
    struct MetroStationView: View {
        
        let viewModel: PlacesListViewModel.ItemViewModel.MetroStationViewModel
        
        var body: some View {
            
            HStack {
                
                Circle()
                    .frame(width: 8, height: 8)
                    .foregroundColor(viewModel.color)
                
                Text(viewModel.name)
                    .font(.textBodyMR14200())
                    .foregroundColor(.mainColorsGray)
            }
        }
    }
}

struct PlacesListView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        Group {
            
            PlacesListView(viewModel: .sample)
            
            PlacesListView.ItemView(viewModel: .sampleOne)
                .previewLayout(.fixed(width: 375, height: 200))
        }
    }
}
