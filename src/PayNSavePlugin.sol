// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.19;

import {BasePlugin} from "modular-account-libs/plugins/BasePlugin.sol";
import {IPluginExecutor} from "modular-account-libs/interfaces/IPluginExecutor.sol";
import {ManifestFunction, ManifestAssociatedFunctionType, ManifestAssociatedFunction, PluginManifest, PluginMetadata, IPlugin} from "modular-account-libs/interfaces/IPlugin.sol";

/// @title Pay n Save Plugin
/// @author Marvin Arnold
/// @notice This plugin lets you save a little bit into a secondary account everytime you make a payment.
contract PayNSavePlugin is BasePlugin {
    // metadata used by the pluginMetadata() method down below
    string public constant NAME = "Locker Pay n Save Plugin";
    string public constant VERSION = "0.0.1";
    string public constant AUTHOR = "Marvin Arnold";

    struct PayNSaveOptions {
        address savingsAccount;
        uint256 roundToNearest; // <- for a USD stable 1,000,000 would be 1 USD (6 decimals)
        bool enabled;
    }

    // this is a constant used in the manifest, to reference our only dependency: the single owner plugin
    // since it is the first, and only, plugin the index 0 will reference the single owner plugin
    // we can use this to tell the modular account that we should use the single owner plugin to validate our user op
    // in other words, we'll say "make sure the person calling increment is an owner of the account using our single plugin"
    uint256
        internal constant _MANIFEST_DEPENDENCY_INDEX_OWNER_USER_OP_VALIDATION =
        0;

    /*
     * Note to Developer:
     * If you're using storage during validation, you need to use "associated storage".
     * ERC 7562 defines the associated storage rules for ERC 4337 accounts.
     * See: https://eips.ethereum.org/EIPS/eip-7562#validation-rules
     *
     * Every owner address can have multiple automated savings setup.
     */
    mapping(address => mapping(uint256 => PayNSaveOptions))
        public subscriptions;

    // ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
    // ┃    Plugin interface functions    ┃
    // ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛

    /// @inheritdoc BasePlugin
    function onInstall(bytes calldata) external pure override {}

    /// @inheritdoc BasePlugin
    function onUninstall(bytes calldata) external pure override {}

    /// @inheritdoc BasePlugin
    function pluginManifest()
        external
        pure
        override
        returns (PluginManifest memory)
    {
        PluginManifest memory manifest;

        // // since we are using the modular account, we will specify one depedency
        // // which will handle the user op validation for ownership
        // // you can find this depedency specified in the installPlugin call in the tests
        // manifest.dependencyInterfaceIds = new bytes4[](1);
        // manifest.dependencyInterfaceIds[0] = type(IPlugin).interfaceId;

        // // we only have one execution function that can be called, which is the increment function
        // // here we define that increment function on the manifest as something that can be called during execution
        // manifest.executionFunctions = new bytes4[](1);
        // manifest.executionFunctions[0] = this.increment.selector;

        // // you can think of ManifestFunction as a reference to a function somewhere,
        // // we want to say "use this function" for some purpose - in this case,
        // // we'll be using the user op validation function from the single owner dependency
        // // and this is specified by the depdendency index
        // ManifestFunction
        //     memory ownerUserOpValidationFunction = ManifestFunction({
        //         functionType: ManifestAssociatedFunctionType.DEPENDENCY,
        //         functionId: 0, // unused since it's a dependency
        //         dependencyIndex: _MANIFEST_DEPENDENCY_INDEX_OWNER_USER_OP_VALIDATION
        //     });

        // // here we will link together the increment function with the single owner user op validation
        // // this basically says "use this user op validation function and make sure everythings okay before calling increment"
        // // this will ensure that only an owner of the account can call increment
        // manifest.userOpValidationFunctions = new ManifestAssociatedFunction[](
        //     1
        // );
        // manifest.userOpValidationFunctions[0] = ManifestAssociatedFunction({
        //     executionSelector: this.increment.selector,
        //     associatedFunction: ownerUserOpValidationFunction
        // });

        // // finally here we will always deny runtime calls to the increment function as we will only call it through user ops
        // // this avoids a potential issue where a future plugin may define
        // // a runtime validation function for it and unauthorized calls may occur due to that
        // manifest.preRuntimeValidationHooks = new ManifestAssociatedFunction[](
        //     1
        // );
        // manifest.preRuntimeValidationHooks[0] = ManifestAssociatedFunction({
        //     executionSelector: this.increment.selector,
        //     associatedFunction: ManifestFunction({
        //         functionType: ManifestAssociatedFunctionType
        //             .PRE_HOOK_ALWAYS_DENY,
        //         functionId: 0,
        //         dependencyIndex: 0
        //     })
        // });

        return manifest;
    }

    /// @inheritdoc BasePlugin
    function pluginMetadata()
        external
        pure
        virtual
        override
        returns (PluginMetadata memory)
    {
        PluginMetadata memory metadata;
        metadata.name = NAME;
        metadata.version = VERSION;
        metadata.author = AUTHOR;
        return metadata;
    }
}
