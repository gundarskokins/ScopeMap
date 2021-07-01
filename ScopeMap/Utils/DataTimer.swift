//
//  DataTimer.swift
//  ScopeMap
//
//  Created by Gundars Kokins on 01/07/2021.
//

import Foundation

class DataTimer {
    var timer = Timer()
    var timeInterval = TimeInterval(86400)
    //    private var configurationTimerTriggered: TimeInterval?
    
    func startSpecsHeartbeatTimer(block: @escaping ()->()) {
        timer.invalidate()
        triggerConfigurationTimer(block: block)
    }
    
    private func triggerConfigurationTimer(block: @escaping ()->()) {
        DispatchQueue.main.async {
            self.timer = Timer.scheduledTimer(withTimeInterval: self.timeInterval,
                                              repeats: true,
                                              block: { _ in
                                                block()
                                              })
        }
    }
}
