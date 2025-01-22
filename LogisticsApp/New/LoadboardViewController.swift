import UIKit
import SwiftUI

class LoadboardViewController: UIViewController {
    private let tableView = UITableView()
    private let viewModel = LoadboardViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Loadboard"
        
        setupUI()
        bindViewModel()
        viewModel.fetchLoadData()
    }

    private func setupUI() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(LoadboardCell.self, forCellReuseIdentifier: LoadboardCell.identifier)
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
    }

    private func bindViewModel() {
        viewModel.reloadData = { [weak self] in
            self?.tableView.reloadData()
        }
    }
}

extension LoadboardViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.loadItems.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: LoadboardCell.identifier, for: indexPath) as? LoadboardCell else {
            return UITableViewCell()
        }
        let item = viewModel.loadItems[indexPath.row]
        cell.configure(with: item)
        return cell
    }
}

extension LoadboardViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedLoad = viewModel.loadItems[indexPath.row]
        let detailView = DetailLoadView(loadItem: selectedLoad)
        let hostingController = UIHostingController(rootView: detailView)
        hostingController.modalPresentationStyle = .fullScreen
        present(hostingController, animated: true, completion: nil)
    }
}
