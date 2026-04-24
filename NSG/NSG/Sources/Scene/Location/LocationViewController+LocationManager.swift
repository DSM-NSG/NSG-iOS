import UIKit
import CoreLocation
import MapKit

extension LocationViewController: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            if isManualLocationRequest {
                manager.requestLocation()
            }
            requestInitialLocation()
        case .denied, .restricted:
            applyFallbackMapRegionIfNeeded()
        case .notDetermined:
            break
        @unknown default:
            applyFallbackMapRegionIfNeeded()
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let now = Date()

        let candidate = locations.reversed().first { location in
            location.horizontalAccuracy > 0
            && location.horizontalAccuracy <= 500
            && abs(location.timestamp.timeIntervalSince(now)) <= 30
        } ?? locations.last

        if isManualLocationRequest, let latest = candidate {
            mapView.setUserTrackingMode(.follow, animated: true)
            centerMapOnLocation(latest, animated: true)
            isManualLocationRequest = false
            if isAwaitingInitialLocation {
                completeInitialLocationRequest()
            }
            return
        }

        guard !hasCenteredOnUserLocation else { return }

        if let latest = candidate, isCoordinateInKorea(latest.coordinate) {
            centerMapOnLocation(latest, animated: false)
            completeInitialLocationRequest()
            return
        }

        if let deadline = initialLocationDeadline, now >= deadline {
            applyFallbackMapRegionIfNeeded()
            completeInitialLocationRequest()
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        if isManualLocationRequest {
            isManualLocationRequest = false
            let alert = UIAlertController(
                title: "위치를 찾을 수 없어요",
                message: "잠시 후 다시 시도해주세요.",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "확인", style: .default))
            present(alert, animated: true)
        }
        if isAwaitingInitialLocation, let deadline = initialLocationDeadline, Date() >= deadline {
            applyFallbackMapRegionIfNeeded()
            completeInitialLocationRequest()
        }
    }
}
