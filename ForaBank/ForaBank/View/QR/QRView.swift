//
//  QRView.swift
//  ForaBank
//
//  Created by Константин Савялов on 21.10.2022.
//
import SwiftUI

struct QRView: View {
    
    @ObservedObject var viewModel: QRViewModel
    
    var body: some View {
        
        ZStack {
            
            QRScannerView(viewModel: viewModel.scanner)
            
            VStack(alignment: .center, spacing: 0)  {
                
                Color.clear
                    .frame(height: 30)
                    .background(Color.black.opacity(0.5))
                
                HStack {
                    
                    VStack(alignment: .center, spacing: 10) {
                        
                        Text(viewModel.title)
                            .foregroundColor(.white)
                            .font(Font.textH1Sb24322())
                            .frame(maxWidth: .infinity)
                        
                        Text(viewModel.subTitle)
                            .foregroundColor(.white)
                            .font(Font.textH1Sb24322())
                            .frame(alignment: .center)
                        
                    }
                    .padding(.top)
                    .background(Color.black.opacity(0.5))
                }
                
                GeometryReader { geometry in
                    
                    let qrCenterRect: CGFloat = min(geometry.size.width , geometry.size.height) / 1.5
                    
                    QRCenterRectangleView(qrCenterRect: qrCenterRect, geometry: geometry)
                }
                
                VStack {
                    
                    HStack(spacing: 20) {
                        
                        ForEach(viewModel.buttons) { buttons in
                            
                            ButtonIconTextView(viewModel: buttons)
                        }
                    }
                    
                    ButtonSimpleView(viewModel: viewModel.closeButton)
                        .frame(height: 48)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 50)
                }
                .background(Color.black.opacity(0.5))
                
            }
            .edgesIgnoringSafeArea(.vertical)
            
            NavigationLink("", isActive: $viewModel.isLinkActive) {
                
                if let link = viewModel.link  {
                    
                    switch link {
                        
                    case .failedView(let view):
                        QRFailedView(viewModel: view)
                    }
                }
            }
            Color.clear
                .bottomSheet(item: $viewModel.bottomSheet, content: { sheet in
                    switch sheet.sheetType {
                        
                    case let .imageCapture(imageCapture):
                        QRImagePickerController(viewModel: imageCapture)
                            .edgesIgnoringSafeArea(.all)
                            .navigationBarBackButtonHidden(false)
                        
                    case let .choiseDocument(choiseDocument):
                        QRButtonsView(viewModel: choiseDocument)
                        
                    case let .info(infoViewModel) :
                        QRInfoViewComponent(viewModel: infoViewModel)
                            .frame(height: 450, alignment: .top)
                            .padding(.horizontal, 30)
                            .padding(.top, 20)
                        
                    case .qRAccessViewComponent(_):
                        
                        QRAccessView(viewModel: .init(input: .camera,  closeAction: {
                            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
                        }))
                        .frame(height: 330)
                        .padding(.horizontal, 30)
                        
                    case .photoAccessViewComponent(_):
                        QRAccessView(viewModel: .init(input: .photo,  closeAction: {
                            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
                        }))
                        .frame(height: 330)
                        .padding(.horizontal, 30)
                    }
                })
        }
        .alert(item: $viewModel.alert, content: { alertViewModel in
            Alert(with: alertViewModel)
        })
        
        .sheet(item: $viewModel.sheet) { item in
            
            switch item.sheetType {
            case .documentPicker(let documentPicker):
                //TODO: move Navigation to DocumentPicker
                NavigationView {
                    DocumentPicker(viewModel: documentPicker)
                        .navigationBarTitle("Из документов", displayMode: .inline)
                        .navigationBarBackButtonHidden(true)
                }
            case .imagePicker(let imagePicker):
                NavigationView {
                    QRImagePickerController(viewModel: imagePicker)
                        .navigationBarTitle("Из фото", displayMode: .inline)
                        .navigationBarBackButtonHidden(true)
                }
            }
        }
    }
}

struct QRCenterRectangleView: View {
    
    let qrCenterRect: CGFloat
    let geometry: GeometryProxy
    
    init(qrCenterRect: CGFloat, geometry: GeometryProxy) {
        self.qrCenterRect = qrCenterRect
        self.geometry = geometry
    }
    
    var body: some View {
        
        ZStack {
            
            Rectangle()
                .fill(.black.opacity(0.5))
            
            RoundedRectangle(cornerRadius: 16)
                .fill(.black)
                .frame(width: qrCenterRect - 25, height: qrCenterRect - 25, alignment: .center)
                .blendMode(.destinationOut)
                .padding(10)
        }
        .compositingGroup()
        
        Path { path in
            
            let left = (geometry.size.width - qrCenterRect) / 2.0
            let right = left + qrCenterRect
            let top = (geometry.size.height - qrCenterRect) / 2.0
            let bottom = top + qrCenterRect
            
            path.addPath(
                createCornersPath(
                    left: left, top: top,
                    right: right, bottom: bottom,
                    cornerRadius: 40, cornerLength: 30
                )
            )
        }
        .stroke(.white, lineWidth: 2)
        .frame(width: qrCenterRect, height: qrCenterRect, alignment: .center)
        .aspectRatio(1, contentMode: .fit)
    }
}

extension QRCenterRectangleView {
    
    private func createCornersPath(
        left: CGFloat,
        top: CGFloat,
        right: CGFloat,
        bottom: CGFloat,
        cornerRadius: CGFloat,
        cornerLength: CGFloat
    ) -> Path {
        var path = Path()
        
        path.move(to: CGPoint(x: left, y: (top + cornerRadius / 2.0)))
        path.addArc(
            center: CGPoint(x: (left + cornerRadius / 2.0), y: (top + cornerRadius / 2.0)),
            radius: cornerRadius / 2.0,
            startAngle: Angle(degrees: 180.0),
            endAngle: Angle(degrees: 270.0),
            clockwise: false
        )
        
        path.move(to: CGPoint(x: left + (cornerRadius / 2.0), y: top))
        path.addLine(to: CGPoint(x: left + (cornerRadius / 2.0) + cornerLength, y: top))
        
        path.move(to: CGPoint(x: left, y: top + (cornerRadius / 2.0)))
        path.addLine(to: CGPoint(x: left, y: top + (cornerRadius / 2.0) + cornerLength))
        
        path.move(to: CGPoint(x: right - cornerRadius / 2.0, y: top))
        path.addArc(
            center: CGPoint(x: (right - cornerRadius / 2.0), y: (top + cornerRadius / 2.0)),
            radius: cornerRadius / 2.0,
            startAngle: Angle(degrees: 270.0),
            endAngle: Angle(degrees: 360.0),
            clockwise: false
        )
        
        path.move(to: CGPoint(x: right - (cornerRadius / 2.0), y: top))
        path.addLine(to: CGPoint(x: right - (cornerRadius / 2.0) - cornerLength, y: top))
        
        path.move(to: CGPoint(x: right, y: top + (cornerRadius / 2.0)))
        path.addLine(to: CGPoint(x: right, y: top + (cornerRadius / 2.0) + cornerLength))
        
        path.move(to: CGPoint(x: left + cornerRadius / 2.0, y: bottom))
        path.addArc(
            center: CGPoint(x: (left + cornerRadius / 2.0), y: (bottom - cornerRadius / 2.0)),
            radius: cornerRadius / 2.0,
            startAngle: Angle(degrees: 90.0),
            endAngle: Angle(degrees: 180.0),
            clockwise: false
        )
        
        path.move(to: CGPoint(x: left + (cornerRadius / 2.0), y: bottom))
        path.addLine(to: CGPoint(x: left + (cornerRadius / 2.0) + cornerLength, y: bottom))
        
        path.move(to: CGPoint(x: left, y: bottom - (cornerRadius / 2.0)))
        path.addLine(to: CGPoint(x: left, y: bottom - (cornerRadius / 2.0) - cornerLength))
        
        path.move(to: CGPoint(x: right, y: bottom - cornerRadius / 2.0))
        path.addArc(
            center: CGPoint(x: (right - cornerRadius / 2.0), y: (bottom - cornerRadius / 2.0)),
            radius: cornerRadius / 2.0,
            startAngle: Angle(degrees: 0.0),
            endAngle: Angle(degrees: 90.0),
            clockwise: false
        )
        
        path.move(to: CGPoint(x: right - (cornerRadius / 2.0), y: bottom))
        path.addLine(to: CGPoint(x: right - (cornerRadius / 2.0) - cornerLength, y: bottom))
        
        path.move(to: CGPoint(x: right, y: bottom - (cornerRadius / 2.0)))
        path.addLine(to: CGPoint(x: right, y: bottom - (cornerRadius / 2.0) - cornerLength))
        
        return path
    }
}

struct QRView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        QRView(viewModel: .init(
            closeAction: {},
            qrResolve: { _ in .unknown }
        ))
    }
}

extension QRView_Previews {
    
    static let buttons = [
        ButtonIconTextView.ViewModel(icon: .init(image: .ic24AlertCircle, background: .circle), title: .init(text: "Из документов"), orientation: .horizontal, action: {}),
        ButtonIconTextView.ViewModel(icon: .init(image: .ic24AlertCircle, background: .circle), title: .init(text: "Фонарик"), orientation: .horizontal, action: {}),
        ButtonIconTextView.ViewModel(icon: .init(image: .ic24AlertCircle, background: .circle), title: .init(text: "Инфо"), orientation: .horizontal, action: {})]
    
    static let clouseButton = ButtonSimpleView(viewModel: .init(title: "Отменить", style: .gray, action: {} ))
}
