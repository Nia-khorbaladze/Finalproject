//
//  CoinViewModel.swift
//  Cypher
//
//  Created by Nkhorbaladze on 18.01.25.
//

import Foundation
import SwiftUI
import Combine

final class CoinViewModel: ObservableObject {
    private let fetchCoinsUseCase: FetchCoinsUseCase
    private var cancellables: Set<AnyCancellable> = []

    @Published var coins: [CoinResponse] = []
    @Published var isLoading: Bool = false
    @Published var error: String?

    init(fetchCoinsUseCase: FetchCoinsUseCase) {
        self.fetchCoinsUseCase = fetchCoinsUseCase
    }

    func fetchCoins() {
        isLoading = true
        error = nil

        fetchCoinsUseCase.execute()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .finished:
                    self?.isLoading = false
                case .failure(let networkError):
                    self?.isLoading = false
                    self?.error = networkError.localizedDescription
                }
            }, receiveValue: { [weak self] coins in
                self?.coins = coins
            })
            .store(in: &cancellables)
    }
}
