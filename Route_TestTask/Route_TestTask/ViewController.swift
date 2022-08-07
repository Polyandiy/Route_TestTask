//
//  ViewController.swift
//  Route_TestTask
//
//  Created by Поляндий on 01.08.2022.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController {
    
    let mapView : MKMapView = {
        let mapView = MKMapView()
        mapView.translatesAutoresizingMaskIntoConstraints = false
        return mapView
    }()
    
    let buttonAddAddress : UIButton = {
        let button = UIButton()
        button.setTitle("Add Address", for: .normal)
        button.backgroundColor = .blue
        button.tintColor = .white
        button.layer.cornerRadius = 30
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let buttonRoute : UIButton = {
        let button = UIButton()
        button.setTitle("Route", for: .normal)
        button.backgroundColor = .blue
        button.tintColor = .white
        button.layer.cornerRadius = 30
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isHidden = true
        return button
    }()
    
    let buttonReset : UIButton = {
        let button = UIButton()
        button.setTitle("Reset", for: .normal)
        button.backgroundColor = .blue
        button.tintColor = .white
        button.layer.cornerRadius = 30
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isHidden = true
        return button
    }()
    
    var annotationsArray = [MKPointAnnotation]()
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        
        setConstraints()
        
        buttonAddAddress.addTarget(self, action: #selector(addAddressTapped), for: .touchUpInside)
        buttonAddAddress.addTarget(self, action: #selector(routeTapped), for: .touchUpInside)
        buttonAddAddress.addTarget(self, action: #selector(resetTapped), for: .touchUpInside)
    }
    
    @objc func addAddressTapped() {
        alertAddAddress(title: "Добавить", placeholder: "Введите адрес") { [self] (text) in
            setupPlacemark(addressPlace: text)
        }
    } 
    @objc func routeTapped() {
        print("route")
        for index in 0...annotationsArray.count-1 {
            showRouteOnMap(startCoordinate: annotationsArray[index].coordinate, destinationCoordinate: annotationsArray[index+1].coordinate)
        }
        mapView.showAnnotations(annotationsArray, animated: true)
    }
    @objc func resetTapped() {
        print("reset")
        mapView.removeOverlay(mapView.overlays)
        mapView.removeAnnotation(mapView.annotations)
        annotationsArray = [MKPointAnnotation]()
        buttonRoute.isHidden = true
        buttonReset.isHidden = true
    }
    
    
    func setupPlacemark (addressPlace: String) {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(addressPlace) { [self] (placemarks, error) in
            if let error = error {
                print(error)
                errorAlert(title: "Ошибка", message: "Попробуйте еще раз.")
                return
            }
            
            guard let placemarks = placemarks else { return }
            let placemark = placemarks.first
            
            let annotation = MKPointAnnotation()
            annotation.title = "\(addressPlace)"
            guard let placemarkLocation = placemark?.location else { return }
            annotation.coordinate = placemarkLocation.coordinate
            
            annotationsArray.append(annotation)
            if annotationsArray.count > 2 {
                buttonRoute.isHidden = false
                buttonReset.isHidden = false
            }
            mapView.showAnnotations(annotationsArray, animated: true)
        }
    }
    
    func showRouteOnMap(startCoordinate: CLLocationCoordinate2D, destinationCoordinate: CLLocationCoordinate2D) {
        let startLocation = MKPlacemark(coordinate: startCoordinate)
        let destinationLocation = MKPlacemark(coordinate: destinationCoordinate)
        
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: startLocation)
        request.destination = MKMapItem(placemark: destinationLocation)
        request.transportType = .walking
        request.requestsAlternateRoutes = true
        
        let direction = MKDirections(request: request)
        direction.calculate{(response, error) -> Void in
            if let error = error {
                print(error)
                return
            }
            guard let response = response else {
                self.errorAlert(title: "Ошибка", message: "Маршрут недоступен")
                return
            }
            
            var minRoute = response.routes[0]
            for route in response.routes {
                minRoute = (route.distance < minRoute.distance) ? route : minRoute
            }
            
            self.mapView.addOverlay(minRoute.polyline)
        }
    }
}

extension ViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay as! MKPolyline)
        renderer.strokeColor = .blue
        return renderer
    }
}

extension ViewController {
    
    func setConstraints() {
        view.addSubview(mapView)
        NSLayoutConstraint.activate ([
            mapView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0)
        ])
        
        mapView.addSubview(buttonAddAddress)
        NSLayoutConstraint.activate ([
            buttonAddAddress.topAnchor.constraint(equalTo: mapView.topAnchor, constant: 50),
            buttonAddAddress.trailingAnchor.constraint(equalTo: mapView.trailingAnchor, constant: -20),
            buttonAddAddress.heightAnchor.constraint(equalToConstant: 70),
            buttonAddAddress.widthAnchor.constraint(equalToConstant: 150)
        ])
        
        mapView.addSubview(buttonRoute)
        NSLayoutConstraint.activate ([
            buttonRoute.leadingAnchor.constraint(equalTo: mapView.leadingAnchor, constant: 20),
            buttonRoute.bottomAnchor.constraint(equalTo: mapView.bottomAnchor, constant: -30),
            buttonRoute.heightAnchor.constraint(equalToConstant: 70),
            buttonRoute.widthAnchor.constraint(equalToConstant: 90)
        ])
        
        mapView.addSubview(buttonReset)
        NSLayoutConstraint.activate ([
            buttonReset.bottomAnchor.constraint(equalTo: mapView.bottomAnchor, constant: -30),
            buttonReset.trailingAnchor.constraint(equalTo: mapView.trailingAnchor, constant: -20),
            buttonReset.heightAnchor.constraint(equalToConstant: 70),
            buttonReset.widthAnchor.constraint(equalToConstant: 90)
        ])
    }
}

