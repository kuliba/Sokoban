//
//  PlacesDetailView.swift
//  ForaBank
//
//  Created by Max Gribov on 05.04.2022.
//

import SwiftUI

struct PlacesDetailView: View {
    
    let viewModel: PlacesDetailViewModel
    
    var body: some View {
        
        VStack(spacing: 40) {
            
            VStack(spacing: 8) {
                
                Capsule()
                    .frame(width: 48, height: 4)
                    .foregroundColor(.mainColorsGrayMedium)
                    .padding(.top, 8)
                
                viewModel.icon
                    .renderingMode(.original)
                    .resizable()
                    .frame(width: 64, height: 64)
                    .padding(.top, 16)
                
                Text(viewModel.name)
                    .font(.textH4SB16240())
                    .multilineTextAlignment(.center)
                    .foregroundColor(.mainColorsBlack)
                    .padding(.top, 8)
                
                Text(viewModel.address)
                    .font(.textBodyMR14200())
                    .multilineTextAlignment(.center)
                    .foregroundColor(.mainColorsGray)
                    .padding(.horizontal, 60)
                
                if let metroViewModel = viewModel.metro {
                    
                    TagsGridView(data: metroViewModel.stations, spacing: 8, alignment: .center) { station in
                        
                        HStack {
                            
                            Circle()
                                .frame(width: 8, height: 8)
                                .foregroundColor(station.color)
                            
                            Text(station.name)
                                .font(.textBodyMR14200())
                                .foregroundColor(.mainColorsGray)
                        }
                    }
                }
                
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
                
                //TODO: turn on after route implementation
                /*
                PlacesDetailView.RouteButtonView(viewModel: viewModel.routeButton)
                    .frame(width: 200, height: 40)
                    .padding(.top, 8)
                 */
                
                Text(viewModel.schedule)
                    .font(.textBodyMR14200())
                    .foregroundColor(.mainColorsBlack)
                    .padding(.top, 16)
                
                HStack {
                    
                    Image.ic16PhoneCall
                    
                    Text(viewModel.phoneNumber)
                        .font(.textBodyMR14200())
                        .foregroundColor(.mainColorsBlack)
                }
                .padding(.top, 24)
                
                HStack {
                    
                    Image.ic16Mail
                    
                    Text(viewModel.email)
                        .font(.textBodyMR14200())
                        .foregroundColor(.mainColorsBlack)
                }
                .padding(.top, 12)
            }
            
            if let servicesViewModel = viewModel.services {
                
                PlacesDetailView.ServicesView(viewModel: servicesViewModel)
            }
            
            Spacer()
        }
        .padding(.horizontal, 20)
    }
}

extension PlacesDetailView {
    
    struct RouteButtonView: View {
        
        let viewModel: PlacesDetailViewModel.RouteButtonViewModel
        
        var body: some View {
            
            ZStack {
                
                RoundedRectangle(cornerRadius: 6)
                    .foregroundColor(.buttonSecondary)
                
                Text(viewModel.title)
                    .font(.buttonSmallM14160())
                    .foregroundColor(.mainColorsBlack)
                
            }
            .onTapGesture {
                viewModel.action()
            }
        }
    }
    
    struct ServicesView: View {
        
        let viewModel: PlacesDetailViewModel.ServicesViewModel
        
        var body: some View {
            
            VStack(spacing: 12) {
                
                Text(viewModel.title)
                    .font(.textH4SB16240())
                    .foregroundColor(.mainColorsBlack)
                
                HStack {
                    
                    VStack(alignment: .leading, spacing: 0) {
                        
                        ForEach(viewModel.services) { service in
                            
                            HStack {
                                
                                Circle()
                                    .frame(width: 4, height: 4)
                                    .foregroundColor(.mainColorsBlack)
                                
                                Text(service.name)
                                    .font(.textBodyMR14200())
                                    .foregroundColor(.mainColorsBlack)
                            }
                        }
                    }
                    Spacer()
                }
            }
        }
    }
}

struct PlacesDetailView_Previews: PreviewProvider {
    static var previews: some View {
        PlacesDetailView(viewModel: .sample)
    }
}
