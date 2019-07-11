//
//  PreferencesTableViewControllerDelegate.swift
//  SmartGPSTracker
//
//  Created by Mosquito1123 on 11/07/2019.
//  Copyright © 2019 Cranberry. All rights reserved.
//

import Foundation

///
/// Delegate protocol of the view controller that displays the list of tile servers
///
///
protocol PreferencesTableViewControllerDelegate: class {
    
    /// User updated tile server
    func didUpdateTileServer(_ newGpxTileServer: Int)
    
    /// User updated the usage of the caché
    func didUpdateUseCache(_ newUseCache: Bool)
    
    /// User update the usage of imperial units
    func didUpdateUseImperial(_ newUseImperial: Bool)
    
}
