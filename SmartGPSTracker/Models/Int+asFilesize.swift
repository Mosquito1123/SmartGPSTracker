//
//  Int+asFilesize.swift
//  SmartGPSTracker
//
//  Created by Mosquito1123 on 11/07/2019.
//  Copyright © 2019 Cranberry. All rights reserved.
//

import Foundation
/// Extension to display humanized filesizes
extension Int {
    
    /// Returns the integer as file size humanized (for instance: 1024 -> "1 KB" )
    func asFileSize() -> String {
        let bcf = ByteCountFormatter()
        bcf.allowedUnits = [.useAll]
        bcf.countStyle = .file
        let string = bcf.string(fromByteCount: Int64(self))
        //print("formatted result: \(string)")
        return string
    }
}
