const PoolHandler = artifacts.require("PoolHandler");
const HandlerProxy = artifacts.require("HandlerProxy");

module.exports = async function (deployer, network, accounts) {
    await deployer.deploy(PoolHandler);
    await deployer.deploy(HandlerProxy,
        PoolHandler.address,
        "0x" // _governance
        );
    const handler = await PoolHandler.at(HandlerProxy.address);
    await handler.initialize(
        "0x" // _distribution
        );
    console.log("***********************************************");
    console.log("PoolHandler address:", HandlerProxy.address);
    console.log("***********************************************");
};
