const PoolHandler = artifacts.require("PoolHandler");
const HandlerProxy = artifacts.require("HandlerProxy");

module.exports = async function (deployer) {
    await deployer.deploy(PoolHandler);
    await deployer.deploy(HandlerProxy, PoolHandler.address);
    const handler = await PoolHandler.at(HandlerProxy.address);
    await handler.initialize(
        "0x" // _distribution
        );
};
