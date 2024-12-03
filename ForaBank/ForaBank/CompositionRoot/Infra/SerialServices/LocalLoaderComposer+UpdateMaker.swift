//
//  LocalAgentAsyncWrapper+UpdateMaker.swift
//  ForaBank
//
//  Created by Igor Malyarov on 16.09.2024.
//

extension LocalAgentAsyncWrapper: UpdateMaker {
    
    func makeUpdate<T, Model: Codable>(
        toModel: @escaping ToModel<T, Model>,
        reduce: @escaping Reduce<Model>
    ) -> Update<T> {
        
        composeUpdate(toModel: toModel, reduce: reduce)
    }
}
