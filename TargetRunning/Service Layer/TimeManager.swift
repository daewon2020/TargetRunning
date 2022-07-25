//
//  TimeManager.swift
//  TargetRunning
//
//  Created by Константин Андреев on 23.05.2022.
//

import Foundation
import UIKit

class TimeManager {
    static var shared = TimeManager()
    
    typealias Listener = (Int) -> Void
    
    private var backgroundTask: UIBackgroundTaskIdentifier = .invalid
    private var listener: Listener?
    private var time: Int {
        didSet {
            listener?(time)
        }
    }
    
    private var timer: Timer?
    
    private init() {
        time = 0
        NotificationCenter.default.addObserver(self, selector: #selector(reinstateBackgroundTask), name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    func startTimer() {
        time = 0
        timer = Timer.scheduledTimer(
            timeInterval: 1,
            target: self,
            selector: #selector(timerDidChange),
            userInfo: nil,
            repeats: true
        )
        if let timer = timer {
            RunLoop.current.add(timer, forMode: .common)
        }
    }

    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    func finishTimer() {
        timer?.invalidate()
        timer = nil
        endBackgroundTask()
    }
    
    func resumeTimer() {
        timer = Timer.scheduledTimer(
            timeInterval: 1,
            target: self,
            selector: #selector(timerDidChange),
            userInfo: nil,
            repeats: true
        )
        if let timer = timer {
            RunLoop.current.add(timer, forMode: .common)
        }
    }
    
    @objc private func timerDidChange() {
        time += 1
    }
    
    func bind(listener: @escaping Listener) {
        self.listener = listener
        listener(time)
    }
    
    @objc private func reinstateBackgroundTask() {
        if timer != nil && backgroundTask == .invalid {
            registerBackgroundTask()
        }
    }
    
    private func registerBackgroundTask() {
        backgroundTask = UIApplication.shared.beginBackgroundTask {
            self.endBackgroundTask()
        }
        assert(backgroundTask != .invalid)
    }
    
    private func endBackgroundTask() {
        UIApplication.shared.endBackgroundTask(backgroundTask)
        backgroundTask = .invalid
    }
}
