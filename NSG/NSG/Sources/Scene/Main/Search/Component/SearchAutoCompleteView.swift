//
//  SearchAutoCompleteView.swift
//  NSG
//
//  Created by hawon on 3/30/26.
//
import UIKit
import SnapKit
import Then

final class SearchAutoCompleteView: UIView {

    var onSelectItem: ((String) -> Void)?

    private var results: [String] = []
    private var keyword: String = ""

    private let tableView = UITableView(frame: .zero, style: .plain).then {
        $0.backgroundColor = .clear
        $0.separatorStyle = .none
        $0.rowHeight = 36
        $0.showsVerticalScrollIndicator = true
        $0.isScrollEnabled = true
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .black50
        layer.cornerRadius = 8
        isHidden = true

        addSubview(tableView)
        tableView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(10)
        }

        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(AutoCompleteCell.self, forCellReuseIdentifier: AutoCompleteCell.identifier)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func update(results: [String], keyword: String) {
        self.results = results
        self.keyword = keyword
        tableView.reloadData()
    }
}

extension SearchAutoCompleteView: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        results.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: AutoCompleteCell.identifier,
            for: indexPath
        ) as? AutoCompleteCell else {
            return UITableViewCell()
        }

        cell.configure(text: results[indexPath.row], keyword: keyword)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        onSelectItem?(results[indexPath.row])
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
