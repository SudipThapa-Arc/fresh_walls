window.flutterConfiguration = {
    async setDeliveryPlatform() {
        // Configure asset loading
        window._flutter = {
            loader: {
                load: function(options) {
                    // Configure the asset loading behavior
                    const assetBase = options?.serviceWorker?.serviceWorkerVersion 
                        ? `/` 
                        : options.assetBase || '/';
                    
                    // Set up asset loading configuration
                    window.FLUTTER_ASSET_BASE_URL = assetBase;
                    window._flutter_loader = {
                        prefetchAssets: true,
                        onEntrypointLoaded: options.onEntrypointLoaded,
                        serviceWorker: options.serviceWorker,
                        assetBase: assetBase,
                        canvasKitBaseUrl: `${assetBase}canvaskit/`
                    };
                    
                    return Promise.resolve();
                }
            }
        };
    }
}; 