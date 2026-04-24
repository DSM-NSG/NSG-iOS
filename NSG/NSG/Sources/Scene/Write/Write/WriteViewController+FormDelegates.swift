import UIKit
import MapKit
import SnapKit

extension WriteViewController: UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {

    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField === majorTextField {
            filterMajors(with: majorTextField.text ?? "")
            return
        }

        if textField === placeTextField.textFieldRef {
            searchPlacesForLocationField()
        }
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField === majorTextField {
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                if self.isSelectingMajorSuggestion { return }
                self.majorDropdownTableView.isHidden = true
                self.majorDropdownHeightConstraint?.update(offset: 0)
                self.view.layoutIfNeeded()
            }
            return
        }

        if textField === placeTextField.textFieldRef {
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                if self.isSelectingPlaceSuggestion { return }
                self.placeAutoCompleteContainerView.isHidden = true
                self.placeDropdownHeightConstraint?.update(offset: 0)
                self.view.layoutIfNeeded()
            }
        }
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView === majorDropdownTableView {
            return filteredMajors.count + (majorCreateCandidateName == nil ? 0 : 1)
        }
        if tableView === placeDropdownTableView {
            return placeResults.count
        }
        return 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView === majorDropdownTableView {
            if indexPath.row < filteredMajors.count {
                guard let cell = tableView.dequeueReusableCell(
                    withIdentifier: AutoCompleteCell.identifier,
                    for: indexPath
                ) as? AutoCompleteCell else {
                    return UITableViewCell()
                }
                let keyword = majorTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
                cell.configure(text: filteredMajors[indexPath.row].name, keyword: keyword)
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "MajorCell", for: indexPath)
                var content = cell.defaultContentConfiguration()
                let candidate = majorCreateCandidateName ?? ""
                content.text = "'\(candidate)' 전공 추가하기"
                content.textProperties.font = .style(.body3)
                content.textProperties.color = .orange500
                cell.contentConfiguration = content
                cell.selectionStyle = .none
                return cell
            }
        }

        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: AutoCompleteCell.identifier,
            for: indexPath
        ) as? AutoCompleteCell else {
            return UITableViewCell()
        }

        let place = placeResults[indexPath.row]
        let keyword = placeTextField.text.trimmingCharacters(in: .whitespacesAndNewlines)
        cell.configure(text: place.displayAddress, keyword: keyword)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView === majorDropdownTableView {
            isSelectingMajorSuggestion = false
            if indexPath.row < filteredMajors.count {
                let selected = filteredMajors[indexPath.row]
                selectedMajors.append(.init(id: selected.id, name: selected.name))
                majorTextField.text = ""
                filterMajors(with: "")
            } else if let candidate = majorCreateCandidateName {
                createMajorCategoryIfNeeded(name: candidate)
            }
            return
        }

        if tableView === placeDropdownTableView {
            let selected = placeResults[indexPath.row]
            isApplyingSelectedPlace = true
            isSelectingPlaceSuggestion = false
            selectedPlace = nil
            placeTextField.setText(selected.displayAddress)
            isApplyingSelectedPlace = false
            placeTextField.textFieldRef.resignFirstResponder()
            placeResults = []
            updatePlaceAutoCompleteUI()
            Task { [weak self] in
                guard let self else { return }
                do {
                    let resolved = try await self.resolvePlace(from: selected.completion)
                    self.selectedPlace = resolved
                } catch {
                    self.selectedPlace = nil
                }
            }
        }
    }

    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if tableView === majorDropdownTableView {
            isSelectingMajorSuggestion = true
        }
        if tableView === placeDropdownTableView {
            isSelectingPlaceSuggestion = true
        }
        return indexPath
    }
}

extension WriteViewController: MKLocalSearchCompleterDelegate {
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        guard tipType == .location else { return }
        placeResults = Array(completer.results.prefix(8)).map {
            PlaceAutoCompleteItem(title: $0.title, subtitle: $0.subtitle, completion: $0)
        }
        updatePlaceAutoCompleteUI()
    }

    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: any Error) {
        guard tipType == .location else { return }
        placeResults = []
        updatePlaceAutoCompleteUI()
    }
}

extension WriteViewController: UICollectionViewDataSource, UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return LocationCategory.allCases.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: LocationCategoryCell.identifier, for: indexPath
        ) as! LocationCategoryCell
        let category = LocationCategory.allCases[indexPath.item]
        cell.configure(category: category, isSelected: selectedCategory == category)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        let tapped = LocationCategory.allCases[indexPath.item]
        selectedCategory = selectedCategory == tapped ? nil : tapped
        collectionView.reloadData()
    }
}
