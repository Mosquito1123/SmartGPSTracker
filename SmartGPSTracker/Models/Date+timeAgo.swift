//
//  Date+timeAgo.swift
//  SmartGPSTracker
//
//  Created by Mosquito1123 on 11/07/2019.
//  Copyright © 2019 Cranberry. All rights reserved.
//

import Foundation

extension Date {
    
    ///
    /// Provides a humanified date. For instance: 1 minute, 1 week ago, 3 months ago
    ///
    /// - Parameters:
    ///      - numericDates: Set it to true to get "1 year ago", "1 month ago" or false if you prefer "Last year", "Last month"
    ///
    func timeAgo(numericDates:Bool) -> String {
        let calendar = Calendar.current
        let now = Date()
        let earliest = self < now ? self : now
        let latest =  self > now ? self : now
        
        let unitFlags: Set<Calendar.Component> = [.minute, .hour, .day, .weekOfMonth, .month, .year, .second]
        let components: DateComponents = calendar.dateComponents(unitFlags, from: earliest, to: latest)
        //print("")
        //print(components)
        if let year = components.year {
            if (year >= 2) {
                return "\(year) years ago"
            } else if (year >= 1) {
                return numericDates ?  "1 year ago" : "Last year"
            }
        }
        if let month = components.month {
            if (month >= 2) {
                return "\(month) months ago"
            } else if (month >= 1) {
                return numericDates ? "1 month ago" : "Last month"
            }
        }
        if let weekOfMonth = components.weekOfMonth {
            if (weekOfMonth >= 2) {
                return "\(weekOfMonth) weeks ago"
            } else if (weekOfMonth >= 1) {
                return numericDates ? "1 week ago" : "Last week"
            }
        }
        if let day = components.day {
            if (day >= 2) {
                return "\(day) days ago"
            } else if (day >= 1) {
                return numericDates ? "1 day ago" : "Yesterday"
            }
        }
        if let hour = components.hour {
            if (hour >= 2) {
                return "\(hour) hours ago"
            } else if (hour >= 1) {
                return numericDates ? "1 hour ago" : "An hour ago"
            }
        }
        if let minute = components.minute {
            if (minute >= 2) {
                return "\(minute) minutes ago"
            } else if (minute >= 1) {
                return numericDates ? "1 minute ago" : "A minute ago"
            }
        }
        if let second = components.second {
            if (second >= 3) {
                return "\(second) seconds ago"
            }
        }
        return "Just now"
    }
}
