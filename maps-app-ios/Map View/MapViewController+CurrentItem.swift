//
//  MapViewController+CurrentItem.swift
//  maps-app-ios
//
//  Created by Nicholas Furness on 5/5/17.
//  Copyright © 2017 Esri. All rights reserved.
//

import ArcGIS

extension MapViewController {
    func setupCurrentItemWatcher() {
        NotificationCenter.default.addObserver(forName: MapsAppNotifications.Names.CurrentItemChanged, object: nil, queue: nil) { _ in
            self.displayCurrentItem()
        }
    }
    
    func displayCurrentItem() {
        if let item = mapsAppState.currentItem, item.type == .webMap {
            let map = AGSMap(item: item)
            map.load() { error in
                guard error == nil else {
                    self.showError(title: "Error opening the map", message: error!.localizedDescription)
                    return
                }
                
                // Workaround: Runtime v100 bug.
                // If LocationDisplay is on, setting the map does not update the extent.
                // Target release for fix: Update 1.
                if let ext = map.item?.extent, self.mapView.locationDisplay.started {
                    defer {
                        self.mapView.setViewpoint(AGSViewpoint(targetExtent: ext))
                    }
                }
                
                self.mapView.map = map
            }
        }
    }
}
