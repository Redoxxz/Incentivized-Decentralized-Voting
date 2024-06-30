const { expect } = require("chai");

async function main() {
    const [deployer, pollManager, voter] = await ethers.getSigners();
    console.log("Deploying contracts with the account:", deployer.address);

    const PollContract = await ethers.getContractFactory("PollContract");
    const pollContract = await PollContract.deploy(deployer.address);

    await pollContract.grantRole(await pollContract.POLL_MANAGER_ROLE(), pollManager.address);

    await testPollContract(pollContract, pollManager, voter);
}

async function testPollContract(pollContract, pollManager, voter) {
    console.log("Testing PollContract...");

    // Create a poll
    await pollContract.connect(pollManager).createPoll("What's your favorite color?", ["Red", "Blue", "Green"]);
    console.log("Poll created.");

    // Activate the poll
    await pollContract.connect(pollManager).activatePoll(0);
    console.log("Poll activated.");

    // Voting in the poll
    await pollContract.vote(0, 1); // Voting for option "Blue"
    console.log("Vote registered for Blue.");

    // Check if voting incremented correctly
    const votesForBlue = await pollContract.polls(0).then(poll => poll.votes(1));
    expect(votesForBlue).to.equal(1);
    console.log("Correctly incremented votes for Blue.");

    // Try to vote again should fail
    try {
        await pollContract.connect(voter).vote(0, 1);
    } catch {
        console.log("Error: Voter cannot vote more than once.");
    }

    // Close the poll
    await pollContract.connect(pollManager).closePoll(0);
    console.log("Poll closed.");

    // Ensure poll is no longer active
    const isActive = await pollContract.polls(0).then(poll => poll.isActive);
    expect(isActive).to.equal(false);
    console.log("Poll is no longer active after being closed.");

    console.log("All PollContract tests passed.");
}

main()
    .then(() => process.exit(0))
    .catch(error => {
        console.error("An error occurred:", error);
        process.exit(1);
    });
