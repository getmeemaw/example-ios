import meemaw
import web3
import Foundation

// To run : swift run
// Note : need to have "RPC" in environment variables (= rpc url)(=> "export" content of .env)

print("Hello, world!")

var rpcUrl = ""
if let rpcUrlEnv = ProcessInfo.processInfo.environment["RPC"] {
    rpcUrl = rpcUrlEnv
} else {
    print("could not find rpc url")
    exit(0)
}

let auth = "eyJhbGciOiJIUzI1NiIsImtpZCI6ImNEdE1CREFQNlphcm15QU8iLCJ0eXAiOiJKV1QifQ.eyJpc3MiOiJodHRwczovL3NnZHh4d2FsdGNkaW1pdWlrZm1uLnN1cGFiYXNlLmNvL2F1dGgvdjEiLCJzdWIiOiIxZDNiM2I0Zi1jNGM5LTQ1ZTYtYWZlNi00MWY3MmU2ZmQ3MWMiLCJhdWQiOiJhdXRoZW50aWNhdGVkIiwiZXhwIjoxNzIxMzM2MzI3LCJpYXQiOjE3MjEzMzI3MjcsImVtYWlsIjoibWFyY2VhdWxlY29tdGVAZ21haWwuY29tIiwicGhvbmUiOiIiLCJhcHBfbWV0YWRhdGEiOnsicHJvdmlkZXIiOiJlbWFpbCIsInByb3ZpZGVycyI6WyJlbWFpbCJdfSwidXNlcl9tZXRhZGF0YSI6e30sInJvbGUiOiJhdXRoZW50aWNhdGVkIiwiYWFsIjoiYWFsMSIsImFtciI6W3sibWV0aG9kIjoicGFzc3dvcmQiLCJ0aW1lc3RhbXAiOjE3MTk5MzUyMzR9XSwic2Vzc2lvbl9pZCI6ImFiYmQ2NTAzLTg3ZmItNGI4OC04MDRhLTI2MjViMGU4OTk0YiIsImlzX2Fub255bW91cyI6ZmFsc2V9.6vbhHHQFltpKDrmSmfQS44CGs3s2sGY5mmMkzpBIpZ8"

let meemaw = Meemaw(server: "http://localhost:8421")
// let wallet = try await meemaw.GetWallet(auth: auth) // works as well
let wallet = try await meemaw.GetWallet(
    auth: auth, 
    callbackRegisterStarted: { deviceCode in
        print("Registration started for device \(deviceCode)")
    },
    callbackRegisterDone: { deviceCode in
        print("Registration completed for device \(deviceCode)")
    })

print("received wallet from meemaw.GetWallet:")
print(wallet)

try await Export(wallet: wallet)
// try await AcceptDevice(wallet: wallet)
try await SendTx(wallet: wallet)

public func AcceptDevice(wallet: Wallet) async throws -> Void {
    do{
        try wallet.AcceptDevice()
        print("device accepted")
    } catch {
        print("could not accept")
    }
}

public func Export(wallet: Wallet) async throws -> Void {
    do{
        let privateKey = try wallet.Recover()
        print("privateKey:", privateKey)
    } catch {
        print("could not recover")
    }
}

public func SendTx(wallet: Wallet) async throws -> Void {
    guard let clientUrl = await URL(string: rpcUrl) else { exit(0) }
    let client = EthereumHttpClient(url: clientUrl, network: EthereumNetwork.sepolia)

    let gasPrice = try await client.eth_gasPrice()
    let nonce = try await client.eth_getTransactionCount(address: wallet.From(), block: EthereumBlock.Latest)

    let transaction = EthereumTransaction(
        from: wallet.From(),
        to: "0xDb2A6F33FFC6624869e16C75829Fc39862A55DDB",
        value: 10000000000000,
        data: Data(),
        nonce: nonce,
        gasPrice: gasPrice,
        gasLimit: 21000,
        chainId: 11155111
    )

    let txHash = try await client.eth_sendRawTransaction(transaction, withAccount: wallet)
    print("Look at my fabulous transaction: \(txHash)")
}