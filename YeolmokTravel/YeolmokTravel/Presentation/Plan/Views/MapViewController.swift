//
//  MapViewController.swift
//  YeolmokTravel
//
//  Created by 김동욱 on 2023/02/03.
//

import UIKit
import MapKit
import CoreLocation

final class MapViewController: UIViewController {

    private let mapView: MKMapView = {
        let mapView = MKMapView()
        mapView.preferredConfiguration = MKStandardMapConfiguration(emphasisStyle: .muted)
        return mapView
    }()
    
    private let coordinate: CLLocationCoordinate2D
    private let span: CLLocationDegrees = CoordinateConstants.mapSpan
    private let pinTitle: String
    
    init(coordinate: CLLocationCoordinate2D, pinTitle: String) {
        self.coordinate = coordinate
        self.pinTitle = pinTitle
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
    
    private func configureMapView() {
        mapView.region = MKCoordinateRegion(
            center: coordinate,
            span: MKCoordinateSpan(latitudeDelta: span, longitudeDelta: span)
        )
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = pinTitle
        
        mapView.addAnnotation(annotation)
    }
}

private enum CoordinateConstants {
    static let mapSpan: CLLocationDegrees = 0.005
}
