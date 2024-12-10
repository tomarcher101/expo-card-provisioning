import { EventSubscription } from "expo-modules-core";

import ExpoCardProvisioningModule from "./ExpoCardProvisioningModule";

export function requestPaymentPassConfiguration(): string {
  return ExpoCardProvisioningModule.requestPaymentPassConfiguration();
}

export function logSomething(message: string): void {
  return ExpoCardProvisioningModule.logSomething(message);
}

export function addOnLogSomethingListener(
  listener: (event: { message: string }) => void
): EventSubscription {
  return ExpoCardProvisioningModule.addListener("onLogSomething", listener);
}

export function test(
  cardholderName: string,
  cardPan: string,
  cardNameInWallet: string,
  cardId,
): void {
  return ExpoCardProvisioningModule.test(
    cardholderName,
    cardPan,
    cardNameInWallet,
    cardId,
  );
}
