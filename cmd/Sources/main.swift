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

let auth = "eyJhbGciOiJIUzI1NiIsImtpZCI6ImNEdE1CREFQNlphcm15QU8iLCJ0eXAiOiJKV1QifQ.eyJpc3MiOiJodHRwczovL3NnZHh4d2FsdGNkaW1pdWlrZm1uLnN1cGFiYXNlLmNvL2F1dGgvdjEiLCJzdWIiOiIxZDNiM2I0Zi1jNGM5LTQ1ZTYtYWZlNi00MWY3MmU2ZmQ3MWMiLCJhdWQiOiJhdXRoZW50aWNhdGVkIiwiZXhwIjoxNzIxNDA2OTA5LCJpYXQiOjE3MjE0MDMzMDksImVtYWlsIjoibWFyY2VhdWxlY29tdGVAZ21haWwuY29tIiwicGhvbmUiOiIiLCJhcHBfbWV0YWRhdGEiOnsicHJvdmlkZXIiOiJlbWFpbCIsInByb3ZpZGVycyI6WyJlbWFpbCJdfSwidXNlcl9tZXRhZGF0YSI6e30sInJvbGUiOiJhdXRoZW50aWNhdGVkIiwiYWFsIjoiYWFsMSIsImFtciI6W3sibWV0aG9kIjoicGFzc3dvcmQiLCJ0aW1lc3RhbXAiOjE3MTk5MzUyMzR9XSwic2Vzc2lvbl9pZCI6ImFiYmQ2NTAzLTg3ZmItNGI4OC04MDRhLTI2MjViMGU4OTk0YiIsImlzX2Fub255bW91cyI6ZmFsc2V9.KDnlIKv4PjfEmch6XzmT6hzCc5-U8njWpsl1u3zXcG8"
let backup = "7b22446b67526573756c74223a227b5c225075626b65795c223a7b5c22585c223a5c2239343331383030363333363630333038393138313536393930373731353939303038373736313131343732313439393435303334343339303532383639323134323633333434373437373232395c222c5c22595c223a5c223130393038383131323537393235323633333039373230373333383435313632393633313636343938343931353639313030303431333232333131353138383530303332323735303334303433385c227d2c5c22424b735c223a7b5c2233343939666239652d346365322d343966312d383565352d6133613435353331343837395c223a7b5c22585c223a5c2239323131333534333035333934363137333737383336343131333434303736353736303332383631313335383535363435343538393130373531343637343936373333313236333339363930305c222c5c2252616e6b5c223a307d2c5c2261633033393665362d333738332d346535352d396237332d3464623732646338633364635c223a7b5c22585c223a5c2238323431353234383932333338303732323537313837393833353039343231323832353238313435393039373338373835343234363935353032323534353736313539393437363930383239355c222c5c2252616e6b5c223a307d2c5c227365727665725c223a7b5c22585c223a5c2231313239303236353635373537313635373136303734303239343239303438363739373334363531383136303635323733303633313135363938373136343932383335323230353136323433325c222c5c2252616e6b5c223a307d7d2c5c2253686172655c223a5c2237303133383032303531373138383932353335363439323236333838303635303837363731333733303631333030313239313934373134343239393236383735383435363031393232353138365c222c5c22416464726573735c223a5c223078373537383534323430384263313143316335313138303664353863353543396443363339353533335c222c5c225065657249445c223a5c2233343939666239652d346365322d343966312d383565352d6133613435353331343837395c227d222c224d65746164617461223a2261396232333666303463643433646466373930336163623435313939396633343730633939623232383530643032346563656363323762626134333738633134227d"

let meemaw = Meemaw(server: "http://localhost:8421")
// let wallet = try await meemaw.GetWallet(auth: auth) // works as well
// let wallet = try await meemaw.GetWallet(
//     auth: auth, 
//     callbackRegisterStarted: { deviceCode in
//         print("Registration started for device \(deviceCode)")
//     },
//     callbackRegisterDone: { deviceCode in
//         print("Registration completed for device \(deviceCode)")
//     })
let wallet = try await meemaw.GetWalletFromBackup(auth: auth, backup: backup)

print("received wallet from meemaw.GetWallet:")
print(wallet)

try await Backup(wallet: wallet)
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
        let privateKey = try wallet.Export()
        print("privateKey:", privateKey)
    } catch {
        print("could not recover")
    }
}

public func Backup(wallet: Wallet) async throws -> Void {
    do{
        let backup = try wallet.Backup()
        print("backup:", backup)
    } catch {
        print("could not Backup")
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