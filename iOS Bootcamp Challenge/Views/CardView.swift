//
//  CardView.swift
//  iOS Bootcamp Challenge
//
//  Created by Marlon David Ruiz Arroyave on 28/09/21.
//

import UIKit

class CardView: UIView {

    private let margin: CGFloat = 30
    var card: Card?

    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 27)
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var tableView: UITableView = {
            let tableView = UITableView()
            tableView.translatesAutoresizingMaskIntoConstraints = false
            return tableView
        }()

    required init(card: Card) {
        self.card = card
        super.init(frame: .zero)
        setup()
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
        setupUI()
    }

    private func setup() {
        guard let card = card else { return }

        card.items.forEach { _ in }

        titleLabel.text = card.title
        titleLabel.font = UIFont.boldSystemFont(ofSize: 20)
        backgroundColor = .white
        layer.cornerRadius = 20
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }

    private func setupUI() {
        addSubview(titleLabel)
        titleLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: margin ).isActive = true
        titleLabel.leftAnchor.constraint(equalTo: self.leftAnchor, constant: margin).isActive = true
        titleLabel.widthAnchor.constraint(lessThanOrEqualTo: self.widthAnchor, multiplier: 0.70).isActive = true

        // TODO: Display pokemon info (eg. types, abilities)
        addSubview(tableView)
        tableView.topAnchor.constraint(equalTo: self.topAnchor, constant: margin * 2).isActive = true
        tableView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 5).isActive = true
        tableView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -margin).isActive = true
        tableView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 5).isActive = true
    }
}

extension CardView: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let items = card?.items.count else { return 0 }
        return items
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: "cell")
        
        let item = card?.items[indexPath.row]
        if item?.title != "Abilities" {
            cell.textLabel?.text = item?.title
            cell.detailTextLabel?.text = item?.description
            cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 18)
            cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 18)
        }
        return cell
    }
    
}
