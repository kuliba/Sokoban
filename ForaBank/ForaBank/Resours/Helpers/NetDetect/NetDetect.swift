//
//  NetDetect.swift
//  ForaBank
//
//  Created by Константин Савялов on 18.08.2021.
//

import Foundation

public class NetDetect {
    public init() {
        NetStatus.shared.startMonitoring()
//        NetStatus.shared.netStatusChangeHandler = {
//            DispatchQueue.main.async { [unowned self] in
//                print("Change Net")
//            }
//        }
    }
}
