
import { Wallet, utils } from "zksync-web3";
import * as ethers from "ethers";
import { HardhatRuntimeEnvironment } from "hardhat/types";
import { Deployer } from "@matterlabs/hardhat-zksync-deploy";

// An example of a deploy script that will deploy and call a simple contract.
export default async function (hre: HardhatRuntimeEnvironment) {
  console.log(`Running deploy script for the tester contract`);

  // Initialize the wallet.
  const wallet = new Wallet('');

  // Create deployer object and load the artifact of the contract you want to deploy.
  const deployer = new Deployer(hre, wallet);
  
  // Load the  artifact.
  const MyTokenArtifact = await deployer.loadArtifact("MyToken");

  // Estimate contract deployment fee for the  contract.
  const TokenDeploymentFee = await deployer.estimateDeployFee(MyTokenArtifact, []);

  // Deploy  contract with the address of the  contract as a constructor argument.
  const TokenContract = await deployer.deploy(MyTokenArtifact, []);

  // Show the  contract info.
  const MyTokenAddress = TokenContract.address;
  console.log(`${MyTokenArtifact.contractName} was deployed to ${MyTokenAddress}`);
}



