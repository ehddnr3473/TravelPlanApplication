//
//  MapViewController.swift
//  YeolmokTravel
//
//  Created by 김동욱 on 2023/02/03.
//

import UIKit
import MapKit
import CoreLocation

protocol Mappable: CameraControllable, AnyObject {
    var mapView: MKMapView { get }
    func configureMapView()
    func updateMapView(_ coordinates: [CLLocationCoordinate2D])
}

protocol CameraControllable: AnyObject {
    func initializePointer()
    func increasePointer()
    func decreasePointer()
}

final class MapViewController: UIViewController {
    // MARK: - Properties
    private var coordinates: [CLLocationCoordinate2D]
    private lazy var coordinatePointer = PointerConstants.initialValue
    
    init(_ coordinates: [CLLocationCoordinate2D]) {
        self.coordinates = coordinates
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) not implemented.")
    }
    
    deinit {
        print("deinit: MapViewController")
    }
    
    let mapView: MKMapView = {
        let mapView = MKMapView()
        mapView.preferredConfiguration = MKStandardMapConfiguration(elevationStyle: .realistic)
        mapView.layer.cornerRadius = LayoutConstants.cornerRadius
        mapView.layer.borderWidth = AppLayoutConstants.borderWidth
        mapView.layer.borderColor = UIColor.white.cgColor
        mapView.accessibilityLabel = AppTextConstants.mapViewAccessibilityLabel
        return mapView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(mapView)
        configureMapView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        mapView.frame = view.frame
    }
}

// MARK: - Mappable(Packaging)
extension MapViewController: Mappable {
    func configureMapView() {
        configure()
        animateCameraToCenter()
        addAnnotation()
    }
    
    func updateMapView(_ coordinates: [CLLocationCoordinate2D]) {
        removeAnnotation()
        updateCoordinates(coordinates)
        animateCameraToCenter()
        addAnnotation()
    }
}

// MARK: - CameraControllable(Packaging) / Pointer control
extension MapViewController {
    func initializePointer() {
        coordinatePointer = PointerConstants.initialValue
        animateCameraToCenter()
    }
    
    private func updatePointer(_ coordinate: CLLocationCoordinate2D) {
        guard let index = findCoordinate(coordinate) else { return }
        coordinatePointer = index
    }
    
    func increasePointer() {
        coordinatePointer = (coordinatePointer + 1) % coordinates.count
        animateCameraToPointer()
    }
    
    func decreasePointer() {
        if coordinatePointer <= 0 {
            coordinatePointer = coordinates.count - 1
        } else {
            coordinatePointer = (coordinatePointer - 1) % coordinates.count
        }
        animateCameraToPointer()
    }
    
    private func animateCameraToCenter() {
        UIView.animate(withDuration: 1, delay: 0, options: .curveEaseInOut) { [self] in
            guard let span = calculateSpan() else { return }
            mapView.region = MKCoordinateRegion(
                center: calculateCenter(),
                span: span
            )
        }
    }
    
    private func animateCameraToPointer() {
        animateCamera(to: coordinates[coordinatePointer])
    }
}

private extension MapViewController {
    func updateCoordinates(_ coordinates: [CLLocationCoordinate2D]) {
        self.coordinates = coordinates
    }
    
    @MainActor func addAnnotation() {
        for coordinate in coordinates {
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            mapView.addAnnotation(annotation)
        }
    }
    
    @MainActor func removeAnnotation() {
        mapView.removeAnnotations(mapView.annotations)
    }
    
    // reduce
    func calculateCenter() -> CLLocationCoordinate2D {
        var latitude: CLLocationDegrees = 0
        var longitude: CLLocationDegrees = 0
        
        for coordinate in coordinates {
            latitude += coordinate.latitude
            longitude += coordinate.longitude
        }
        
        latitude /= Double(coordinates.count)
        longitude /= Double(coordinates.count)
        
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    // 최대 차이 + 조금
    func calculateSpan() -> MKCoordinateSpan? {
        if coordinates.count == 1 {
            return MKCoordinateSpan(
                latitudeDelta: CoordinateConstants.mapSpan,
                longitudeDelta: CoordinateConstants.mapSpan
            )
        }
        
        guard let minLatitude = coordinates.min(by: { $0.latitude < $1.latitude }) else { return nil }
        guard let maxLatitude = coordinates.max(by: { $0.latitude < $1.latitude }) else { return nil }
        let latitudeGap = maxLatitude.latitude - minLatitude.latitude +
        (maxLatitude.latitude - minLatitude.latitude > CoordinateConstants.wideRange ? CoordinateConstants.largeSpan : CoordinateConstants.littleSpan)
        
        guard let minLongitude = coordinates.min(by: { $0.longitude < $1.longitude }) else { return nil }
        guard let maxLongitude = coordinates.max(by: { $0.longitude < $1.longitude }) else { return nil }
        let longitudeGap = maxLongitude.latitude - minLongitude.latitude +
        (maxLongitude.latitude - minLongitude.latitude > CoordinateConstants.wideRange ? CoordinateConstants.largeSpan : CoordinateConstants.littleSpan)
        
        return MKCoordinateSpan(latitudeDelta: latitudeGap, longitudeDelta: longitudeGap)
    }
}

extension MapViewController: MKMapViewDelegate {
    private func configure() {
        mapView.delegate = self
    }
    
    func animateCamera(to coordinate: CLLocationCoordinate2D) {
        UIView.animate(withDuration: 1, delay: 0, options: .curveEaseInOut) { [self] in
            mapView.region = MKCoordinateRegion(center: coordinate,
                                                      latitudinalMeters: CoordinateConstants.pointSpan,
                                                      longitudinalMeters: CoordinateConstants.pointSpan)
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let annotationView = MKAnnotationView()
        guard coordinates.count > 1,
                let order = findCoordinate(annotation.coordinate),
                order <= CoordinateConstants.maximumNumberOfCoordinates else { return nil }
        annotationView.image = createImage(order + 1)
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, didDeselect annotation: MKAnnotation) {
        animateCameraToCenter()
    }
    
    func mapView(_ mapView: MKMapView, didSelect annotation: MKAnnotation) {
        animateCamera(to: annotation.coordinate)
        updatePointer(annotation.coordinate)
    }
    
    private func findCoordinate(_ coordinate: CLLocationCoordinate2D) -> Int? {
        coordinates.firstIndex {
            $0.latitude == coordinate.latitude && $0.longitude == coordinate.longitude
        }
    }
    
    private func createImage(_ order: Int) -> UIImage? {
        let iconName = "\(order).circle.fill"
        return UIImage(systemName: iconName)
    }
}

private enum CoordinateConstants {
    static let mapSpan: CLLocationDegrees = 0.005
    static let littleSpan: CLLocationDegrees = 0.02
    static let wideRange: CLLocationDegrees = 5
    static let largeSpan: CLLocationDegrees = 1
    static let pointSpan: CLLocationDistance = 300
    static let maximumNumberOfCoordinates = 50
}

private enum PointerConstants {
    static let initialValue = -1
}

private enum LayoutConstants {
    static let cornerRadius: CGFloat = 10
}
