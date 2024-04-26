import SwiftUI
import MeemawSDK
import web3

struct ContentView: View {
    @State private var result: String = ""
    
    var body: some View {
        VStack {
            Text(result)
                .padding()
            
            Button("Perform Task") {
                performTask()
            }
        }
    }
    
    func performTask() {
        // Show loading indicator
        result = "Loading..."
        
        Task.detached {
            do {
                let meemaw = Meemaw(server: "ws://localhost:8421")
                let wallet = try await meemaw.GetWallet(auth: "bonjour")
                
                print("received wallet from meemaw.GetWallet:")
                print(wallet)
                
                guard let clientUrl = URL(string: "JSON-RPC_API_URL") else { return }
                let client = EthereumHttpClient(url: clientUrl, network: EthereumNetwork.sepolia)
                
                let gasPrice = try await client.eth_gasPrice()
                let nonce = try await client.eth_getTransactionCount(address: wallet.From(), block: EthereumBlock.Latest)
                
                let transaction = EthereumTransaction(
                    from: wallet.From(),
                    to: "0x809ccc37d2dd55a8e8fa58fc51d101c6b22425a8",
                    value: 10000000000000,
                    data: Data(),
                    nonce: nonce,
                    gasPrice: gasPrice,
                    gasLimit: 21000,
                    chainId: 11155111
                )
                
                let txHash = try await client.eth_sendRawTransaction(transaction, withAccount: wallet)
                print("Look at my fabulous transaction: \(txHash)")
                
                // Process the task result
                let taskResult = "Task completed successfully:"+txHash
                
                // Update the UI on the main queue
                DispatchQueue.main.async {
                    result = taskResult
                }
            } catch {
                print("error while running task:")
                print(error)
                
                // Update the UI on the main queue
                DispatchQueue.main.async {
                    result = "error"
                    print(result)
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
