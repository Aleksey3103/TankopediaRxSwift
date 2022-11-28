//
//  TanksViewModel.swift
//  NetworkTanks
//
//  Created by Aleksey on 27.12.2021.
//

import Foundation
import RxSwift
import RxCocoa

protocol ViewModelProtocol {
    associatedtype Input
    associatedtype Output
    
    func transform(input: Input) -> Output
    
}

class TanksViewModel: ViewModelProtocol {
    
    var data = ModelTanks(data: [:])
    var datum: BehaviorRelay<[Datum]> = .init(value: [])
    var apiClient = RequestManager()
    var reloadInfo: (()->())?
    var showError: (()->())?
    var disposeBag = DisposeBag()
    
    private var cellViewModels: [DataListCellViewModel] = [DataListCellViewModel]()
    private let searchText = BehaviorRelay<String>(value: "")
    
    struct Input {
        var disposeBag: DisposeBag
        var text: ControlProperty<String>
    }
    
    struct Output {
        let tankList: Driver<[Datum]>
    }
    
    func transform(input: Input) -> Output {
        let tankList = datum.asDriver()
        self.getData()
        
        //MARK: -Searching
        input.text
            .throttle(.milliseconds(100), scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .bind(onNext: { query in
                if query.isEmpty {
                    self.closureSetUp()
                } else {
                    let filteredValues = self.datum.value.filter({ tank in
                        return tank.name.lowercased().contains(query.lowercased())
                    })
                    self.datum.accept(filteredValues)
                    self.reloadInfo?()
                }
            }).disposed(by: disposeBag)
        //MARK: Searching-
        
        return Output(tankList: tankList)
    }
    
    private func getData() {
        closureSetUp()
        self.apiClient.getDataTanks()
    }
    
    private func closureSetUp() {
        apiClient
            .tanks
            .subscribe(onNext: { [weak self] data in
                var localDatum: [Datum] = []
                data.data.keys.forEach {
                    guard let value = data.data[$0] else { return }
                    localDatum.append(value)
                }
                self?.datum.accept(localDatum)
                self?.createCell(datas: self?.datum ?? .init(value: []))
            }).disposed(by: disposeBag)
        
        apiClient.tankDataError = { [weak self] _ in
            self?.showError?()
        }
    }
    
    func getCellViewModel( at indexPath: IndexPath ) -> DataListCellViewModel {
        return cellViewModels[indexPath.row]
    }
    
    private func createCell(datas: BehaviorRelay<[Datum]>) {
        var modelCell = [DataListCellViewModel]()
        for value in datas.value {
            guard let imgurl = value.images.imageUrl else {
                return
            }
            modelCell.append(DataListCellViewModel(tankImage: imgurl, tankLabel: value.name, desc: value.description))
        }
        cellViewModels = modelCell
        self.reloadInfo?()
    }
    
    struct DataListCellViewModel {
        let tankImage: URL
        let tankLabel: String
        let desc: String
    }
}
