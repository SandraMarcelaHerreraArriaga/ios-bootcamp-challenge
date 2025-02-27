//
//  ListViewController.swift
//  iOS Bootcamp Challenge
//
//  Created by Jorge Benavides on 26/09/21.
//

import UIKit

class ListViewController: UICollectionViewController, UISearchBarDelegate, UISearchResultsUpdating {
    
    private var group = DispatchGroup()
    private var pokemons: [Pokemon] = []
    private var resultPokemons: [Pokemon] = []

    // TODO: Use UserDefaults to pre-load the latest search at start
    private var userDefaults = UserDefaults.standard
    private var latestSearch: String?

    lazy private var searchController: SearchBar = {
        let searchController = SearchBar("Search a pokemon", delegate: nil)
        searchController.searchResultsUpdater = self
        searchController.showsCancelButton = !searchController.isSearchBarEmpty
        searchController.text = userDefaults.string(forKey: "latestSearch")
        return searchController
    }()

    private var isFirstLauch: Bool = true

    private var uiActivityIndicator = UIActivityIndicatorView(style: .medium)
    private var shouldShowLoader: Bool = true

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        uiActivityIndicator.center = view.center
        view.addSubview(uiActivityIndicator)
        checkIfShowDisplayLoaderIndicator()
        
        setup()
        setupUI()
    }

    // MARK: Setup

    private func setup() {
        title = "Pokédex"

        // Customize navigation bar.
        guard let navbar = self.navigationController?.navigationBar else { return }

        navbar.tintColor = .black
        navbar.titleTextAttributes = [.foregroundColor: UIColor.black]
        navbar.prefersLargeTitles = true
        
        // Set up the searchController parameters.
        navigationItem.searchController = searchController
        definesPresentationContext = true

        refresh()

    }
    
    private func checkIfShowDisplayLoaderIndicator(){
        if shouldShowLoader {
            uiActivityIndicator.startAnimating()
        }
        else {
            uiActivityIndicator.stopAnimating()
        }
    }

    private func setupUI() {

        // Set up the collection view.
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.backgroundColor = .white
        collectionView.alwaysBounceVertical = true
        collectionView.indicatorStyle = .white

        // Set up the refresh control as part of the collection view when it's pulled to refresh.
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        refreshControl.beginRefreshing()
        collectionView.refreshControl = refreshControl
        collectionView.sendSubviewToBack(refreshControl)
        
    }

    // MARK: - UISearchViewController

    private func filterContentForSearchText(_ searchText: String) {
        // filter with a simple contains searched text
        resultPokemons = pokemons
            .filter {
                searchText.isEmpty || $0.name.lowercased().contains(searchText.lowercased())
            }
            .sorted {
                $0.id < $1.id
            }

        collectionView.reloadData()
    }

    func updateSearchResults(for searchController: UISearchController) {
       guard  let searchBarText = searchController.searchBar.text else { return }
        filterContentForSearchText(searchBarText)
        userDefaults.setValue(searchBarText, forKey: "latestSearch")

    }

    // MARK: - UICollectionViewDataSource

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return resultPokemons.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PokeCell.identifier, for: indexPath) as? PokeCell
        else { preconditionFailure("Failed to load collection view cell") }
        
        cell.pokemon = resultPokemons[indexPath.item]
        return cell
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goDetailViewControllerSegue" {
            if let detailViewController = segue.destination as? DetailViewController {
                let cell = sender as! PokeCell
                let indexPath = self.collectionView.indexPath(for: cell)
                detailViewController.pokemon = resultPokemons[indexPath!.row]
            }
        }
    }

    // MARK: - UI Hooks

    @objc func refresh() {
        shouldShowLoader = true

        var pokemons: [Pokemon] = []

        self.group.enter()
        PokeAPI.shared.get(url: "pokemon?limit=30", onCompletion: { (list: PokemonList?, _) in
            guard let list = list else { return }
            self.group.leave()
            list.results.forEach { result in
                self.group.enter()
                PokeAPI.shared.get(url: "/pokemon/\(result.id)/", onCompletion: { (pokemon: Pokemon?, _) in
                    guard let pokemon = pokemon else { return }
                    pokemons.append(pokemon)
                    self.pokemons = pokemons
                    self.didRefresh()
                    self.group.leave()
                })
            }
        })
        group.notify(queue: .main) {
            self.pokemons = pokemons
            self.didRefresh()
        }
    }

    private func didRefresh() {
        shouldShowLoader = false
        checkIfShowDisplayLoaderIndicator()
        guard
            let collectionView = collectionView,
            let refreshControl = collectionView.refreshControl
        else { return }

        refreshControl.endRefreshing()

        filterContentForSearchText("")
    }

}
