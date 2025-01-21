//
//  CargoLISTVC.swift
//  LogisticsApp
//
//  Created by beqa on 15.01.25.
//

import UIKit

class CargoListViewController: UIViewController {
    
    private var cargos: [Cargo] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Cargo List"
        view.backgroundColor = .white
        
        // Create UITableView for listing cargos
        let cargoTableView = UITableView(frame: self.view.bounds)
        cargoTableView.dataSource = self
        cargoTableView.delegate = self
        cargoTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cargoCell")
        view.addSubview(cargoTableView)
        
        // Simulate fetching cargos
        cargos = CargoService().getAllCargos()
    }
}

extension CargoListViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cargos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cargoCell", for: indexPath)
        let cargo = cargos[indexPath.row]
        cell.textLabel?.text = cargo.description
        return cell
    }
}
