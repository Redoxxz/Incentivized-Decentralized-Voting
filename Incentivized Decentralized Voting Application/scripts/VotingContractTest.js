const { expect } = require("chai");

async function main() {
    const [deployer, voteManager, voter1, voter2] = await ethers.getSigners();
    console.log("Deploying contracts with the account:", deployer.address);

    const LoyaltyToken = await ethers.getContractFactory("LoyaltyToken");
    const loyaltyToken = await LoyaltyToken.deploy();

    const VotingContract = await ethers.getContractFactory("VotingContract");
    const votingContract = await VotingContract.deploy(deployer.address);
    console.log("VotingContract deployed to:", votingContract.address);

    await votingContract.grantRole(await votingContract.VOTE_MANAGER_ROLE(), voteManager.address);

    await testVotingContract(votingContract, voteManager, voter1, voter2, loyaltyToken);
}

async function testVotingContract(votingContract, voteManager, voter1, voter2, loyaltyToken) {
    console.log("Testing VotingContract...");

    const pollId = 1;
    const option = 0;
/*
    // Cast a vote
    await votingContract.connect(voteManager).castVote(pollId, option);
    console.log("Vote casted by vote manager.");

    // Check vote count
    const voteCount = await votingContract.votes(pollId).then(vote => vote.optionCounts(option));
    expect(voteCount).to.equal(1);
    console.log("Vote count is correctly recorded.");

    // Attempt to vote again by the same manager will fail
    try {
        await votingContract.connect(voteManager).castVote(pollId, option);
    } catch {
        console.log("Error: Vote manager cannot vote more than once in the same poll.");
    }
*/
    // Check if a different voter can vote
    await votingContract.connect(voteManager).grantRole(await votingContract.VOTE_MANAGER_ROLE(), voter1.address);
    await votingContract.connect(voter1).castVote(pollId, option);
    console.log("Vote casted by another voter.");


    // Check loyaltyToken balance as a reward for voting (assuming the loyaltyToken contract works as expected)
    const balance = await loyaltyToken.balanceOf(voter1.address);
    expect(balance).to.equal(1); // Assuming 1 loyaltyToken is rewarded per vote
    console.log("LoyaltyToken rewarded correctly.");

    console.log("All VotingContract tests passed.");
}

main()
    .then(() => process.exit(0))
    .catch(error => {
        console.error("An error occurred:", error);
        process.exit(1);
    });
