//
//  MicroServices+ContractUpdater.swift
//
//
//  Created by Igor Malyarov on 26.01.2024.
//

public typealias ContractStatus = UserPaymentSettings.PaymentContract.ContractStatus

public extension MicroServices {
    
    final class ContractUpdater<ContractID, AccountID, Contract>
    where ContractID: Equatable,
          AccountID: Equatable,
          Contract: StatusReporting<ContractStatus> {
        
        private let getContract: GetContract
        private let updateContract: UpdateContract
        
        public init(
            getContract: @escaping GetContract,
            updateContract: @escaping UpdateContract
        ) {
            self.getContract = getContract
            self.updateContract = updateContract
        }
    }
}

public extension MicroServices.ContractUpdater {
    
    func process(
        _ payload: Payload,
        _ completion: @escaping Completion
    ) {
        updateContract(payload, completion)
    }
}

public extension MicroServices.ContractUpdater {
    
    struct Payload: Equatable {
        
        public let contractID: ContractID
        public let selectableProductID: SelectableProductID
        public let target: TargetStatus
        
        public init(
            contractID: ContractID, 
            selectableProductID: SelectableProductID,
            target: TargetStatus
        ) {
            self.contractID = contractID
            self.selectableProductID = selectableProductID
            self.target = target
        }
        
        public enum TargetStatus: Equatable {
            
            case active, inactive
        }
    }
    
    typealias ProcessResult = Result<Contract, ServiceFailure>
    typealias Completion = (ProcessResult) -> Void
    
    // fastPaymentContractFindList
    typealias GetContractResult = Result<Contract?, ServiceFailure>
    typealias GetContractCompletion = (GetContractResult) -> Void
    typealias GetContract = (@escaping GetContractCompletion) -> Void
    
    // updateFastPaymentContract
    typealias UpdateContractResponse = Result<Void, ServiceFailure>
    typealias UpdateContractCompletion = (UpdateContractResponse) -> Void
    typealias UpdateContract = (Payload, @escaping UpdateContractCompletion) -> Void
}

private extension MicroServices.ContractUpdater {
    
    func updateContract(
        _ payload: Payload,
        _ completion: @escaping Completion
    ) {
        updateContract(payload) { [weak self] result in
            
            guard let self else { return }
            
            switch result {
            case let .failure(serviceFailure):
                completion(.failure(serviceFailure))
                
            case .success(()):
                getContract(payload.target, completion)
            }
        }
    }
    
    func getContract(
        _ targetStatus: Payload.TargetStatus,
        _ completion: @escaping Completion
    ) {
        getContract { [weak self] result in
            
            guard self != nil else { return }
            
            switch result {
            case let .failure(serviceFailure):
                completion(.failure(serviceFailure))
                
            case .success(.none):
                completion(.failure(.connectivityError))

            case let .success(.some(contract)):
                switch (targetStatus, contract.status) {
                case (.active, .active),
                    (.inactive, .inactive):
                    completion(.success(contract))
                    
                default:
                    completion(.failure(.connectivityError))
                }
            }
        }
    }
}
