//
//  Coordinator.swift
//  ForaBank
//
//  Created by Константин Савялов on 22.09.2021.
//

import UIKit

public protocol BaseCoordinatorType: AnyObject {
    func start()
}

public protocol PresentableCoordinatorType: BaseCoordinatorType, Presentable {}

open class PresentableCoordinator: NSObject, PresentableCoordinatorType {
    
    public override init() {
        super.init()
    }
    
    open func start() { start() }

    open func toPresentable() -> UIViewController {
        fatalError("Must override toPresentable()")
    }
}


public protocol CoordinatorType: PresentableCoordinatorType {
    var router: RouterType { get }
}


open class Coordinator: PresentableCoordinator, CoordinatorType  {
    
    public var childCoordinators: [Coordinator] = []
    
    open var router: RouterType
    
    public init(router: RouterType) {
        self.router = router
        super.init()
    }
    
    public func addChild(_ coordinator: Coordinator) {
        childCoordinators.append(coordinator)
    }
    
    public func removeChild(_ coordinator: Coordinator?) {
        
        if let coordinator = coordinator, let index = childCoordinators.firstIndex(of: coordinator) {
            childCoordinators.remove(at: index)
        }
    }
    
    open override func toPresentable() -> UIViewController {
        return router.toPresentable()
    }
}

