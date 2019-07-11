//
//  GPXTrack+length.swift
//  SmartGPSTracker
//
//  Created by Mosquito1123 on 11/07/2019.
//  Copyright © 2019 Cranberry. All rights reserved.
//

import Foundation
import MapKit
import CoreGPX

/// Extension to support getting the distance of a track in meters.
extension GPXTrack {
    
    /// Track length in meters
    public var length: CLLocationDistance {
        get {
            var trackLength: CLLocationDistance = 0.0
            for segment in tracksegments {
                trackLength += segment.length()
            }
            return trackLength
        }
    }
}
