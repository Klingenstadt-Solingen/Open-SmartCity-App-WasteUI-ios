import Combine
import SwiftUICore
import MapKit
import OSCAEssentials
import OSCAWaste
import UIKit
import SwiftUI

public final class OSCAWasteGreenAndClothesViewController: UIViewController,
    UICollectionViewDelegate
{

    @IBOutlet private var button: UIButton!
    @IBOutlet private var mView: UIView!
    @IBOutlet private var mapView: MKMapView!
    @IBOutlet weak var containerListView: UIView!
    
    enum Section {
        case main
    }

    private typealias DataSourceLocation = UICollectionViewDiffableDataSource<
        Section, OSCAWasteGreenAndClothesLocation
    >
    private typealias SnapshotLocation = NSDiffableDataSourceSnapshot<
        Section, OSCAWasteGreenAndClothesLocation
    >

    private var viewModel: OSCAWasteGreenAndClothesViewModel!
    private var bindings = Set<AnyCancellable>()

    private var dataSourceLocation: DataSourceLocation!

    public override func viewDidLoad() {
        super.viewDidLoad()
        self.setupViews()
        self.setupBindings()
        self.viewModel.viewDidLoad(callback: self.createDistrictsButtonMenue)
        let listViewVC = UIHostingController(
            rootView: ContainerListView(viewModel: self.viewModel)
        )
        addChild(listViewVC)
        listViewVC.view.frame = containerListView.bounds
        containerListView.addSubview(listViewVC.view)
        listViewVC.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            listViewVC.view.leadingAnchor.constraint(equalTo: containerListView.leadingAnchor),
            listViewVC.view.trailingAnchor.constraint(equalTo: containerListView.trailingAnchor),
            listViewVC.view.topAnchor.constraint(equalTo: containerListView.topAnchor),
            listViewVC.view.bottomAnchor.constraint(equalTo: containerListView.bottomAnchor)])
        listViewVC.didMove(toParent: self)
    }

    private func setupViews() {
        self.view.backgroundColor =
            OSCAWasteUI.configuration.colorConfig.backgroundColor
        self.navigationItem.title = viewModel.screenTitle
        
        self.mView.backgroundColor = .clear
        self.mView.layer.cornerRadius = 10
        self.mView.layer.masksToBounds = false
        self.mView.layer.shadowColor = UIColor.black.cgColor
        self.mView.layer.shadowOpacity = 0.3
        self.mView.layer.shadowRadius = 10.0
        self.mView.layer.shadowOffset = CGSize(width: 0, height: 5)
        
        self.mapView.delegate = self
        self.mapView.register(
            MKMarkerAnnotationView.self,
            forAnnotationViewWithReuseIdentifier: "Annotation")

        let region = MKCoordinateRegion(center:  CLLocationCoordinate2D(latitude: 51.171517, longitude: 7.086807),span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))
        self.mapView.setRegion(region, animated: true)
    }

    private func setupBindings() {
        self.viewModel.$wasteLocations
            .receive(on: RunLoop.main)
            .dropFirst()
            .sink(receiveValue: { [weak self] wasteGreenAndClothesLocation in
                guard let `self` = self else { return }
                self.updateSectionLocation(wasteGreenAndClothesLocation)
                //collectionView.isHidden = wasteGreenMobileLocation.isEmpty
                if (wasteGreenAndClothesLocation.isEmpty) {
                    //self.setEmptyMessageCollectionView()
                } else {
                    //self.deleteEmptyMessageCollectionView()
                }
            })
            .store(in: &self.bindings)
    }

    func createDistrictsButtonMenue(districts: [OSCAWasteGreenAndClothesDistrict]) {
        DispatchQueue.main.async {
            let userDistricts = UserDefaults.standard.stringArray(
                forKey: OSCAWaste.greenWasteAppointmentDistrictsKey
              )
            let items = districts
            let actions: [UIAction] = items.map { item in
                let action = UIAction(title: item.name!) { action in
                    // The following updates the original UIAction without crashing
                    if let act = self.button.menu?.children.first(where: {
                        $0.title == action.title
                    }), let act = act as? UIAction {
                        if act.state == .on {
                            act.state = .off
                            self.viewModel.didDeselect(at: act.title)
                        } else {
                            act.state = .on
                            self.viewModel.didSelect(at: act.title)
                        }
                    }
                }
                if let userDistricts = userDistricts {
                    action.state = userDistricts
                        .contains(where: { district in action.title == district }) ? .on : .off
                } else {
                    action.state = .off
                }
                
                return action
            }
            
            self.button.menu = UIMenu(children: actions)
            self.button.showsMenuAsPrimaryAction = true
        }
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setup(
            largeTitles: true,
            tintColor: OSCAWasteUI.configuration.colorConfig
                .navigationTintColor,
            titleTextColor: OSCAWasteUI.configuration.colorConfig
                .navigationTitleTextColor,
            barColor: OSCAWasteUI.configuration.colorConfig.navigationBarColor)
    }

    private func updateSectionLocation(
        _ wasteGreenAndClothesLocation: [OSCAWasteGreenAndClothesLocation]
    ) {
        mapView.removeAnnotations(mapView.annotations)
        wasteGreenAndClothesLocation.enumerated().forEach({ (index, location) in
            let annotation = WastePointAnnotation()
            annotation.title = location.street + " " + location.streetNumber
            annotation.subtitle = String(index)
            annotation.coordinate = location.position.toCLLocationCoordinate2D()
            annotation.objectId = location.objectId
            self.mapView.addAnnotation(annotation)
        })

        self.mapView.showAnnotations(self.mapView.annotations, animated: true)
    }
    
    func createSpinnerView() -> UIView{
        let child = SpinnerViewController()
        addChild(child)
        child.view.frame = view.frame
        view.addSubview(child.view)
        child.didMove(toParent: self)
        return child.view
    }

}

class WastePointAnnotation: MKPointAnnotation {
    var objectId: Int? = nil
}

// MARK: - instantiate view conroller
extension OSCAWasteGreenAndClothesViewController: StoryboardInstantiable {
    public static func create(with viewModel: OSCAWasteGreenAndClothesViewModel)
        -> OSCAWasteGreenAndClothesViewController
    {
        let vc = Self.instantiateViewController(OSCAWasteUI.bundle)
        vc.viewModel = viewModel
        return vc
    }
}

extension OSCAWasteGreenAndClothesViewController: MKMapViewDelegate {
    public func mapView(
        _ mapView: MKMapView, viewFor annotation: any MKAnnotation
    ) -> MKAnnotationView? {
        guard !annotation.isKind(of: MKUserLocation.self) else { return nil }
        guard
            let markerAnnotationView = mapView.dequeueReusableAnnotationView(
                withIdentifier: "Annotation",
                for: annotation) as? MKMarkerAnnotationView
        else { return nil }
        markerAnnotationView.tag = Int((annotation.subtitle ?? "0")!)!
        markerAnnotationView.addGestureRecognizer(
            UITapGestureRecognizer(
                target: self, action: #selector(self.didTapAnnotationView(_:))))

        return markerAnnotationView
    }

    @objc func didTapAnnotationView(_ gesture: UITapGestureRecognizer) {
        let indexPath = IndexPath(item: gesture.view?.tag ?? 0, section: 0)
    }
    
    public func mapView(
        _ mapView: MKMapView,
        didSelect view: MKAnnotationView
    ) {
        if let pointAnnotation = view.annotation as? WastePointAnnotation, let objectId = pointAnnotation.objectId {
            viewModel.scrollObjectId = objectId
        }
    }
}


class SpinnerViewController: UIViewController {
    var spinner = UIActivityIndicatorView(style: .whiteLarge)

    override func loadView() {
        view = UIView()
        view.backgroundColor = UIColor(white: 0, alpha: 0.1)

        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.startAnimating()
        view.addSubview(spinner)

        spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
}
