//
//  GPXFilesTableViewControlllerDelegate.swift
//  SmartGPSTracker
//
//  Created by Mosquito1123 on 11/07/2019.
//  Copyright © 2019 Cranberry. All rights reserved.
//

import Foundation
import CoreGPX

///
/// Delegate protocol for the view controller that displays the list of files (GPXFilesTableViewController).
///
/// Used to inform the main ViewController that user wants to load a GPX File on it.
///
protocol GPXFilesTableViewControllerDelegate: class {
    
    ///
    /// GPXFilesTableView controller will be dismissed after calling this method
    ///
    /// - Parameters:
    ///       - gpxFile: is the name of the file to load without extension
    ///       - gpxRoot: is a object with the contents of
    ///
    ///  - Seealso:
    ///     - [iOS-GPX-Framework](https://github.com/merlos/iOS-GPX-Framework)
    ///
    func didLoadGPXFileWithName(_ gpxFilename: String, gpxRoot: GPXRoot)
    
}
