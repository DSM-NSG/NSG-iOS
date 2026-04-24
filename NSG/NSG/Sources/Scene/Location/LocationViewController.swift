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

    enum PlaceCategory: String, CaseIterable {
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

        init?(apiValue: String) {
            switch apiValue.uppercased() {
            case "CAFE":
                self = .cafe
            case "PC_ROOM":
                self = .pcRoom
            case "KARAOKE":
                self = .karaoke
            case "RESTAURANT":
                self = .restaurant
            case "ETC":
                self = .etc
            default:
                return nil
            }
        }

        var activeColor: UIColor {
            switch self {
            case .cafe:
                return UIColor(named: "cafe") ?? UIColor.cafe
            case .pcRoom:
                return UIColor(named: "pc") ?? UIColor.pc
            case .karaoke:
                return UIColor(named: "sing") ?? UIColor.sing
            case .restaurant:
                return UIColor(named: "eat") ?? .orange400
            case .etc:
                return UIColor(named: "etc") ?? UIColor.black500
            }
        }

        var inactiveColor: UIColor {
            switch self {
            case .cafe:
                return UIColor(named: "cafeNon") ?? UIColor.cafeNon
            case .pcRoom:
                return UIColor(named: "pcNon") ?? UIColor.pcNon
            case .karaoke:
                return UIColor(named: "singNon") ?? UIColor.singNon
            case .restaurant:
                return UIColor(named: "eatNon") ?? .eatNon
            case .etc:
                return UIColor(named: "etcNon") ?? UIColor.etcNon
            }
        }
    }

    final class PlaceAnnotation: MKPointAnnotation {
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

    struct SearchAutoCompleteItem {
        let title: String
        let subtitle: String
        let completion: MKLocalSearchCompletion

        var displayText: String {
            subtitle.isEmpty ? title : "\(title) \(subtitle)"
        }
    }


    let tipService: TipServicing
    let locationManager = CLLocationManager()
    var selectedCategory: PlaceCategory?
    var hasCenteredOnUserLocation = false
    var isAwaitingInitialLocation = false
    var initialLocationDeadline: Date?
    var isManualLocationRequest = false
    var currentAnnotation: PlaceAnnotation?
    var searchPreviewAnnotation: MKPointAnnotation?
    var allPlaces: [PlaceListResponseItem] = []
    var filteredPlaces: [PlaceListResponseItem] = []
    var selectedPlacePosts: [SharePost] = []
    let searchCompleter = MKLocalSearchCompleter()
    var searchAutoCompleteResults: [SearchAutoCompleteItem] = []
    var placeListTask: Task<Void, Never>?
    var placePostTask: Task<Void, Never>?
    var placeAddressTask: Task<Void, Never>?
    var placeAddressCache: [String: String] = [:]

    var bottomSheetHeightConstraint: Constraint?
    var bottomSheetBottomConstraint: Constraint?
    var routeButtonBottomConstraint: Constraint?
    var searchAutoCompleteHeightConstraint: Constraint?

    let mapView = MKMapView().then {
        $0.showsCompass = false
        $0.showsScale = false
        $0.showsUserLocation = true
        $0.pointOfInterestFilter = .includingAll
    }

    let dimView = UIView().then {
        $0.backgroundColor = UIColor.black.withAlphaComponent(0.15)
        $0.alpha = 0
        $0.isHidden = true
    }

    let searchContainerView = UIView().then {
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 10
    }

    let searchTextField = UITextField().then {
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

    let searchAutoCompleteContainerView = UIView().then {
        $0.backgroundColor = .black50
        $0.layer.cornerRadius = 8
        $0.isHidden = true
    }

    let searchAutoCompleteTableView = UITableView(frame: .zero, style: .plain).then {
        $0.backgroundColor = .clear
        $0.separatorStyle = .none
        $0.rowHeight = 36
        $0.showsVerticalScrollIndicator = true
        $0.isScrollEnabled = true
    }

    let categoryStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 8
        $0.alignment = .fill
        $0.distribution = .fillProportionally
    }

    lazy var categoryButtons: [UIButton] = PlaceCategory.allCases.map { category in
        UIButton(type: .system).then {
            $0.tag = PlaceCategory.allCases.firstIndex(of: category) ?? 0
            $0.layer.cornerRadius = 4
            $0.setTitle(category.rawValue, for: .normal)
            $0.titleLabel?.font = .style(.body3)
            $0.addTarget(self, action: #selector(didTapCategoryButton(_:)), for: .touchUpInside)
        }
    }

    let writeButton = UIButton(type: .system).then {
        $0.setImage(UIImage(named: "write"), for: .normal)
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 10
        $0.layer.shadowColor = UIColor.black.cgColor
        $0.layer.shadowOpacity = 0.12
        $0.layer.shadowRadius = 6
        $0.layer.shadowOffset = CGSize(width: 0, height: 2)
    }

    let myLocationButton = UIButton(type: .system).then {
        $0.setImage(UIImage(systemName: "location.fill"), for: .normal)
        $0.tintColor = .orange500
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 10
        $0.layer.shadowColor = UIColor.black.cgColor
        $0.layer.shadowOpacity = 0.12
        $0.layer.shadowRadius = 6
        $0.layer.shadowOffset = CGSize(width: 0, height: 2)
    }

    let routeButton = UIButton(type: .system).then {
        $0.setTitle("길찾기", for: .normal)
        $0.setTitleColor(.white, for: .normal)
        $0.titleLabel?.font = .style(.header4)
        $0.backgroundColor = .orange500
        $0.layer.cornerRadius = 16
        $0.isHidden = true
    }

    let bottomSheetView = UIView().then {
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 20
        $0.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        $0.clipsToBounds = true
    }

    let sheetHandle = UIView().then {
        $0.backgroundColor = .black200
        $0.layer.cornerRadius = 2
    }

    let placeNameLabel = UILabel().then {
        $0.font = .style(.header2)
        $0.textColor = .black800
        $0.numberOfLines = 1
    }

    let placeAddressLabel = UILabel().then {
        $0.font = .style(.body3)
        $0.textColor = .black500
        $0.numberOfLines = 2
    }

    let postTitleLabel = UILabel().then {
        $0.text = "위 장소가 포함된 글"
        $0.font = .style(.header3)
        $0.textColor = .black800
    }

    let emptyPostsLabel = UILabel().then {
        $0.text = "해당 장소 관련 게시글이 아직 없어요."
        $0.font = .style(.body3)
        $0.textColor = .black500
        $0.textAlignment = .center
        $0.isHidden = true
    }

    let postsCollectionView = UICollectionView(
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

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // 자동완성은 카테고리/맵 마커 위로 항상 오버레이되도록 최상단 유지
        view.bringSubviewToFront(searchAutoCompleteContainerView)
    }

    func setupUI() {
        view.backgroundColor = .background
        mapView.delegate = self
        searchTextField.delegate = self
        postsCollectionView.delegate = self
        postsCollectionView.dataSource = self
        postsCollectionView.register(LatestPostCell.self, forCellWithReuseIdentifier: LatestPostCell.identifier)
        searchAutoCompleteTableView.dataSource = self
        searchAutoCompleteTableView.delegate = self
        searchAutoCompleteTableView.register(AutoCompleteCell.self, forCellReuseIdentifier: AutoCompleteCell.identifier)
        searchCompleter.delegate = self
        searchCompleter.resultTypes = [.address, .pointOfInterest, .query]
        searchTextField.addTarget(self, action: #selector(didChangeSearchTextField), for: .editingChanged)
        searchAutoCompleteContainerView.layer.zPosition = 999

        view.addSubview(mapView)
        view.addSubview(dimView)
        view.addSubview(searchContainerView)
        view.addSubview(searchAutoCompleteContainerView)
        view.addSubview(categoryStackView)
        view.addSubview(writeButton)
        view.addSubview(myLocationButton)
        view.addSubview(routeButton)
        view.addSubview(bottomSheetView)

        searchContainerView.addSubview(searchTextField)
        searchAutoCompleteContainerView.addSubview(searchAutoCompleteTableView)
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

    func setupLayout() {
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

        searchAutoCompleteContainerView.snp.makeConstraints {
            $0.top.equalTo(searchContainerView.snp.bottom).offset(8)
            $0.leading.trailing.equalTo(searchContainerView)
            searchAutoCompleteHeightConstraint = $0.height.equalTo(0).constraint
        }

        searchAutoCompleteTableView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(10)
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

        myLocationButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(20)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(28)
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

    func bindActions() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapDimView))
        dimView.addGestureRecognizer(tapGesture)
        routeButton.addTarget(self, action: #selector(didTapRouteButton), for: .touchUpInside)
        myLocationButton.addTarget(self, action: #selector(didTapMyLocationButton), for: .touchUpInside)
    }

    func configureInitialMapRegion() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        applyFallbackMapRegionIfNeeded()

        switch locationManager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            requestInitialLocation()
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .denied, .restricted:
            applyFallbackMapRegionIfNeeded()
        @unknown default:
            applyFallbackMapRegionIfNeeded()
        }
    }

    func requestInitialLocation() {
        guard !hasCenteredOnUserLocation else { return }
        isAwaitingInitialLocation = true
        initialLocationDeadline = Date().addingTimeInterval(10)
        locationManager.startUpdatingLocation()
    }

    func completeInitialLocationRequest() {
        isAwaitingInitialLocation = false
        initialLocationDeadline = nil
        locationManager.stopUpdatingLocation()
    }

    func isCoordinateInKorea(_ coordinate: CLLocationCoordinate2D) -> Bool {
        (33.0...39.8).contains(coordinate.latitude) && (124.0...132.5).contains(coordinate.longitude)
    }

    func centerMapOnLocation(_ location: CLLocation, animated: Bool) {
        let region = MKCoordinateRegion(
            center: location.coordinate,
            latitudinalMeters: 1500,
            longitudinalMeters: 1500
        )
        mapView.setRegion(region, animated: animated)
        hasCenteredOnUserLocation = true
    }

    func applyFallbackMapRegionIfNeeded() {
        guard !hasCenteredOnUserLocation else { return }
        let center = CLLocationCoordinate2D(latitude: 36.3918, longitude: 127.3632)
        let region = MKCoordinateRegion(center: center, latitudinalMeters: 3000, longitudinalMeters: 3000)
        mapView.setRegion(region, animated: false)
    }

    @objc
    func didTapCategoryButton(_ sender: UIButton) {
        guard sender.tag < PlaceCategory.allCases.count else { return }
        let tappedCategory = PlaceCategory.allCases[sender.tag]
        selectedCategory = selectedCategory == tappedCategory ? nil : tappedCategory
        updateCategoryButtonStyles()
        fetchPlaces()
    }

    func updateCategoryButtonStyles() {
        for (index, button) in categoryButtons.enumerated() {
            let category = PlaceCategory.allCases[index]
            let isSelected = category == selectedCategory
            button.backgroundColor = isSelected ? category.activeColor : category.inactiveColor
            button.layer.borderWidth = 0
            button.setTitleColor(.white, for: .normal)
        }
    }

    func fetchPlaces() {
        placeListTask?.cancel()
        placeListTask = Task { [weak self] in
            guard let self else { return }

            do {
                let places = try await tipService.listPlaces(category: selectedCategory?.apiValue)
                allPlaces = places
                applyPlaceSearchFilter()
            } catch {
                allPlaces = []
                filteredPlaces = []
                refreshPlaceAnnotations()
            }
        }
    }

    func applyPlaceSearchFilter() {
        let keyword = searchTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        if keyword.isEmpty {
            filteredPlaces = allPlaces
            if let preview = searchPreviewAnnotation {
                mapView.removeAnnotation(preview)
                searchPreviewAnnotation = nil
            }
        } else {
            filteredPlaces = allPlaces.filter {
                $0.title.localizedCaseInsensitiveContains(keyword)
                || $0.description.localizedCaseInsensitiveContains(keyword)
            }
        }
        refreshPlaceAnnotations()
    }

    func refreshPlaceAnnotations() {
        let annotations = filteredPlaces.map {
            PlaceAnnotation(place: $0, category: PlaceCategory(apiValue: $0.category) ?? .etc)
        }
        let existingPlaceAnnotations = mapView.annotations.compactMap { $0 as? PlaceAnnotation }
        mapView.removeAnnotations(existingPlaceAnnotations)
        mapView.addAnnotations(annotations)

        if let first = annotations.first, !(searchTextField.text?.isEmpty ?? true) {
            selectPlace(annotation: first, moveToCenter: true)
        }
    }

    func selectPlace(annotation: PlaceAnnotation, moveToCenter: Bool) {
        currentAnnotation = annotation
        if moveToCenter {
            let region = MKCoordinateRegion(center: annotation.coordinate, latitudinalMeters: 800, longitudinalMeters: 800)
            mapView.setRegion(region, animated: true)
        }
        mapView.selectAnnotation(annotation, animated: true)
        showBottomSheet(for: annotation)
        loadPosts(for: annotation)
    }

    func showBottomSheet(for annotation: PlaceAnnotation) {
        placeNameLabel.text = annotation.title ?? "이름 없음"
        placeAddressLabel.text = placeAddressCache[annotation.place.id] ?? "주소 불러오는 중..."
        resolvePlaceAddress(for: annotation)
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
    func didTapDimView() {
        hideBottomSheet()
        mapView.selectedAnnotations.forEach { mapView.deselectAnnotation($0, animated: true) }
    }

    @objc
    func didChangeSearchTextField() {
        let keyword = searchTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        applyPlaceSearchFilter()

        guard !keyword.isEmpty else {
            searchAutoCompleteResults = []
            updateSearchAutoCompleteUI()
            return
        }

        searchCompleter.region = mapView.region
        searchCompleter.queryFragment = keyword
    }

    func updateSearchAutoCompleteUI() {
        searchAutoCompleteTableView.reloadData()
        let shouldShow = searchTextField.isFirstResponder
            && !(searchTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true)
            && !searchAutoCompleteResults.isEmpty
        searchAutoCompleteContainerView.isHidden = !shouldShow
        if shouldShow {
            view.bringSubviewToFront(searchAutoCompleteContainerView)
        }
        searchAutoCompleteHeightConstraint?.update(offset: shouldShow ? min(CGFloat(searchAutoCompleteResults.count) * 36 + 20, 150) : 0)
        view.layoutIfNeeded()
    }

    func searchMapItem(with completion: MKLocalSearchCompletion) {
        Task { [weak self] in
            guard let self else { return }

            let request = MKLocalSearch.Request(completion: completion)
            request.resultTypes = [.address, .pointOfInterest]

            do {
                let response = try await MKLocalSearch(request: request).start()
                guard let first = response.mapItems.first else { return }

                if let matched = filteredPlaces.first(where: {
                    $0.title.localizedCaseInsensitiveContains(completion.title)
                    || completion.title.localizedCaseInsensitiveContains($0.title)
                }) {
                    let matchedAnnotation = mapView.annotations.compactMap { $0 as? PlaceAnnotation }.first {
                        $0.place.title == matched.title
                        && abs($0.place.latitude - matched.latitude) < 0.0001
                        && abs($0.place.longitude - matched.longitude) < 0.0001
                    }
                    if let matchedAnnotation {
                        selectPlace(annotation: matchedAnnotation, moveToCenter: true)
                    }
                    return
                }

                if let preview = searchPreviewAnnotation {
                    mapView.removeAnnotation(preview)
                }

                let preview = MKPointAnnotation()
                preview.title = first.name ?? completion.title
                preview.subtitle = first.placemark.title ?? completion.subtitle
                preview.coordinate = first.placemark.coordinate
                mapView.addAnnotation(preview)
                searchPreviewAnnotation = preview
                let region = MKCoordinateRegion(center: preview.coordinate, latitudinalMeters: 900, longitudinalMeters: 900)
                mapView.setRegion(region, animated: true)
                hideBottomSheet()
            } catch {
                // 검색 실패 시에는 기존 필터 결과만 유지
            }
        }
    }

    func hideBottomSheet() {
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

    func loadPosts(for annotation: PlaceAnnotation) {
        placePostTask?.cancel()
        placePostTask = Task { [weak self] in
            guard let self else { return }

            do {
                let posts = try await tipService.listPlacePosts(placeID: annotation.place.id, page: 1)
                self.selectedPlacePosts = posts
                self.emptyPostsLabel.isHidden = !self.selectedPlacePosts.isEmpty
                self.postsCollectionView.reloadData()
            } catch {
                self.selectedPlacePosts = []
                self.emptyPostsLabel.isHidden = false
                self.postsCollectionView.reloadData()
            }
        }
    }

    func resolvePlaceAddress(for annotation: PlaceAnnotation) {
        if let cached = placeAddressCache[annotation.place.id], !cached.isEmpty {
            placeAddressLabel.text = cached
            return
        }

        placeAddressTask?.cancel()
        let coordinate = annotation.coordinate
        let placeID = annotation.place.id

        placeAddressTask = Task { [weak self] in
            guard let self else { return }
            do {
                let geocoder = CLGeocoder()
                let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
                let placemarks = try await geocoder.reverseGeocodeLocation(location)
                guard let placemark = placemarks.first else { return }

                let components = [
                    placemark.country,
                    placemark.administrativeArea,
                    placemark.locality,
                    placemark.subLocality,
                    placemark.thoroughfare,
                    placemark.subThoroughfare
                ]
                    .compactMap { $0?.trimmingCharacters(in: .whitespacesAndNewlines) }
                    .filter { !$0.isEmpty }

                let formatted = components.isEmpty
                    ? (placemark.name ?? annotation.place.description)
                    : components.joined(separator: " ")

                await MainActor.run {
                    self.placeAddressCache[placeID] = formatted
                    if self.currentAnnotation?.place.id == placeID {
                        self.placeAddressLabel.text = formatted
                        self.postsCollectionView.reloadData()
                    }
                }
            } catch {
                await MainActor.run {
                    let fallback = annotation.place.description
                    self.placeAddressCache[placeID] = fallback
                    if self.currentAnnotation?.place.id == placeID {
                        self.placeAddressLabel.text = fallback
                        self.postsCollectionView.reloadData()
                    }
                }
            }
        }
    }

    @objc
    func didTapRouteButton() {
        guard let annotation = currentAnnotation else { return }
        if let url = URL(string: annotation.place.naverMapURL), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
            return
        }

        let destination = MKMapItem(placemark: MKPlacemark(coordinate: annotation.coordinate))
        destination.name = annotation.title
        destination.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving])
    }

    @objc
    func didTapMyLocationButton() {
        switch locationManager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            mapView.setUserTrackingMode(.follow, animated: true)
            if let current = mapView.userLocation.location {
                centerMapOnLocation(current, animated: true)
                return
            }
            isManualLocationRequest = true
            locationManager.requestLocation()
        case .notDetermined:
            isManualLocationRequest = true
            locationManager.requestWhenInUseAuthorization()
        case .denied, .restricted:
            let alert = UIAlertController(
                title: "위치 권한 필요",
                message: "내 위치로 이동하려면 위치 권한을 허용해주세요.",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "확인", style: .default))
            present(alert, animated: true)
        @unknown default:
            break
        }
    }
}
