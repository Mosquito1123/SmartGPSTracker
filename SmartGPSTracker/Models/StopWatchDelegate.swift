//
//  StopWatchDelegate.swift
//  SmartGPSTracker
//
//  Created by Mosquito1123 on 11/07/2019.
//  Copyright © 2019 Cranberry. All rights reserved.
//

import Foundation

/// This protocol is used to inform the delegate that the elapsed time was updated.
/// Provides the elapsed time as a string
protocol StopWatchDelegate: class {
    
    /// Called when the stopwatch updated the elapsed time.
    func stopWatch(_ stropWatch: StopWatch, didUpdateElapsedTimeString elapsedTimeString: String)
}
