//
//  LocationViewController.swift
//  NSG
//
//  Created by hawon on 3/16/26.
//
import UIKit
import MapKit
import SnapKit
import Then

@MainActor
final class LocationViewController: UIViewController {

    private enum PlaceCategory: String, CaseIterable {
        case cafe = "카페"
        case pcRoom = "PC방"
        case karaoke = "노래방"
        case restaurant = "맛집"
        case etc = "기타"

        var apiValue: String {
            switch self {
            case .cafe:
                return "CAFE"
            case .pcRoom:
                return "PC_ROOM"
            case .karaoke:
                return "KARAOKE"
            case .restaurant:
                return "RESTAURANT"
            case .etc:
                return "ETC"
            }
        }

        var activeColor: UIColor {
            switch self {
            case .cafe:
                return UIColor(named: "cafe") ?? UIColor(hex: "#7D6B5E")
            case .pcRoom:
                return UIColor(named: "pc") ?? UIColor(hex: "#4A7FC1")
            case .karaoke:
                return UIColor(named: "sing") ?? UIColor(hex: "#9B3FA8")
            case .restaurant:
                return UIColor(named: "eat") ?? .orange500
            case .etc:
                return UIColor(named: "etc") ?? UIColor(hex: "#6B7280")
            }
        }

        var inactiveColor: UIColor {
            switch self {
            case .cafe:
                return UIColor(named: "cafeNon") ?? UIColor(hex: "#7D6B5E").withAlphaComponent(0.7)
            case .pcRoom:
                return UIColor(named: "pcNon") ?? UIColor(hex: "#4A7FC1").withAlphaComponent(0.7)
            case .karaoke:
                return UIColor(named: "singNon") ?? UIColor(hex: "#9B3FA8").withAlphaComponent(0.7)
            case .restaurant:
                return UIColor(named: "eatNon") ?? .orange300
            case .etc:
                return UIColor(named: "etcNon") ?? UIColor(hex: "#6B7280").withAlphaComponent(0.7)
            }
        }
    }

    private final class PlaceAnnotation: MKPointAnnotation {
        let category: PlaceCategory
        let place: PlaceListResponseItem

        init(place: PlaceListResponseItem, category: PlaceCategory) {
            self.place = place
            self.category = category
            super.init()
            coordinate = CLLocationCoordinate2D(latitude: place.latitude, longitude: place.longitude)
            title = place.title
            subtitle = place.description
        }
    }

    private let tipService: TipServicing
    private var selectedCategory: PlaceCategory = .cafe
    private var currentAnnotation: PlaceAnnotation?
    private var allPlaces: [PlaceListResponseItem] = []
    private var filteredPlaces: [PlaceListResponseItem] = []
    private var selectedPlacePosts: [SharePost] = []
    private var placeListTask: Task<Void, Never>?
    private var placePostTask: Task<Void, Never>?

    private var bottomSheetHeightConstraint: Constraint?
    private var bottomSheetBottomConstraint: Constraint?
    private var routeButtonBottomConstraint: Constraint?

    private let mapView = MKMapView().then {
        $0.showsCompass = false
        $0.showsScale = false
        $0.pointOfInterestFilter = .includingAll
    }

    private let dimView = UIView().then {
        $0.backgroundColor = UIColor.black.withAlphaComponent(0.15)
        $0.alpha = 0
        $0.isHidden = true
    }

    private let searchContainerView = UIView().then {
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 10
    }

    private let searchTextField = UITextField().then {
        $0.font = .style(.body3)
        $0.textColor = .black800
        $0.tintColor = .orange500
        $0.returnKeyType = .search
        $0.clearButtonMode = .whileEditing
        $0.attributedPlaceholder = NSAttributedString(
            string: "키워드 혹은 찾고싶은 걸 검색해보세요.",
            attributes: [.foregroundColor: UIColor.black400]
        )
    }

    private let categoryStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 8
        $0.alignment = .fill
        $0.distribution = .fillProportionally
    }

    private lazy var categoryButtons: [UIButton] = PlaceCategory.allCases.map { category in
        UIButton(type: .system).then {
            $0.tag = PlaceCategory.allCases.firstIndex(of: category) ?? 0
            $0.layer.cornerRadius = 4
            $0.setTitle(category.rawValue, for: .normal)
            $0.titleLabel?.font = .style(.body3)
            $0.addTarget(self, action: #selector(didTapCategoryButton(_:)), for: .touchUpInside)
        }
    }

    private let writeButton = UIButton(type: .system).then {
        $0.setImage(UIImage(named: "write"), for: .normal)
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 10
        $0.layer.shadowColor = UIColor.black.cgColor
        $0.layer.shadowOpacity = 0.12
        $0.layer.shadowRadius = 6
        $0.layer.shadowOffset = CGSize(width: 0, height: 2)
    }

    private let routeButton = UIButton(type: .system).then {
        $0.setTitle("길찾기", for: .normal)
        $0.setTitleColor(.white, for: .normal)
        $0.titleLabel?.font = .style(.header4)
        $0.backgroundColor = .orange500
        $0.layer.cornerRadius = 16
        $0.isHidden = true
    }

    private let bottomSheetView = UIView().then {
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 20
        $0.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        $0.clipsToBounds = true
    }

    private let sheetHandle = UIView().then {
        $0.backgroundColor = .black200
        $0.layer.cornerRadius = 2
    }

    private let placeNameLabel = UILabel().then {
        $0.font = .style(.header2)
        $0.textColor = .black800
        $0.numberOfLines = 1
    }

    private let placeAddressLabel = UILabel().then {
        $0.font = .style(.body3)
        $0.textColor = .black500
        $0.numberOfLines = 2
    }

    private let postTitleLabel = UILabel().then {
        $0.text = "위 장소가 포함된 글"
        $0.font = .style(.header3)
        $0.textColor = .black800
    }

    private let emptyPostsLabel = UILabel().then {
        $0.text = "해당 장소 관련 게시글이 아직 없어요."
        $0.font = .style(.body3)
        $0.textColor = .black500
        $0.textAlignment = .center
        $0.isHidden = true
    }

    private let postsCollectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: {
            let layout = UICollectionViewFlowLayout()
            layout.scrollDirection = .vertical
            layout.minimumLineSpacing = 10
            layout.minimumInteritemSpacing = 0
            layout.itemSize = CGSize(width: UIScreen.main.bounds.width - 40, height: 100)
            return layout
        }()
    ).then {
        $0.backgroundColor = .clear
        $0.showsVerticalScrollIndicator = false
    }

    init(tipService: TipServicing) {
        self.tipService = tipService
        super.init(nibName: nil, bundle: nil)
    }

    convenience init() {
        self.init(tipService: TipService.shared)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupLayout()
        bindActions()
        updateCategoryButtonStyles()
        configureInitialMapRegion()
        fetchPlaces()
    }

    private func setupUI() {
        view.backgroundColor = .background
        mapView.delegate = self
        searchTextField.delegate = self
        postsCollectionView.delegate = self
        postsCollectionView.dataSource = self
        postsCollectionView.register(LatestPostCell.self, forCellWithReuseIdentifier: LatestPostCell.identifier)

        view.addSubview(mapView)
        view.addSubview(dimView)
        view.addSubview(searchContainerView)
        view.addSubview(categoryStackView)
        view.addSubview(writeButton)
        view.addSubview(routeButton)
        view.addSubview(bottomSheetView)

        searchContainerView.addSubview(searchTextField)
        categoryButtons.forEach { categoryStackView.addArrangedSubview($0) }

        [
            sheetHandle,
            placeNameLabel,
            placeAddressLabel,
            postTitleLabel,
            emptyPostsLabel,
            postsCollectionView
        ].forEach { bottomSheetView.addSubview($0) }
    }

    private func setupLayout() {
        mapView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        dimView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        searchContainerView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(12)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(44)
        }

        searchTextField.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12))
        }

        categoryStackView.snp.makeConstraints {
            $0.top.equalTo(searchContainerView.snp.bottom).offset(10)
            $0.leading.trailing.equalTo(searchContainerView)
            $0.height.equalTo(30)
        }

        writeButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(20)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(86)
            $0.size.equalTo(44)
        }

        routeButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(20)
            routeButtonBottomConstraint = $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(28).constraint
            $0.height.equalTo(32)
            $0.width.equalTo(72)
        }

        bottomSheetView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            bottomSheetBottomConstraint = $0.bottom.equalToSuperview().offset(320).constraint
            bottomSheetHeightConstraint = $0.height.equalTo(320).constraint
        }

        sheetHandle.snp.makeConstraints {
            $0.top.equalToSuperview().offset(10)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(44)
            $0.height.equalTo(4)
        }

        placeNameLabel.snp.makeConstraints {
            $0.top.equalTo(sheetHandle.snp.bottom).offset(14)
            $0.leading.trailing.equalToSuperview().inset(20)
        }

        placeAddressLabel.snp.makeConstraints {
            $0.top.equalTo(placeNameLabel.snp.bottom).offset(6)
            $0.leading.trailing.equalToSuperview().inset(20)
        }

        postTitleLabel.snp.makeConstraints {
            $0.top.equalTo(placeAddressLabel.snp.bottom).offset(14)
            $0.leading.trailing.equalToSuperview().inset(20)
        }

        emptyPostsLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(postTitleLabel.snp.bottom).offset(28)
        }

        postsCollectionView.snp.makeConstraints {
            $0.top.equalTo(postTitleLabel.snp.bottom).offset(8)
            $0.leading.trailing.bottom.equalToSuperview()
        }
    }

    private func bindActions() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapDimView))
        dimView.addGestureRecognizer(tapGesture)
        routeButton.addTarget(self, action: #selector(didTapRouteButton), for: .touchUpInside)
    }

    private func configureInitialMapRegion() {
        let center = CLLocationCoordinate2D(latitude: 36.3918, longitude: 127.3632)
        let region = MKCoordinateRegion(center: center, latitudinalMeters: 3000, longitudinalMeters: 3000)
        mapView.setRegion(region, animated: false)
    }

    @objc
    private func didTapCategoryButton(_ sender: UIButton) {
        guard sender.tag < PlaceCategory.allCases.count else { return }
        selectedCategory = PlaceCategory.allCases[sender.tag]
        updateCategoryButtonStyles()
        fetchPlaces()
    }

    private func updateCategoryButtonStyles() {
        for (index, button) in categoryButtons.enumerated() {
            let category = PlaceCategory.allCases[index]
            let isSelected = category == selectedCategory
            button.backgroundColor = isSelected ? category.activeColor : category.inactiveColor
            button.layer.borderWidth = 0
            button.setTitleColor(.white, for: .normal)
        }
    }

    private func fetchPlaces() {
        placeListTask?.cancel()
        placeListTask = Task { [weak self] in
            guard let self else { return }

            do {
                let places = try await tipService.listPlaces(category: selectedCategory.apiValue)
                allPlaces = places
                applyPlaceSearchFilter()
            } catch {
                allPlaces = []
                filteredPlaces = []
                refreshPlaceAnnotations()
            }
        }
    }

    private func applyPlaceSearchFilter() {
        let keyword = searchTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        if keyword.isEmpty {
            filteredPlaces = allPlaces
        } else {
            filteredPlaces = allPlaces.filter {
                $0.title.localizedCaseInsensitiveContains(keyword)
                || $0.description.localizedCaseInsensitiveContains(keyword)
            }
        }
        refreshPlaceAnnotations()
    }

    private func refreshPlaceAnnotations() {
        let annotations = filteredPlaces.map { PlaceAnnotation(place: $0, category: selectedCategory) }
        mapView.removeAnnotations(mapView.annotations)
        mapView.addAnnotations(annotations)

        if let first = annotations.first, !(searchTextField.text?.isEmpty ?? true) {
            selectPlace(annotation: first, moveToCenter: true)
        }
    }

    private func selectPlace(annotation: PlaceAnnotation, moveToCenter: Bool) {
        currentAnnotation = annotation
        if moveToCenter {
            let region = MKCoordinateRegion(center: annotation.coordinate, latitudinalMeters: 800, longitudinalMeters: 800)
            mapView.setRegion(region, animated: true)
        }
        mapView.selectAnnotation(annotation, animated: true)
        showBottomSheet(for: annotation)
        loadPosts(for: annotation)
    }

    private func showBottomSheet(for annotation: PlaceAnnotation) {
        placeNameLabel.text = annotation.title ?? "이름 없음"
        placeAddressLabel.text = annotation.subtitle ?? ""
        routeButton.isHidden = false
        dimView.isHidden = false

        UIView.animate(withDuration: 0.24) {
            self.bottomSheetBottomConstraint?.update(offset: 0)
            self.routeButtonBottomConstraint?.update(inset: 340)
            self.dimView.alpha = 1
            self.view.layoutIfNeeded()
        }
    }

    @objc
    private func didTapDimView() {
        hideBottomSheet()
        mapView.selectedAnnotations.forEach { mapView.deselectAnnotation($0, animated: true) }
    }

    private func hideBottomSheet() {
        routeButton.isHidden = true
        UIView.animate(withDuration: 0.24, animations: {
            self.bottomSheetBottomConstraint?.update(offset: 320)
            self.routeButtonBottomConstraint?.update(inset: 28)
            self.dimView.alpha = 0
            self.view.layoutIfNeeded()
        }, completion: { _ in
            self.dimView.isHidden = true
        })
    }

    private func loadPosts(for annotation: PlaceAnnotation) {
        placePostTask?.cancel()
        placePostTask = Task { [weak self] in
            guard let self else { return }

            do {
                let allPlacePosts = try await tipService.listTips(category: "PLACE", page: 1, search: nil)
                let keyword = annotation.title ?? ""
                let filtered = allPlacePosts.filter {
                    $0.title.localizedCaseInsensitiveContains(keyword)
                    || $0.content.localizedCaseInsensitiveContains(keyword)
                    || ($0.place?.localizedCaseInsensitiveContains(keyword) ?? false)
                }

                self.selectedPlacePosts = filtered.isEmpty ? Array(allPlacePosts.prefix(10)) : filtered
                self.emptyPostsLabel.isHidden = !self.selectedPlacePosts.isEmpty
                self.postsCollectionView.reloadData()
            } catch {
                self.selectedPlacePosts = []
                self.emptyPostsLabel.isHidden = false
                self.postsCollectionView.reloadData()
            }
        }
    }

    @objc
    private func didTapRouteButton() {
        guard let annotation = currentAnnotation else { return }
        if let url = URL(string: annotation.place.naverMapURL), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
            return
        }

        let destination = MKMapItem(placemark: MKPlacemark(coordinate: annotation.coordinate))
        destination.name = annotation.title
        destination.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving])
    }
}

extension LocationViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        applyPlaceSearchFilter()
        return true
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        applyPlaceSearchFilter()
    }
}

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
        markerView.markerTintColor = .orange500
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
        cell.configure(with: post)
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
