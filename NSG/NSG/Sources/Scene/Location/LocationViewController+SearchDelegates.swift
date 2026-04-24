import UIKit
import MapKit
import SnapKit

extension LocationViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        didChangeSearchTextField()
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        applyPlaceSearchFilter()
        searchAutoCompleteContainerView.isHidden = true
        searchAutoCompleteHeightConstraint?.update(offset: 0)
        return true
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        applyPlaceSearchFilter()
        searchAutoCompleteContainerView.isHidden = true
        searchAutoCompleteHeightConstraint?.update(offset: 0)
    }
}

extension LocationViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        searchAutoCompleteResults.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: AutoCompleteCell.identifier,
            for: indexPath
        ) as? AutoCompleteCell else {
            return UITableViewCell()
        }

        let item = searchAutoCompleteResults[indexPath.row]
        let keyword = searchTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        cell.configure(text: item.displayText, keyword: keyword)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.row < searchAutoCompleteResults.count else { return }
        let selected = searchAutoCompleteResults[indexPath.row]
        searchTextField.text = selected.displayText
        applyPlaceSearchFilter()
        searchAutoCompleteResults = []
        updateSearchAutoCompleteUI()
        searchTextField.resignFirstResponder()
        searchMapItem(with: selected.completion)
    }
}

extension LocationViewController: MKLocalSearchCompleterDelegate {
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        searchAutoCompleteResults = Array(completer.results.prefix(8)).map {
            SearchAutoCompleteItem(title: $0.title, subtitle: $0.subtitle, completion: $0)
        }
        updateSearchAutoCompleteUI()
    }

    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: any Error) {
        searchAutoCompleteResults = []
        updateSearchAutoCompleteUI()
    }
}
