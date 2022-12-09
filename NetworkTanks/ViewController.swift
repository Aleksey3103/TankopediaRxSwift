//
//  ViewController.swift
//  NetworkTanks
//
//  Created by Aleksey on 27.12.2021.
//

import UIKit
import Nuke
import RxCocoa
import RxSwift

class ViewController: UIViewController {
    var apiClient = RequestManager()
    var dataViewModel = TanksViewModel()
    let sspacing: CGFloat = 0.0
    var bottomInset: CGFloat = 0
    var searchActive = false
    var activityIndicator = UIActivityIndicatorView()
    let searchController = UISearchController(searchResultsController: nil)
    
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    let disposeBag = DisposeBag()
    
    var searchBarISEmpty: Bool {
        guard let text = searchController.searchBar.text else {
            return false
        }
        return text.isEmpty
    }
    
    var isFiltering: Bool {
        return searchController.isActive && !searchBarISEmpty
    }
    //
    @IBOutlet weak var collectionView: UICollectionView!
    //    @IBOutlet weak var searchBar: UISearchBar!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.activityIndicator.startAnimating()
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationItem.largeTitleDisplayMode = .automatic
        navigationItem.title = "Tankopedia"
        self.definesPresentationContext = true
        bindCollectionView()
        setupSearch()
        setupActivityIndicator()
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func setupSearch() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search"
        searchController.searchBar.barStyle = .black
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        searchController.searchBar.text = ""
        searchController.becomeFirstResponder()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        navigationController?.navigationBar.barStyle = .black
        collectionView.reloadData()
    }
    
    override func loadView() {
        super.loadView()
        self.initViewModel()
    }
    
    func setupActivityIndicator() {
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.style = .large
        activityIndicator.color = UIColor.white
        view.addSubview(activityIndicator)
    }
    
    func initViewModel() {
        dataViewModel.reloadInfo = {
            
        }
        dataViewModel.showError = {
            DispatchQueue.main.async { self.collectionView.reloadData() }
        }
    }
    
    func bindCollectionView() {
        collectionView.register(UINib(nibName: "TankCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "TankCollectionViewCell")
        
        let input = TanksViewModel.Input(disposeBag: disposeBag, text: searchController.searchBar.rx.text.orEmpty)
        let output = dataViewModel.transform(input: input)
        
        /*
         searchController.searchBar.rx.text.orEmpty
         .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
         .distinctUntilChanged()
         .map({ query in
         self.dataViewModel.datum.value.filter({ tank in
         query.isEmpty || tank.name.lowercased().contains(query.lowercased())
         })
         })
         */
        
        output
            .tankList
            .asObservable()
            .bind(to: collectionView.rx.items(cellIdentifier: "TankCollectionViewCell", cellType: TankCollectionViewCell.self)) { row, model, cell in
                self.activityIndicator.stopAnimating()
                cell.configure(model: model)
                cell.layer.cornerRadius = 8
                cell.layer.masksToBounds = true
            }.disposed(by: disposeBag)
        
        collectionView
            .rx
            .itemSelected
            .subscribe(onNext: { indexPath in
                if let vc = self.storyboard?.instantiateViewController(withIdentifier: "DetailedViewController") as? DetailedViewController {
                    let cellVC = self.dataViewModel.getCellViewModel(at: indexPath)
                    vc.imageTank.bigIcon = ("\(cellVC.tankImage)")
                    vc.detailTank.description = cellVC.desc
                    vc.detailTank.name = cellVC.tankLabel
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }).disposed(by: disposeBag)
        
        collectionView.rx.setDelegate(self)
            .disposed(by: disposeBag)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {
            return
        }
        
        var keyboardHeight: CGFloat
        let bottom = self.view.safeAreaInsets.bottom - 20
        keyboardHeight = keyboardFrame.cgRectValue.height - bottom
        bottomConstraint.constant = keyboardHeight
        self.view.layoutIfNeeded()
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        self.bottomConstraint.constant = self.bottomInset
        self.view.layoutIfNeeded()
    }
}

extension ViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 20, left: 15, bottom: 20, right: 15)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let numberOfItemsPerRow:CGFloat = 3
        let spacingBetweenCells:CGFloat = 70
        let totalSpacing = (2 * self.sspacing) + ((numberOfItemsPerRow - 1) * spacingBetweenCells) //Amount of total spacing in a row
        if let collection = self.collectionView {
            let width = (collection.bounds.width + totalSpacing)/numberOfItemsPerRow
            return CGSize(width: width, height: width)
        } else {
            return CGSize(width: 130, height: 140)
        }
    }
}

extension ViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {}
}
