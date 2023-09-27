//
//  QRDataMapper.swift
//  ForaBank
//
//  Created by Andryusina Nataly on 26.09.2023.
//

import Foundation

struct QrDataMapper {
    
    typealias Result = Swift.Result<QRScenarioData, MapperError>
    
    public static func map(
        _ data: Data,
        _ response: HTTPURLResponse
    ) -> Result {
        
        let statusCode = response.statusCode
        
        switch statusCode {
        case statusCode200:
            return handle200(with: data)
            
        default:
            return .failure(.notOkStatus(statusCode))
        }
    }
    
    private static func handle200(with data: Data) -> Result {
        
        do {
            let decodableData = try JSONDecoder().decode(DecodableQrData.self, from: data)
            
            switch decodableData.statusCode {
                
            case statusCode3122:
                return .failure(.status3122)
                
            default:
                guard let data = decodableData.data
                else { return .failure(.emptyData)}
                return .success(data)
            }
        } catch {
            return .failure(.mapError)
        }
    }
    
    enum MapperError: Error {
        
        case emptyData
        case notOkStatus(Int)
        case mapError
        case status3122
    }
}

private let statusCode200 = 200
private let statusCode3122 = 3122
