const PoolHandler = artifacts.require("PoolHandler");
const HandlerProxy = artifacts.require("HandlerProxy");

module.exports = async function (deployer, network, accounts) {
    // await deployer.deploy(PoolHandler);
    // await deployer.deploy(HandlerProxy,
    //     PoolHandler.address,
    //     "0x3455F426CB1c2a8c61b0a6e5F7A8BA98893888a9" // _governance
    //     );
    // const handler = await PoolHandler.at(HandlerProxy.address);
    // await handler.initialize(
    //     "0xD3b4C3af64B5053071d903CD67CD652A4f14E07E" // _distribution
    //     );
    // console.log("***********************************************");
    // console.log("PoolHandler address:", HandlerProxy.address);
    // console.log("***********************************************");


    await deployer.deploy(PoolHandler);
    await deployer.deploy(HandlerProxy,
        PoolHandler.address,
        "0x735e95fa199c947EDe682d724f55ECa3205678ff" // _governance
        );
    const handler2 = await PoolHandler.at(HandlerProxy.address);
    await handler2.initialize(
        "0xD3b4C3af64B5053071d903CD67CD652A4f14E07E" // _distribution
        );
    console.log("***********************************************");
    console.log("PoolHandler address:", HandlerProxy.address);
    console.log("***********************************************");

};
