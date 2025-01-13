//
//  MicroServices+ContractMaker.swift
//
//
//  Created by Igor Malyarov on 26.01.2024.
//

public extension MicroServices {
    
    final class ContractMaker<Payload, Contract>
    where Contract: StatusReporting<ContractStatus> {
        
        private let createContract: CreateContract
        private let getContract: GetContract
        
        public init(
            createContract: @escaping CreateContract,
            getContract: @escaping GetContract
        ) {
            self.createContract = createContract
            self.getContract = getContract
        }
    }
}

public extension MicroServices.ContractMaker {
    
    func process(
        _ payload: Payload,
        _ completion: @escaping Completion
    ) {
        createContract(payload, completion)
    }
}

public extension MicroServices.ContractMaker {
    
    #warning("how to enforce on type level that success case means active contract and active only? check is performed in `getContract(_:_:)`")
    typealias ProcessResult = Result<Contract, ServiceFailure>
    typealias Completion = (ProcessResult) -> Void
    
    // createFastPaymentContract
    typealias CreateContractResponse = Result<Void, ServiceFailure>
    typealias CreateContractCompletion = (CreateContractResponse) -> Void
    typealias CreateContract = (Payload, @escaping CreateContractCompletion) -> Void
    
    // fastPaymentContractFindList
    typealias GetContractResult = Result<Contract?, ServiceFailure>
    typealias GetContractCompletion = (GetContractResult) -> Void
    typealias GetContract = (@escaping GetContractCompletion) -> Void
}

private extension MicroServices.ContractMaker {
    
    func createContract(
        _ payload: Payload,
        _ completion: @escaping Completion
    ) {
        createContract(payload) { [weak self] result in
            
            guard let self else { return }
            
            switch result {
            case let .failure(serviceFailure):
                completion(.failure(serviceFailure))
                
            case .success(()):
                getContract(payload, completion)
            }
        }
    }
    
    func getContract(
        _ payload: Payload,
        _ completion: @escaping Completion
    ) {
        getContract { [weak self] result in
            
            guard self != nil else { return }
            
            switch result {
            case let .failure(serviceFailure):
                completion(.failure(serviceFailure))
                
            case .success(nil):
                completion(.failure(.connectivityError))
                
            case let .success(.some(contract)):
                switch contract.status {
                case .active:
                    completion(.success(contract))
                    
                case .inactive:
                    completion(.failure(.connectivityError))
                }
            }
        }
    }
}
