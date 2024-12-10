import { NativeModule, requireNativeModule } from "expo";
import { EventSubscription } from "expo-modules-core";

// Extend the ExpoCardProvisioningModule interface
declare class ExpoCardProvisioningModule extends NativeModule {
  logSomething(message: string): void;
  test(
    cardholderName: string,
    cardPan: string,
    cardNameInWallet: string,
    primaryAccountIdentifier: string,
  ): void;

  addListener(
    eventName: "onLogSomething",
    listener: (event: { message: string }) => void
  ): EventSubscription;
}

// Load the native module
export default requireNativeModule<ExpoCardProvisioningModule>(
  "ExpoCardProvisioning"
);
