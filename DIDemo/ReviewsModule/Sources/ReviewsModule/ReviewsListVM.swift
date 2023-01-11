import Foundation
import AppContainer
import ReviewsServicesInterfaces

/// VM для отображения отзывов
@MainActor public class ReviewsListVM {
	public struct Deps {
		let reviewsService: IReviewsService

		/// Генерируется
		public init(reviewsService: IReviewsService) {
			self.reviewsService = reviewsService
		}
	}

	var viewModelChanged: (() -> Void)?

	private(set) var state: State = .loading {
		didSet {
			viewModelChanged?()
		}
	}

	private let deps: Deps
	private let args: Args

	public init(
		deps: Deps = AppContainer.make(type: Deps.self, init: Deps.init),
		args: Args
	) {
		self.deps = deps
		self.args = args
	}

	func willAppear() async {
		do {
			state = .loading
			let reviews = try await deps.reviewsService.fetchReviews(cardId: args.cardId)
			state = .success(reviews)
		} catch {
			state = .error
		}
	}
}

// MARK: - Args

extension ReviewsListVM {
	public struct Args {
		public let cardId: String
		public init(cardId: String) {
			self.cardId = cardId
		}
	}
}

// MARK: - State

extension ReviewsListVM {
	public enum State: Equatable {
		case loading
		case success([ReviewModel])
		case error
	}
}
