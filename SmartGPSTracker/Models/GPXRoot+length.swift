//
//  GPXRoot+length.swift
//  SmartGPSTracker
//
//  Created by Mosquito1123 on 11/07/2019.
//  Copyright © 2019 Cranberry. All rights reserved.
//

import Foundation
import MapKit
import CoreGPX

/// Extends GPXRoot to support getting the length of all tracks in meters
extension GPXRoot {
    
    /// Distance in meters of all the track segments
    public var tracksLength: CLLocationDistance {
        get {
            var tLength: CLLocationDistance = 0.0
            for track in self.tracks {
                tLength += track.length
            }
            return tLength
        }
    }
}
