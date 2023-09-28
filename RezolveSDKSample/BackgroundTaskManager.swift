//
//  BackgroundTaskManager.swift
//  RezolveSDKDemo
//
//  Created by Krzysztof Pelczar on 23/01/2020.
//  Copyright © 2020 Rezolve. All rights reserved.
//

import UIKit
import BackgroundTasks
import RezolveSDKLite

private enum BgTask {
    case appRefresh
    case processingTask
    
    var identifier: String {
        switch self {
        case .appRefresh: return "co.rezolve.app.apprefresh"
        case .processingTask: return "co.rezolve.app.processingtask"
        }
    }
    var earliestBeginTime: TimeInterval {
        switch self {
        case .appRefresh: return 15 * 60
        case .processingTask: return 2 * 60 * 60
        }
    }
}

final class BackgroundTaskManager {
    static let shared = BackgroundTaskManager()
    
    var engagementsService: RezolveGeofence?
    
    // MARK: Public methods
    
    func didFinishLaunchingWithOptions() {
        if #available(iOS 13.0, *) {
            registerBackgroundTaks()
        } else {
            UIApplication.shared.setMinimumBackgroundFetchInterval(UIApplication.backgroundFetchIntervalMinimum)
        }
    }
    
    func applicationDidEnterBackground() {
        if #available(iOS 13.0, *) {
            cancelAllPendingTasks()
            scheduleAppRefreshTask()
            scheduleProcessingTask()
        } else {
            // pre iOS 13 handled by old BackgroundFetch
        }
    }
    
    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // pre iOS 13
        refreshEngagementsInBackground(completionHandler: completionHandler)
    }
    
    // MARK: Registration
    
    @available(iOS 13.0, *)
    private func registerBackgroundTaks() {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: BgTask.appRefresh.identifier, using: nil) { task in
            self.handleAppRefreshTask(task: task as! BGAppRefreshTask)
        }
        BGTaskScheduler.shared.register(forTaskWithIdentifier: BgTask.processingTask.identifier, using: nil) { task in
            self.handleProcessingTask(task: task as! BGProcessingTask)
        }
    }
    
    // MARK: Scheduling
    
    @available(iOS 13.0, *)
    private func cancelAllPendingTasks() {
        BGTaskScheduler.shared.cancelAllTaskRequests()
    }
    
    @available(iOS 13.0, *)
    private func scheduleAppRefreshTask() {
        let request = BGAppRefreshTaskRequest(identifier: BgTask.appRefresh.identifier)
        request.earliestBeginDate = Date(timeIntervalSinceNow: BgTask.appRefresh.earliestBeginTime)
        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            print("Could not schedule app refresh: \(error)")
        }
    }
    
    @available(iOS 13.0, *)
    private func scheduleProcessingTask() {
        let request = BGProcessingTaskRequest(identifier: BgTask.processingTask.identifier)
        request.requiresNetworkConnectivity = true
        request.requiresExternalPower = false
        request.earliestBeginDate = Date(timeIntervalSinceNow: BgTask.processingTask.earliestBeginTime)
        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            print("Could not schedule processing task: \(error)")
        }
    }
    
    // MARK: Handle fired background task
    
    @available(iOS 13.0, *)
    private func handleAppRefreshTask(task: BGAppRefreshTask) {
        print("this?")
        scheduleAppRefreshTask() // Reschedule task

        task.expirationHandler = {
            self.engagementsService?.cancelBackgroundFetch()
            task.setTaskCompleted(success: false)
        }

        refreshEngagementsInBackground { result in
            task.setTaskCompleted(success: true)
        }
    }
    
    @available(iOS 13.0, *)
    private func handleProcessingTask(task: BGProcessingTask) {
        print("or that?")
        scheduleProcessingTask() // Reschedule task
        
        task.expirationHandler = {
            self.engagementsService?.cancelBackgroundFetch()
            task.setTaskCompleted(success: false)
        }
        
        refreshEngagementsInBackground { result in
            task.setTaskCompleted(success: true)
        }
    }
    
    // MARK: Refresh engagements
    
    func refreshEngagementsInBackground(completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // give some time to instantiate app in background
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
            self.engagementsService?.performFetchWithCompletionHandler(completionHandler)
        }
    }
}
