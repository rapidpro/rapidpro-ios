//
//  URStringExtension.swift
//  ureport
//
//  Created by Daniel Amaral on 03/11/15.
//  Copyright © 2015 ilhasoft. All rights reserved.
//

import UIKit

extension String {
    var localized: String {
        return NSLocalizedString(self, tableName: nil, bundle: Bundle.main, value: "", comment: "")
    }
}
