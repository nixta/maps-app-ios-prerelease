//
//  AGSRouteTask+DefaultParameters.swift
//  maps-app-ios
//
//  Created by Nicholas Furness on 4/23/17.
//  Copyright © 2017 Esri. All rights reserved.
//
//  This class extends AGSRouteTask to avoid unnecessary requests to get Default Parameters from a service.

import ArcGIS

extension AGSRouteTask {
    
    fileprivate struct AssociatedKeys {
        static var cachedDefaultParametersKey = "geodev_cachedDefaultParameters"
    }
    
    var cachedDefaultParameters:AGSRouteParameters? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.cachedDefaultParametersKey) as? AGSRouteParameters
        }
        set {
            if let defaultParams = newValue {
                objc_setAssociatedObject(self, &AssociatedKeys.cachedDefaultParametersKey, defaultParams, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
    }
    
    public func loadCachedDefaultParameters(completion:@escaping (AGSRouteParameters?, Error?) -> Void) {
        if let params = cachedDefaultParameters {
            completion(params, nil)
        } else {
            self.defaultRouteParameters(completion: { (params, error) in
                if error == nil {
                    self.cachedDefaultParameters = params
                }
                completion(params, error)
            })
        }
    }
}