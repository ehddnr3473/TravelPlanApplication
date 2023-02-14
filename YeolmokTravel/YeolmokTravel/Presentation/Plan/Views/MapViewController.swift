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
    func animateCameraToPreviousPoint()
    func animateCameraToCenterPoint()
    func animateCameraToNextPoint()
}

final class MapViewController: UIViewController {
    // MARK: - Properties
    private var coordinates: [CLLocationCoordinate2D]
    private lazy var coordinatePointer = PointerConstants.initialValue
    
    private var inRange: Bool {
        -1 < coordinatePointer && coordinatePointer < coordinates.count
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
    
    init(_ coordinates: [CLLocationCoordinate2D]) {
        self.coordinates = coordinates
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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
    /*
     Path는 실용적으로 구현하지 않았기 때문에 보류.
     */
    func configureMapView() {
        mapView.overrideUserInterfaceStyle = .light
        configure()
        animateCameraToCenter()
        addAnnotation()
//        addPath()
    }
    
    func updateMapView(_ coordinates: [CLLocationCoordinate2D]) {
//        removePath()
        removeAnnotation()
        updateCoordinates(coordinates)
        animateCameraToCenter()
        addAnnotation()
//        addPath()
    }
}

// MARK: - CameraControllable(Packaging) / Pointer control
extension MapViewController {
    func animateCameraToPreviousPoint() {
        decreasePointer()
        animateCameraToCenter(completion: animateCameraToPoint)
    }
    
    func animateCameraToCenterPoint() {
        initializePointer()
        animateCameraToCenter()
    }
    
    func animateCameraToNextPoint() {
        increasePointer()
        animateCameraToCenter(completion: animateCameraToPoint)
    }
    
    private func animateCameraToPoint() {
        UIView.animate(withDuration: AnimationConstants.duration, delay: .zero, options: .curveEaseInOut) { [self] in
            guard inRange else { return }
            mapView.region = MKCoordinateRegion(center: coordinates[coordinatePointer],
                                                      latitudinalMeters: CoordinateConstants.pointSpan,
                                                      longitudinalMeters: CoordinateConstants.pointSpan)
        }
    }
    
    private func decreasePointer() {
        if coordinatePointer <= 0 {
            coordinatePointer = coordinates.count - 1
        } else {
            coordinatePointer = (coordinatePointer - 1) % coordinates.count
        }
    }
    
    private func initializePointer() {
        coordinatePointer = PointerConstants.initialValue
    }
    
    private func increasePointer() {
        coordinatePointer = (coordinatePointer + 1) % coordinates.count
    }
    
    private func updatePointer(_ coordinate: CLLocationCoordinate2D) {
        guard let index = findCoordinate(coordinate) else { return }
        coordinatePointer = index
    }
    
    /// 카메라 애니메이션
    /// - Parameter animateCameraToPoint: 카메라를 특정 좌표로 이동하기 위한 메서드
    /// 1. 중심으로 카메라 이동. 이때, completion == nil
    /// 2. 중심으로 이동한 후, completion을 수행하여 (포인터를 활용해)특정 좌표로 카메라 이동
    private func animateCameraToCenter(completion animateCameraToPoint: (() -> Void)? = nil) {
        UIView.animate(withDuration: AnimationConstants.duration, delay: .zero, options: .curveEaseInOut, animations: { [self] in
            guard let span = calculateSpan() else { return }
            mapView.region = MKCoordinateRegion(
                center: calculateCenter(),
                span: span
            )
        }, completion: { _ in
            guard let animateCameraToPoint = animateCameraToPoint else { return }
            animateCameraToPoint()
        })
    }
}

private extension MapViewController {
    func updateCoordinates(_ coordinates: [CLLocationCoordinate2D]) {
        self.coordinates = coordinates
    }
    
    func addAnnotation() {
        for coordinate in coordinates {
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            DispatchQueue.main.async { [self] in
                mapView.addAnnotation(annotation)
            }
        }
    }
    
    func removeAnnotation() {
        DispatchQueue.main.async { [self] in
            mapView.removeAnnotations(mapView.annotations)
        }
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
    
    func addPath() {
        let polyline = MKPolyline(coordinates: coordinates, count: coordinates.count)
        DispatchQueue.main.async { [self] in
            mapView.addOverlay(polyline)
        }
    }
    
    func removePath() {
        DispatchQueue.main.async { [self] in
            mapView.removeOverlays(mapView.overlays)
        }
    }
}

extension MapViewController: MKMapViewDelegate {
    private func configure() {
        mapView.delegate = self
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
        updatePointer(annotation.coordinate)
        animateCameraToPoint()
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let polyline = overlay as? MKPolyline {
            let renderer = MKPolylineRenderer(polyline: polyline)
            renderer.strokeColor = .blue
            renderer.lineWidth = 3
            return renderer
        }
        return MKOverlayRenderer(overlay: overlay)
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

private enum AnimationConstants {
    static let duration: TimeInterval = 1.5
}
