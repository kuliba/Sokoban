//
//  ResponseMapper+GetImageList.swift
//  Vortex
//
//  Created by Дмитрий Савушкин on 13.11.2023.
//

import Foundation
import PaymentSticker

struct ImageListResponse: Decodable {
    
    let statusCode: Int
    let errorMessage: String?
    let data: Data

    struct Data: Decodable {
        
        let svgImageList: [ImageList]
        
        struct ImageList: Decodable {
            
            let svgImage: String
            let md5hash: String
        }
    }
}

extension ResponseMapper {
    
    typealias GetImageListResult = Result<[ImageData], GetImageListError>
    
    static func getImageListResponse(
        _ data: Data,
        _ httpURLResponse: HTTPURLResponse
    ) -> GetImageListResult {
        
        do {
            
            switch httpURLResponse.statusCode {
            case 200:
                    
                let imageList = try JSONDecoder().decode(ImageListResponse.self, from: data)
                return .success(imageList.data.svgImageList.map({
                    ImageData(data: $0.svgImage.data)
                }))
                
            default:
                
                let serverError = try JSONDecoder().decode(ServerError.self, from: data)
                return .failure(.error(
                    statusCode: serverError.statusCode,
                    errorMessage: serverError.errorMessage
                ))
            }
            
        } catch {
            return .failure(.invalidData(
                statusCode: httpURLResponse.statusCode, data: data
            ))
            
        }
    }
    
    enum GetImageListErrorResponse: Error , Equatable {
        
        case error(
            statusCode: Int,
            errorMessage: String
        )
        case invalidData(statusCode: Int, data: Data)
    }
}
