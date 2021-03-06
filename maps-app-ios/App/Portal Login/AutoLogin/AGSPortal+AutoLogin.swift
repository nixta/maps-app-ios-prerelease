//
//  AGSPortal+AutoLogin.swift
//  maps-app-ios
//
//  Created by Nicholas Furness on 4/27/17.
//  Copyright © 2017 Esri. All rights reserved.
//

import ArcGIS

extension AGSPortal {
    static func bestPortalFromCachedCredentials(portalURL: URL?, completion: @escaping ((AGSPortal, Bool) -> Void)) {
        // The credential cache will have at most one valid cached credential. We want to see if it will log us into the portal.
        // 
        // If a custom portal URL is provided, we'll use that, but otherwise we'll use ArcGIS Online.
        //
        // If we don't have cached credentials that automatically log us in to that portal, then we connect to 
        // the portal anonymously (i.e. not logged in).
        
        // First try a portal that requires a login. If there are cached credentials that suit, we will be logged in to the portal.
        let newPortal = (portalURL != nil) ? AGSPortal(url: portalURL!, loginRequired: true) : AGSPortal.arcGISOnline(withLoginRequired: true)
        
        // We'll temporarily disable prompting the user to log in if the cached credentials are not suitable to log us in.
        let preferredAuthChallengeRule = AGSRequestConfiguration.global().shouldIssueAuthenticationChallenge
        AGSRequestConfiguration.global().shouldIssueAuthenticationChallenge = { _ in return false }
        
        newPortal.load() { error in
            // Before we do anything else, go back to handling auth challenges as before.
            AGSRequestConfiguration.global().shouldIssueAuthenticationChallenge = preferredAuthChallengeRule
            
            // If we were able to log in with cached credentials, there will be no error.
            if error == nil {
                completion(newPortal, true)
            } else {
                // Could not log in silently with cached credentials, so let's return a portal that doesn't require login
                print("Error loading the new portal: \(error!.localizedDescription)")
                if let newURL = newPortal.url {
                    // Portal URL was specified. Let's use that.
                    completion(AGSPortal(url: newURL, loginRequired: false), false)
                } else {
                    // Fall back to ArcGIS Online
                    completion(AGSPortal.arcGISOnline(withLoginRequired: false), false)
                }
            }
        }
    }
}
