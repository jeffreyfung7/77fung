(use-trait nft-trait .nft-trait.nft-trait)

(define-map listings
    { id: uint }
    {
        maker: principal,
        nft-contract: principal,
        token-id: uint,
        price: uint
    }
)
(define-data-var listing-nonce uint u0)

(define-constant err-unknown-listing (err u100))
(define-constant err-tx-sender-not-maker (err u101))
(define-constant err-wrong-trait-reference (err u102))

(define-read-only (get-listing (listing-id uint))
    (map-get? listings {id: listing-id})
)

(define-public (list-nft (nft-contract <nft-trait>) (token-id uint) (price uint))
    (let
        (
            (listing-id (var-get listing-nonce))
        )
        (try! (contract-call? nft-contract transfer token-id tx-sender (as-contract tx-sender)))
        (map-set listings 
            {id: listing-id}
            {
                maker: tx-sender,
                nft-contract: (contract-of nft-contract),
                token-id: token-id,
                price: price
            }
        )
        (var-set listing-nonce (+ listing-id u1))
        (ok true)
    )
)

(define-public (cancel-listing (nft-contract <nft-trait>) (listing-id uint))
    (let
        (
            (listing (unwrap! (get-listing listing-id) err-unknown-listing))
            (maker (get maker listing))
            (token-id (get token-id listing))
        )
        (asserts! (is-eq tx-sender maker) err-tx-sender-not-maker)
        (asserts! (is-eq (contract-of nft-contract) (get nft-contract listing)) err-wrong-trait-reference)
        (try! (as-contract (contract-call? nft-contract transfer token-id tx-sender maker)))
        (map-delete listings {id: token-id})
        (ok true)
    )
)

(define-public (fulfill-listing (nft-contract <nft-trait>) (listing-id uint))
    (let
        (
            (listing (unwrap! (get-listing listing-id) err-unknown-listing))
            (maker (get maker listing))
            (token-id (get token-id listing))
            (price (get price listing))
            (taker tx-sender)
        )
        (asserts! (is-eq (contract-of nft-contract) (get nft-contract listing)) err-wrong-trait-reference)
        (try! (stx-transfer? price taker maker))
        (try! (as-contract (contract-call? nft-contract transfer token-id tx-sender taker)))
        (map-delete listings {id: listing-id})
        (ok true)
    )
)