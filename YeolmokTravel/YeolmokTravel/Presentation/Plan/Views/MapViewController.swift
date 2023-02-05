//
//  MapViewController.swift
//  YeolmokTravel
//
//  Created by 김동욱 on 2023/02/03.
//

import UIKit
import MapKit
import CoreLocation

struct AnnotatedCoordinate {
    let title: String
    let coordinate: CLLocationCoordinate2D
}

final class MapViewController: UIViewController {
    // MARK: - Properties
    private let mapView: MKMapView = {
        let mapView = MKMapView()
        mapView.preferredConfiguration = MKStandardMapConfiguration(emphasisStyle: .muted)
        return mapView
    }()
    
    private let annotatedCoordinates: [AnnotatedCoordinate]
    
    init(_ annotatedCoordinates: [AnnotatedCoordinate]) {
        self.annotatedCoordinates = annotatedCoordinates
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) not implemented.")
    }
    
    deinit {
        print("deinit: MapViewController")
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

private extension MapViewController {
    func configureMapView() {
        guard let span = calculateSpan() else { return }
        mapView.region = MKCoordinateRegion(
            center: calculateCenter(),
            span: span
        )
        
        for annotatedCoordinate in annotatedCoordinates {
            let annotation = MKPointAnnotation()
            annotation.coordinate = annotatedCoordinate.coordinate
            annotation.title = annotatedCoordinate.title
            mapView.addAnnotation(annotation)
        }
    }
    
    // reduce
    func calculateCenter() -> CLLocationCoordinate2D {
        var latitude: CLLocationDegrees = 0
        var longitude: CLLocationDegrees = 0
        
        for annotatedCoordinate in annotatedCoordinates {
            latitude += annotatedCoordinate.coordinate.latitude
            longitude += annotatedCoordinate.coordinate.longitude
        }
        
        latitude /= Double(annotatedCoordinates.count)
        longitude /= Double(annotatedCoordinates.count)
        
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    // 최대 차이 + 조금
    func calculateSpan() -> MKCoordinateSpan? {
        if annotatedCoordinates.count == 1 {
            return MKCoordinateSpan(
                latitudeDelta: CoordinateConstants.mapSpan,
                longitudeDelta: CoordinateConstants.mapSpan
            )
        }
        
        guard let minLatitude = annotatedCoordinates.min(by: { $0.coordinate.latitude < $1.coordinate.latitude }) else { return nil }
        guard let maxLatitude = annotatedCoordinates.max(by: { $0.coordinate.latitude < $1.coordinate.latitude }) else { return nil }
        let latitudeGap = maxLatitude.coordinate.latitude - minLatitude.coordinate.latitude + CoordinateConstants.littleSpan
        
        guard let minLongitude = annotatedCoordinates.min(by: { $0.coordinate.longitude < $1.coordinate.longitude }) else { return nil }
        guard let maxLongitude = annotatedCoordinates.max(by: { $0.coordinate.longitude < $1.coordinate.longitude }) else { return nil }
        let longitudeGap = maxLongitude.coordinate.latitude - minLongitude.coordinate.latitude + CoordinateConstants.littleSpan
        
        return MKCoordinateSpan(latitudeDelta: latitudeGap, longitudeDelta: longitudeGap)
    }
}

private enum CoordinateConstants {
    static let mapSpan: CLLocationDegrees = 0.005
    static let littleSpan: CLLocationDegrees = 0.01
}
