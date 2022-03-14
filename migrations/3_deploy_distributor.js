const TokenDistributor = artifacts.require("TokenDistributor");
const HandlerProxy = artifacts.require("HandlerProxy");

module.exports = async function (deployer, network, accounts) {
    await deployer.deploy(TokenDistributor);

    await deployer.deploy(HandlerProxy,
        TokenDistributor.address,
        "0x" // _governance
        );
    const t = await TokenDistributor.at(HandlerProxy.address);
    await t.initialize(
        "0x", // _distribution
        '0x', // _token
        [], // _rewardHeightArray
        [] // _rewardPerBlockArray
        );
    console.log("***********************************************");
    console.log("TokenDistributor address:", HandlerProxy.address);
    console.log("***********************************************");

};
