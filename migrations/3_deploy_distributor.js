const TokenDistributor = artifacts.require("TokenDistributor");
const HandlerProxy = artifacts.require("HandlerProxy");

module.exports = async function (deployer, network, accounts) {
    const FILDA = "0xe36ffd17b2661eb57144ceaef942d95295e637f0";
    await deployer.deploy(TokenDistributor);
    await deployer.deploy(HandlerProxy,
        TokenDistributor.address,
        "0x3455F426CB1c2a8c61b0a6e5F7A8BA98893888a9" // _governance
        );

    const oldHandler = await TokenDistributor.at("0x54884e90B2572cF910E46174B5ea684035BEEBCF");
    await oldHandler.withdraw(FILDA, "0x7a04448863aDc17c2e3529dB1f6d827495E19EE9", 23720563);

    var startHeight = await oldHandler.lastUpdateHeight()
    console.log("Old TokenDistributor height is "+startHeight);

    const newHandler = await TokenDistributor.at(HandlerProxy.address);
    await newHandler.initialize("0xD3b4C3af64B5053071d903CD67CD652A4f14E07E", // _distribution
        '0xe36ffd17b2661eb57144ceaef942d95295e637f0', // _token
        startHeight, // _startHeight
        2021627 // _halfHeight
        );

    var accounts = [];
    var rewards = []
    var count = await oldHandler.getRecipientCount();
    for (var i=0; i<count; i++) {
        var address = (await oldHandler.recipientList(i)).toString()
        
        var value = (await oldHandler.getProportion(address)).toString()
        console.log("recipient: " +  address + " value "+value)

        accounts.push(address.toString());
        rewards.push(value.toString());
    }

    console.log("accounts: "+accounts);
    console.log("rewards: "+rewards);

    await newHandler.add(accounts, rewards);

    count = await newHandler.getRecipientCount();
    for (var i=0; i<count; i++) {
        var address = (await newHandler.recipientList(i)).toString()
        
        var value = (await newHandler.getProportion(address)).toString()
        console.log("recipient: " +  address + " value "+value)
    }





    console.log("***********************************************");
    console.log("TokenDistributor address:", HandlerProxy.address);
    console.log("***********************************************");

};
