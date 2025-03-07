//
//  FavoritesViewModel.swift
//  Cypher
//
//  Created by Nkhorbaladze on 17.01.25.
//

import Foundation
import Combine
import FirebaseAuth
import UIKit

final class FavoritesViewModel: ObservableObject {
    private let fetchCoinsUseCase: FetchCoinsUseCaseProtocol
    private let fetchFavoritesUseCase: FetchFavoritesUseCaseProtocol
    
    @Published var favoriteCoins: [FavoriteCoin] = []
    @Published var isLoading: Bool = false
    @Published var error: String?
    var cancellables = Set<AnyCancellable>()
    
    init(fetchCoinsUseCase: FetchCoinsUseCaseProtocol, fetchFavoritesUseCase: FetchFavoritesUseCaseProtocol) {
        self.fetchCoinsUseCase = fetchCoinsUseCase
        self.fetchFavoritesUseCase = fetchFavoritesUseCase
    }
    
    deinit {
        cancellables.forEach { $0.cancel() }
        cancellables.removeAll()
    }
    
    func fetchFavorites() {
        isLoading = true
        error = nil
        
        guard let currentUser = Auth.auth().currentUser else {
            return
        }
        
        let userID = currentUser.uid
        
        Task { [weak self] in
            guard let self = self else { return }
            
            do {
                let favoriteNames = try await fetchFavoritesUseCase.execute(userID: userID)
                
                fetchCoinsUseCase.execute()
                    .receive(on: DispatchQueue.main)
                    .sink(receiveCompletion: { completion in
                        switch completion {
                        case .finished:
                            self.isLoading = false
                        case .failure(let networkError):
                            self.error = networkError.localizedDescription
                            self.isLoading = false
                        }
                    }, receiveValue: { [weak self] marketData in
                        guard let self = self else { return }
                        
                        let favoriteCoins = favoriteNames.compactMap { favoriteName in
                            marketData.first { $0.name.lowercased() == favoriteName.lowercased() }
                                .map { marketCoin in
                                    FavoriteCoin(
                                        id: marketCoin.id,
                                        name: marketCoin.name,
                                        image: marketCoin.image,
                                        imageURL: marketCoin.imageURL,
                                        currentPrice: marketCoin.currentPrice,
                                        changePercentage24h: marketCoin.priceChangePercentage24h ?? 0,
                                        symbol: marketCoin.symbol
                                    )
                                }
                        }
                        
                        self.favoriteCoins = favoriteCoins
                    })
                    .store(in: &self.cancellables)
            } catch {
                await MainActor.run {
                    self.error = error.localizedDescription
                    self.isLoading = false
                }
            }
        }
    }
}


