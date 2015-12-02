//
//  URAlamofireLogExtension.swift
//  ureport
//
//  Created by John Dalton Costa Cordeiro on 02/12/15.
//  Copyright © 2015 ilhasoft. All rights reserved.
//

import Alamofire

extension Request {
    public func debugLog() -> Self {
//        #if DEBUG
            debugPrint(self)
//        #endif
        return self
    }
}
