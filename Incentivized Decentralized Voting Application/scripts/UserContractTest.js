const { expect } = require("chai");

async function main() {
    const [deployer, user] = await ethers.getSigners();
    console.log("Deploying UserContract with the account:", deployer.address);

    const LoyaltyToken = await ethers.getContractFactory("LoyaltyToken");
    const loyaltyToken = await LoyaltyToken.deploy();
    await loyaltyToken.setupMinter(deployer.address);
    await loyaltyToken.mint(deployer.address, 1000);  // Provide initial tokens for testing

    const UserContract = await ethers.getContractFactory("UserContract");
    const userContract = await UserContract.deploy(deployer.address);

    // Ensure the deployer can manage user roles
    await userContract.grantRole(await userContract.USER_MANAGER_ROLE(), deployer.address);

    // Simulate user registration
    await userContract.connect(deployer).registerUser(deployer.address);
    console.log(`User registration complete for address ${user.address}`);

    await testUserContract(userContract, user, deployer, loyaltyToken);
}

async function testUserContract(userContract, user, deployer, loyaltyToken) {
    console.log("Testing UserContract functionality...");

    // Approve UserContract to spend tokens on behalf of user
    await loyaltyToken.connect(user).approve(user.address, 1000);

    // Test token deposit
    console.log("Testing token deposit...");
    await userContract.connect(deployer).depositTokens(user.address, 500);
    let userProfile = await userContract.userProfiles(user.address);
    expect(userProfile.tokenBalance).to.equal(500);
    console.log("Token deposit test passed.");

    // Test voting functionality
    console.log("Testing voting...");
    await userContract.connect(deployer).recordVote(user.address, 1, "Option A");
    userProfile = await userContract.userProfiles(user.address);
    expect(userProfile.pollsParticipated[1]).to.be.true;
    expect(userProfile.votingRecords[0]).to.equal("Option A");
    console.log("Voting test passed.");

    // Test redemption of tokens for credit
    console.log("Testing token redemption for credit...");
    await userContract.connect(deployer).redeemTokensForCredit(deployer.address, 500);
    userProfile = await userContract.userProfiles(deployer.address);
    expect(userProfile.storeCredit).to.equal(200);  // Assuming redemption logic as specified
    expect(userProfile.tokenBalance).to.equal(0);
    console.log("Token redemption for credit test passed.");

    console.log("All UserContract tests passed.");
}

main()
    .then(() => process.exit(0))
    .catch(error => {
        console.error("An error occurred:", error);
        process.exit(1);
    });
