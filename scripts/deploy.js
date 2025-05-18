const { ethers, network, run } = require("hardhat");

async function main() {
  const Logi = await ethers.getContractFactory("Logi");
  const logi = await Logi.deploy();

  await logi.waitForDeployment();
  const address = await logi.getAddress();
  console.log(`Deployed contract address: ${address}`);
  // if (network.config.chainId === 534351 && process.env.SCROLL_SCAN) {
  //   console.log("Waiting for 6 confirmations before verifying...");
  //   await delay(30000);
  //   await verify(address, []);
  // }
}

// Utility function to add a delay
function delay(ms) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

//Progammatic Verification of contract
async function verify(contractAddress, args) {
  console.log("Verifying contract!");

  try {
    await run("verify:verify", {
      address: contractAddress,
      constructorArguments: args,
    });
  } catch (e) {
    if (e.message.toLowerCase().includes("already verified")) {
      console.log("Already Verified");
    } else {
      console.log(e);
    }
  }
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
