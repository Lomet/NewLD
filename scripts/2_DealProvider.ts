import { deployed } from "../test/helper"
import { DealProvider } from "../typechain-types"

async function main() {
    const lockDealNFT = "0x57e0433551460e85dfC5a5DdafF4DB199D0F960A" // replace with your lockDealNFT address
    const dealProvider: DealProvider = await deployed("DealProvider", lockDealNFT)
    console.log(`Contract deployed to ${dealProvider.address} with lockDealNFT ${lockDealNFT}`)
}

main().catch((error) => {
    console.error(error)
    process.exitCode = 1
})
