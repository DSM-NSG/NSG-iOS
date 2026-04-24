import UIKit
import MapKit

extension LocationViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard annotation is PlaceAnnotation else { return nil }
        let identifier = "PlaceMarker"
        let markerView: MKMarkerAnnotationView

        if let reused = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView {
            markerView = reused
            markerView.annotation = annotation
        } else {
            markerView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
        }

        markerView.canShowCallout = false
        markerView.glyphImage = UIImage(systemName: "mappin")
        if let placeAnnotation = annotation as? PlaceAnnotation {
            markerView.markerTintColor = placeAnnotation.category.activeColor
        } else {
            markerView.markerTintColor = .orange500
        }
        return markerView
    }

    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard let annotation = view.annotation as? PlaceAnnotation else { return }
        selectPlace(annotation: annotation, moveToCenter: true)
    }

    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        if mapView.selectedAnnotations.isEmpty {
            hideBottomSheet()
        }
    }
}

extension LocationViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        selectedPlacePosts.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LatestPostCell.identifier, for: indexPath) as! LatestPostCell
        let post = selectedPlacePosts[indexPath.row]
        cell.configure(with: post, secondaryText: placeAddressLabel.text)
        cell.onToggleLike = nil
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard indexPath.row < selectedPlacePosts.count else { return }
        let post = selectedPlacePosts[indexPath.row]
        let detailViewController = DetailViewController(post: post)
        navigationController?.pushViewController(detailViewController, animated: true)
    }
}
