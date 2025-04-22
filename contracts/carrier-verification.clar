;; Carrier Verification Contract
;; This contract validates legitimate transportation companies

(define-data-var admin principal tx-sender)

;; Data map to store verified carriers
(define-map verified-carriers principal
  {
    company-name: (string-utf8 100),
    registration-number: (string-utf8 50),
    verified: bool,
    verification-date: uint
  }
)

;; Public function to register a carrier (can only be called by the admin)
(define-public (register-carrier
    (carrier principal)
    (company-name (string-utf8 100))
    (registration-number (string-utf8 50)))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u1)) ;; Only admin can register
    (asserts! (is-none (map-get? verified-carriers carrier)) (err u2)) ;; Carrier not already registered

    (map-set verified-carriers carrier
      {
        company-name: company-name,
        registration-number: registration-number,
        verified: true,
        verification-date: block-height
      }
    )
    (ok true)
  )
)

;; Public function to revoke carrier verification
(define-public (revoke-carrier (carrier principal))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u1)) ;; Only admin can revoke
    (asserts! (is-some (map-get? verified-carriers carrier)) (err u3)) ;; Carrier must exist

    (map-delete verified-carriers carrier)
    (ok true)
  )
)

;; Read-only function to check if a carrier is verified
(define-read-only (is-verified-carrier (carrier principal))
  (match (map-get? verified-carriers carrier)
    carrier-data (ok (get verified carrier-data))
    (err u3) ;; Carrier not found
  )
)

;; Read-only function to get carrier details
(define-read-only (get-carrier-details (carrier principal))
  (map-get? verified-carriers carrier)
)

;; Function to transfer admin rights
(define-public (transfer-admin (new-admin principal))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u1))
    (var-set admin new-admin)
    (ok true)
  )
)
