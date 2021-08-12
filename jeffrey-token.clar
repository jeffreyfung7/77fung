(impl-trait .nft-trait.nft-trait)

(define-constant contract-owner tx-sender)

(define-non-fungible-token jeffrey-token uint)

(define-data-var last-token-id uint u0)

(define-public (mint)
	(let
        (
            (token-id (+ (var-get last-token-id) u1))
        )      
        (asserts! (is-eq contract-owner tx-sender) (err u100))
        (var-set last-token-id token-id)
        (nft-mint? jeffrey-token token-id tx-sender)
    )
)		

(define-public (get-last-token-id)
	(ok (var-get last-token-id))
)

(define-read-only (get-token-uri (token-id uint))
	(ok none)
)

(define-read-only (get-owner (token-id uint))
	(ok (nft-get-owner? jeffrey-token token-id))
)

(define-public (transfer (token-id uint) (sender principal) (recipient principal))
	(begin     
        (asserts! (is-eq tx-sender sender) (err u101))    
        (nft-transfer? jeffrey-token token-id sender recipient)
    )
)
