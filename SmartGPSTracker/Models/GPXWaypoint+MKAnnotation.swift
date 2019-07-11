//
//  GPXWaypoint+MKAnnotation.swift
//  SmartGPSTracker
//
//  Created by Mosquito1123 on 11/07/2019.
//  Copyright © 2019 Cranberry. All rights reserved.
//

import Foundation
import MapKit
import CoreGPX

///
/// Extends GPXWaypoint to support the MKAnnotation protocol. It allows to
/// add the waypoint as a pin in the map
///
extension GPXWaypoint : MKAnnotation {
    
    ///
    /// Inits the point with a coordinate
    ///
    convenience init (coordinate: CLLocationCoordinate2D) {
        self.init(latitude: coordinate.latitude, longitude: coordinate.longitude)
        //set default title and subtitle
        
        // Default title now
        let timeFormat = DateFormatter()
        timeFormat.dateStyle = DateFormatter.Style.none
        timeFormat.timeStyle = DateFormatter.Style.medium
        //timeFormat.setLocalizedDateFormatFromTemplate("HH:mm:ss")
        
        let subtitleFormat = DateFormatter()
        //dateFormat.setLocalizedDateFormatFromTemplate("MMM dd, yyyy")
        subtitleFormat.dateStyle = DateFormatter.Style.medium
        subtitleFormat.timeStyle = DateFormatter.Style.medium
        
        let now = Date()
        self.time = now
        self.title = timeFormat.string(from: now)
        self.subtitle = subtitleFormat.string(from: now)
    }
    
    convenience init (coordinate: CLLocationCoordinate2D, altitude: CLLocationDistance?) {
        self.init(coordinate: coordinate)
        self.elevation = altitude
    }
    
    /// Title displayed on the annotation bubble.
    /// Is the attribute name of the waypoint.
    public var title: String? {
        set {
            self.name = newValue
        }
        get {
            return self.name
        }
    }
    
    /// Subtitle displayed on the annotation bubble
    /// Description of the GPXWaypoint.
    public var subtitle: String? {
        set {
            self.desc = newValue
        }
        get {
            return self.desc
        }
    }
    
    ///Annotation coordinates. Returns/Sets the waypoint latitude and longitudes.
    public var coordinate: CLLocationCoordinate2D {
        set {
            self.latitude = newValue.latitude
            self.longitude = newValue.longitude
        }
        get {
            return CLLocationCoordinate2D(latitude: self.latitude!, longitude: CLLocationDegrees(self.longitude!))
        }
    }
}


///
/// This extension adds some methods to work with MapKit
///
#if os(iOS)
extension GPXTrackSegment {
    
    /// Returns a MapKit polyline with the points of the segment.
    /// This polyline can be directly plotted on the map as an overlay
    public var overlay: MKPolyline {
        get {
            var coords: [CLLocationCoordinate2D] = self.trackPointsToCoordinates()
            let pl = MKPolyline(coordinates: &coords, count:  coords.count)
            return pl
        }
    }
}
#endif

extension GPXTrackSegment {
    
    /// Helper method to create the polyline. Returns the array of coordinates of the points
    /// that belong to this segment
    func trackPointsToCoordinates() -> [CLLocationCoordinate2D] {
        var coords: [CLLocationCoordinate2D] = []
        for point in self.trackpoints {
            coords.append(point.coordinate)
        }
        return coords
    }
    
    /// Calculates length in meters of the segment
    func length() -> CLLocationDistance {
        var length: CLLocationDistance = 0.0
        var distanceTwoPoints: CLLocationDistance
        //we need at least two points
        if self.trackpoints.count < 2 {
            return length
        }
        var prev: CLLocation? //previous
        for point in self.trackpoints {
            let pt: CLLocation = CLLocation(latitude: Double(point.latitude!), longitude: Double(point.longitude!) )
            if prev == nil { //if first point => set it as previous and go for next
                prev = pt
                continue
            }
            distanceTwoPoints = pt.distance(from: prev!)
            length += distanceTwoPoints
            //set current point as previous point
            prev = pt
        }
        return length
    }
}
/// Extends the GPXTrackPoint to be able to be initialized with a `CLLocation` object.
extension GPXTrackPoint {
    
    /// Initializes a trackpoint with the CLLocation data
    convenience init(location: CLLocation) {
        self.init()
        self.latitude = location.coordinate.latitude
        self.longitude = location.coordinate.longitude
        self.time = Date()
        self.elevation = location.altitude
    }
    
    
}
