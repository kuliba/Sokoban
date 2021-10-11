//
//  ExtensionQRReadPDF.swift
//  ForaBank
//
//  Created by Константин Савялов on 04.09.2021.
//

import UIKit

extension QRViewController {
/// Преобразуем PDF в Image
func drawPDFfromURL(url: URL) -> UIImage? {
        guard let document = CGPDFDocument(url as CFURL) else { return nil }

        var width: CGFloat = 0
        var height: CGFloat = 0
        
        // calculating overall page size
        for index in 1...document.numberOfPages {
            print("index: \(index)")
            if let page = document.page(at: index) {
                let pageRect = page.getBoxRect(.mediaBox)
                width = max(width, pageRect.width)
                height = height + pageRect.height
            }
        }

        // now creating the image
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: width, height: height))

        let image = renderer.image { (ctx) in
            ctx.cgContext.scaleBy(x: 1.0, y: -1.0)
            for index in 1...document.numberOfPages {
                
                if let page = document.page(at: index) {
                    let pageRect = page.getBoxRect(.mediaBox)
                    ctx.cgContext.translateBy(x: 0.0, y: -pageRect.height)
                    ctx.cgContext.drawPDFPage(page)
                }
            }
            
            ctx.cgContext.scaleBy(x: 1.0, y: -1.0)
        }
        return image
    }

/// В Image определяем qr  и возвращаем в строку
func string(from image: UIImage) -> String {

        var qrAsString = ""
        guard let detector = CIDetector(ofType: CIDetectorTypeQRCode,
                                        context: nil,
                                        options: [CIDetectorAccuracy: CIDetectorAccuracyHigh]),
            let ciImage = CIImage(image: image),
            let features = detector.features(in: ciImage) as? [CIQRCodeFeature] else {
                return qrAsString
        }

        for feature in features {
            guard let indeedMessageString = feature.messageString else {
                continue
            }
            qrAsString += indeedMessageString
        }
        return qrAsString
    }
    
    

}
