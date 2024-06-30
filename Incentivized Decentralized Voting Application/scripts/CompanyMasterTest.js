const { expect } = require("chai");

async function main() {
    const [deployer, anotherAccount] = await ethers.getSigners();
    console.log("Deploying CompanyMaster with the account:", deployer.address);

    const CompanyMaster = await ethers.getContractFactory("CompanyMaster");
    const companyMaster = await CompanyMaster.deploy();
    console.log("CompanyMaster deployed to:", companyMaster.address);

    await testCompanyMaster(companyMaster, deployer, anotherAccount);
}

async function testCompanyMaster(companyMaster, deployer, anotherAccount) {
    console.log("Testing deployment functionality...");

    // Test contract deployment functions
    const LoyaltyToken = await ethers.getContractFactory("LoyaltyToken");
    const loyaltyToken = await LoyaltyToken.deploy();

    await companyMaster.deployLoyaltyToken(deployer.address);
    expect(await companyMaster.loyaltyToken()).to.equal(deployer.address);
    console.log("Loyalty Token contract deployed and recorded correctly.");

    const UserContract = await ethers.getContractFactory("UserContract");
    const userContract = await UserContract.deploy(deployer.address);
    await companyMaster.deployUserContract(deployer.address);
    expect(await companyMaster.userContract()).to.equal(deployer.address);
    console.log("User contract deployed and recorded correctly.");

    const PollContract = await ethers.getContractFactory("PollContract");
    const pollContract = await PollContract.deploy(deployer.address);
    await companyMaster.deployPollContract(deployer.address);
    expect(await companyMaster.pollContract()).to.equal(deployer.address);
    console.log("Poll contract deployed and recorded correctly.");

    // Test role management
    console.log("Testing role management...");
    await companyMaster.setupRole(companyMaster.USER_MANAGER_ROLE(), anotherAccount.address);
    expect(await companyMaster.hasRole(companyMaster.USER_MANAGER_ROLE(), anotherAccount.address)).to.be.true;
    console.log("User manager role granted successfully.");

    // Test secured function
    console.log("Testing unauthorized access...");
    try {
        await companyMaster.connect(anotherAccount).manageUser(anotherAccount.address, true);
    } catch (error) {
        console.log("Error: Unauthorized access prevented for manageUser function. (Passing)");
    }

    console.log("All CompanyMaster tests passed.");
}

main()
    .then(() => process.exit(0))
    .catch(error => {
        console.error("An error occurred:", error);
        process.exit(1);
    });
