import ExpoModulesCore
import PassKit

public class ExpoCardProvisioningModule: Module {
  private var paymentPassDelegate: PaymentPassDelegate?

  public func definition() -> ModuleDefinition {
    Name("ExpoCardProvisioning")

    Events("onLogSomething")

    Function("logSomething") { (message: String) -> Void in
      self.print(message)
    }

    Function("test") {
      (
        cardholderName: String, cardPan: String, cardNameInWallet: String,
        primaryAccountIdentifier: String
      ) -> Void in
      self.print("test.start")

      guard let config = PKAddPaymentPassRequestConfiguration(encryptionScheme: .ECC_V2) else {
        return
      }

      config.cardholderName = cardholderName
      config.primaryAccountSuffix = cardPan
      config.localizedDescription = cardNameInWallet
      config.primaryAccountIdentifier = primaryAccountIdentifier

      // Print the configuration details
      self.print("PKAddPaymentPassRequestConfiguration:")
      self.print("  Cardholder Name: \(config.cardholderName ?? "nil")")
      self.print("  Primary Account Suffix: \(config.primaryAccountSuffix ?? "nil")")
      self.print("  Localized Description: \(config.localizedDescription ?? "nil")")
      self.print("  Primary Account Identifier: \(config.primaryAccountIdentifier ?? "nil")")
      self.print("  Encryption Scheme: \(config.encryptionScheme)")

      let lol = PKAddPaymentPassViewController.canAddPaymentPass()

      self.print("canAddPaymentPass: \(lol)")

      guard
        let viewController = PKAddPaymentPassViewController(
          requestConfiguration: config, delegate: self.createPaymentPassDelegate())
      else { return }

      self.print("viewController created: \(viewController)")

      // Present the view controller
      DispatchQueue.main.async {
        guard
          let rootViewController = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .flatMap({ $0.windows })
            .first(where: { $0.isKeyWindow })?.rootViewController
        else {
          self.print("Failed to find the root view controller")
          return
        }

        self.print("Presenting viewController")
        rootViewController.present(viewController, animated: true, completion: nil)
      }

    }

  }

  private func print(_ message: String) {
    sendEvent("onLogSomething", ["message": message])
  }

  private func createPaymentPassDelegate() -> PaymentPassDelegate {
    let delegate = PaymentPassDelegate()

    // Handle generate request callback
    delegate.onGenerateRequest = { [weak self] certificates, nonce, nonceSignature, handler in
      self?.print("generateRequestWithCertificateChain called")
      let request = PKAddPaymentPassRequest()  // Add actual provisioning logic here
      handler(request)
    }

    // Handle didFinishAdding callback
    delegate.onDidFinishAdding = { [weak self] pass, error in
      if let error = error {
        self?.print("Error adding payment pass: \(error.localizedDescription)")
      } else {
        self?.print("Payment pass added successfully")
      }
    }

    self.paymentPassDelegate = delegate
    return delegate
  }
}

class PaymentPassDelegate: NSObject, PKAddPaymentPassViewControllerDelegate {
  var onGenerateRequest:
    (([Data], Data, Data, @escaping (PKAddPaymentPassRequest) -> Void) -> Void)?
  var onDidFinishAdding: ((PKPaymentPass?, Error?) -> Void)?

  func addPaymentPassViewController(
    _ controller: PKAddPaymentPassViewController,
    generateRequestWithCertificateChain certificates: [Data],
    nonce: Data,
    nonceSignature: Data,
    completionHandler handler: @escaping (PKAddPaymentPassRequest) -> Void
  ) {
    onGenerateRequest?(certificates, nonce, nonceSignature, handler)
  }

  func addPaymentPassViewController(
    _ controller: PKAddPaymentPassViewController,
    didFinishAdding pass: PKPaymentPass?,
    error: Error?
  ) {
    onDidFinishAdding?(pass, error)
  }
}
