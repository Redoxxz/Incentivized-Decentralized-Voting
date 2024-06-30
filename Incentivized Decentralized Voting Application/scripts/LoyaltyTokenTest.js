const { expect } = require("chai");

async function main() {
    const [deployer, tester, anotherAccount] = await ethers.getSigners();
    console.log("Deploying contracts with the account:", deployer.address);

    const LoyaltyToken = await ethers.getContractFactory("LoyaltyToken");
    const loyaltyToken = await LoyaltyToken.deploy();
    console.log("LoyaltyToken deployed to:", loyaltyToken.address);

    await testLoyaltyToken(loyaltyToken, tester, anotherAccount);
}

async function testLoyaltyToken(loyaltyToken, tester, anotherAccount) {
    console.log("Testing LoyaltyToken Roles...");
    // Role setup
    await loyaltyToken.setupMinter(tester.address);
    await loyaltyToken.setupBurner(tester.address);

    // Edge Case: Minting zero tokens
    await loyaltyToken.connect(tester).mint(tester.address, 0);
    const balanceAfterMintingZero = await loyaltyToken.balanceOf(tester.address);
    expect(balanceAfterMintingZero).to.equal(0);
    console.log("Minting zero tokens does not change balance.");

    // Normal Mint
    await loyaltyToken.connect(tester).mint(tester.address, 1000);
    const balanceAfterNormalMint = await loyaltyToken.balanceOf(tester.address);
    expect(balanceAfterNormalMint).to.equal(1000);
    console.log("Minting 1000 tokens successful.");

    // Edge Case: Burning more tokens than balance
    console.log("Burning more than available...")
    try{
        await loyaltyToken.connect(tester).burn(tester.address, 1500);
    }
    catch{
        console.log("Error: Tried to burn more tokens than available; None Burned");
    }
    console.log("Burning Balance Amount Or Less...");
    await loyaltyToken.connect(tester).burn(tester.address, 750);
    const balanceAfterUnderburn = await loyaltyToken.balanceOf(tester.address);
    expect(balanceAfterUnderburn).to.equal(250);
    await loyaltyToken.connect(tester).burn(tester.address, 250);
    const balanceAfterNormalburn = await loyaltyToken.balanceOf(tester.address);
    expect(balanceAfterNormalburn).to.equal(0);
    console.log("Burning Balance Amount Or Less Works As Intended");

    // Edge Case: Burning zero tokens
    console.log("Burning zero tokens...");
    await loyaltyToken.connect(tester).burn(tester.address, 0);
    expect(await loyaltyToken.balanceOf(tester.address)).to.equal(0);
    console.log("Burning zero tokens has no effect.");

    // Role Manipulation: Removing Minter and Burner roles and testing
    console.log("Removing Minter and Burner Roles");
    await loyaltyToken.revokeRole(await loyaltyToken.MINTER_ROLE(), tester.address);
    try{
        await loyaltyToken.connect(tester).mint(tester.address, 100); // This should have no effect now
    }
    catch{
        console.log("Error: Tried to mint without role; No change (Passing)");
    }
    const finalBalanceAfterRoleRemoval = await loyaltyToken.balanceOf(tester.address);
    expect(finalBalanceAfterRoleRemoval).to.equal(0);
    console.log("Minting after revoking minter role has no effect.");

    console.log("All LoyaltyToken tests passed.");
}

main()
    .then(() => process.exit(0))
    .catch(error => {
        console.error("An error occurred:", error);
        process.exit(1);
    });
