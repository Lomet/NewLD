import { deployed } from "../test/helper"
import { LockDealProvider } from "../typechain-types"

async function main() {
    const lockDealNFT = "0x57e0433551460e85dfC5a5DdafF4DB199D0F960A" // replace with your lockDealNFT address
    const dealProvider = "0x2028C98AC1702E2bb934A3E88734ccaE42d44338" // replace with your dealProvider address
    const lockProvider: LockDealProvider = await deployed("LockDealProvider", lockDealNFT, dealProvider)
    console.log(`Contract deployed to ${lockProvider.address}`)
}

main().catch((error) => {
    console.error(error)
    process.exitCode = 1
})
